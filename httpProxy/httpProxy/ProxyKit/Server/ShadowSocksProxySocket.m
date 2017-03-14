//
//  ShadowSocksProxySocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/10.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

// Define various socket tags
#define SOCKS_OPEN             10100
#define SOCKS_CONNECT_INIT     10200
#define SOCKS_CONNECT_REPLY    10300
#define SOCKS_INCOMING_READ    10400
#define SOCKS_INCOMING_WRITE   10401
#define SOCKS_OUTGOING_READ    10500
#define SOCKS_OUTGOING_WRITE   10501

// Timeouts
#define TIMEOUT_CONNECT		    -1

#import "ShadowSocksProxySocket.h"
#import "NSData+AES256.h"
#import "CCCrypto.h"

@interface ShadowSocksProxySocket() <GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *proxySocket;
@property (nonatomic, strong) GCDAsyncSocket *outgoingSocket;
@property (nonatomic, strong) CCCrypto *crypto;
@property (nonatomic, strong) CCCrypto *decrypto;
@property (nonatomic, strong) NSData *iv;
@property (nonatomic, strong) NSData *buffer;
@end

@implementation ShadowSocksProxySocket

- (id) initWithSocket:(GCDAsyncSocket *)socket{
	if (self = [super init]) {
		dispatch_queue_t delegateQueue = dispatch_queue_create("SOCKSProxySocket socket delegate queue", 0);
		self.proxySocket = socket;
		self.proxySocket.delegate = self;
		self.proxySocket.delegateQueue = delegateQueue;
		self.outgoingSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:delegateQueue];
		self.proxySocket.delegate = self;
		NSData *key = [[NSData new] generateKey:[@"barfoo!" dataUsingEncoding:NSUTF8StringEncoding] keyLen:32 IVLen:16];
		self.iv = [[NSData new] convertHexStrToData:@"3d32955f8615096eee96038ba2dc4b61"];
		self.crypto = [[CCCrypto shareInstance] initWithCCOperation:kCCEncrypt CCMode:kCCModeCFB CCAlgorithm:kCCAlgorithmAES IV:self.iv Key:key];
		[self.proxySocket readDataWithTimeout:TIMEOUT_CONNECT tag:SOCKS_OPEN];
	}
	return self;
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	NSLog(@"-------didReadData%@-----%lu",data,(unsigned long)data.length);
	if (tag == SOCKS_OPEN) {
		 // 首次收到直接扔回x05x00
		[sock writeData:[[NSData new] convertHexStrToData:@"0500"] withTimeout:-1 tag:SOCKS_OPEN];
		[sock readDataWithTimeout:TIMEOUT_CONNECT tag:SOCKS_CONNECT_INIT];
	}
	if(tag == SOCKS_CONNECT_INIT) {
		// 暂时不考虑UDP
		//      +-----+-----+-----+------+------+------+
		// NAME | VER | CMD | RSV | ATYP | ADDR | PORT |
		//      +-----+-----+-----+------+------+------+
		// SIZE |  1  |  1  |  1  |  1   | var  |  2   |
		//      +-----+-----+-----+------+------+------+
		// Version      = 5 (for SOCKS5)
		// Command      = 1 (for Connect)
		// Reserved     = 0
		// Address Type = 3 (1=IPv4, 3=DomainName 4=IPv6)
		// Address      = P:D (P=LengthOfDomain D=DomainWithoutNullTermination)
		// Port         = 0
		// 所以cmd!=1就直接丢弃.
		uint8_t *requestBytes = (uint8_t*)[data bytes];
		uint8_t cmd = requestBytes[1];
		uint8_t addressType = requestBytes[3];
		uint8_t addrLen = 0;
		NSInteger headerLength = 0;
		if(cmd != 1){
			[sock writeData:[[NSData new] convertHexStrToData:@"05070001"] withTimeout:-1 tag:0];
			[sock disconnectAfterWriting];
			return;
		}
		if (addressType == 3) {
			addrLen = requestBytes[4];
		}
		if(addressType !=1 && addressType !=4){
			// 不支持的Address Type 丢弃
			[sock disconnect];
			return;
		}
		NSMutableData *addrToSend = [NSMutableData new];
		[addrToSend appendData:[data subdataWithRange:NSMakeRange(3, 1)]];
		if(addressType == 1){
			[addrToSend appendData:[data subdataWithRange:NSMakeRange(4, 6)]];
			headerLength = 10;
		}else if(addressType == 4){
			[addrToSend appendData:[data subdataWithRange:NSMakeRange(4, 18)]];
			headerLength = 22;
		}else{
			[addrToSend appendData:[data subdataWithRange:NSMakeRange(4, addrLen+2)]];
			headerLength = 5+addrLen+2;
		}
		
		if (cmd == 3) {
			return;
		}
		[sock writeData:[[NSData new] convertHexStrToData:@"050000010000000008ae"] withTimeout:-1 tag:0];
		// 开始连接服务端.
		NSError *error = nil;
		[self.outgoingSocket connectToHost:@"127.0.0.1" onPort:8388 error:&error];
		self.buffer = addrToSend;
	}
	
	if (tag == SOCKS_INCOMING_READ) {
		NSData *encodedData = [self.crypto encryptData:data];
		NSLog(@"加密前data=>%@",data);
		[self.outgoingSocket writeData:encodedData withTimeout:-1 tag:SOCKS_OUTGOING_WRITE];
		[self.outgoingSocket readDataWithTimeout:-1 tag:SOCKS_OUTGOING_READ];
		[self.proxySocket readDataWithTimeout:-1 tag:SOCKS_INCOMING_READ];
	}
	if (tag == SOCKS_OUTGOING_READ) {
		NSData *encData;
		if(!self.decrypto){
			// 首先读取iv
			NSData *iv = [data subdataWithRange:NSMakeRange(0, 16)];
			NSData *key = [[NSData new] generateKey:[@"barfoo!" dataUsingEncoding:NSUTF8StringEncoding] keyLen:32 IVLen:16];
			self.decrypto = [[CCCrypto shareInstance] initWithCCOperation:kCCDecrypt CCMode:kCCModeCFB CCAlgorithm:kCCAlgorithmAES IV:iv Key:key];
			encData = [self.decrypto encryptData:[data subdataWithRange:NSMakeRange(16, data.length-16)]];
		}else{
			encData = [self.decrypto encryptData:data];
		}
		NSLog(@"解密后data=>%@",encData);
		[self.proxySocket writeData:encData withTimeout:-1 tag:SOCKS_INCOMING_WRITE];
		[self.proxySocket readDataWithTimeout:-1 tag:SOCKS_INCOMING_READ];
		[self.outgoingSocket readDataWithTimeout:-1 tag:SOCKS_OUTGOING_READ];
	}
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
	NSData *encodedData = [self.crypto encryptData:self.buffer];
	
	NSMutableData *lastSend = [NSMutableData new];
	[lastSend appendData:self.iv];
	[lastSend appendData:encodedData];
	
	[self.outgoingSocket writeData:lastSend withTimeout:-1 tag:0];
	
	[self.proxySocket readDataWithTimeout:-1 tag:SOCKS_INCOMING_READ];
}

@end
