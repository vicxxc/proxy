//
//  ShadowSocksProxySocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/10.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

// Define various socket tags
#define SOCKS_OPEN             10100
//#define SOCKS_CONNECT_AUTH_INIT     10101
//#define SOCKS_CONNECT_AUTH_USERNAME     10102
//#define SOCKS_CONNECT_AUTH_PASSWORD     10103
//
#define SOCKS_CONNECT_INIT     10200
//#define SOCKS_CONNECT_IPv4     10201
//#define SOCKS_CONNECT_DOMAIN   10202
//#define SOCKS_CONNECT_DOMAIN_LENGTH   10212
//#define SOCKS_CONNECT_IPv6     10203
//#define SOCKS_CONNECT_PORT     10210
//#define SOCKS_CONNECT_REPLY    10300
//#define SOCKS_INCOMING_READ    10400
//#define SOCKS_INCOMING_WRITE   10401
//#define SOCKS_OUTGOING_READ    10500
//#define SOCKS_OUTGOING_WRITE   10501

// Timeouts
#define TIMEOUT_CONNECT       8.00
//#define TIMEOUT_READ          5.00
//#define TIMEOUT_TOTAL        80.00

#import "ShadowSocksProxySocket.h"
#import "NSData+AES256.h"
#import "CCCrypto.h"

@interface ShadowSocksProxySocket() <GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *proxySocket;
@property (nonatomic, strong) GCDAsyncSocket *outgoingSocket;
@property (nonatomic, strong) CCCrypto *crypto;
@end

@implementation ShadowSocksProxySocket

- (id) initWithSocket:(GCDAsyncSocket *)socket{
	if (self = [super init]) {
		dispatch_queue_t delegateQueue = dispatch_queue_create("SOCKSProxySocket socket delegate queue", 0);
		self.proxySocket = socket;
		self.proxySocket.delegate = self;
		self.proxySocket.delegateQueue = delegateQueue;
		self.outgoingSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:delegateQueue];
		NSData *key = [[NSData new] generateKey:[@"barfoo!" dataUsingEncoding:NSUTF8StringEncoding] keyLen:32 IVLen:16];
		NSData *iv = [[NSData new] convertHexStrToData:@"3d32955f8615096eee96038ba2dc4b61"];
		self.crypto = [[CCCrypto shareInstance] initWithCCOperation:kCCEncrypt CCMode:kCCModeCFB CCAlgorithm:kCCAlgorithmAES IV:iv Key:key];
		[self.proxySocket readDataToLength:3 withTimeout:TIMEOUT_CONNECT tag:SOCKS_OPEN];
		[self.proxySocket readDataWithTimeout:TIMEOUT_CONNECT tag:SOCKS_OPEN];
	}
	return self;
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	NSLog(@"load-------data%@",data);
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
		[data subdataWithRange:NSMakeRange(3, 1)];
//		addrToSend = data.slice(3, 4).toString("binary");
//		if (addrtype === 1) {
//			remoteAddr = utils.inetNtoa(data.slice(4, 8));
//			addrToSend += data.slice(4, 10).toString("binary");
//			remotePort = data.readUInt16BE(8);
//			headerLength = 10;
//		} else if (addrtype === 4) {
//			remoteAddr = inet.inet_ntop(data.slice(4, 20));
//			addrToSend += data.slice(4, 22).toString("binary");
//			remotePort = data.readUInt16BE(20);
//			headerLength = 22;
//		} else {
//			remoteAddr = data.slice(5, 5 + addrLen).toString("binary");
//			addrToSend += data.slice(4, 5 + addrLen + 2).toString("binary");
//			remotePort = data.readUInt16BE(5 + addrLen);
//			headerLength = 5 + addrLen + 2;
//		}
	}
}

@end
