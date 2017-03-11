//
//  ViewController.m
//  httpProxy
//
//  Created by scorpio on 2017/3/2.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "ViewController.h"
#import "HTTPHeader.h"
#import <GCDAsyncSocket.h>
#import "ProxySocket.h"
#import "SOCKSProxy.h"
#import <NAChloride.h>
#import "NSData+AES256.h"
#import "CCCrypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
@property (nonatomic, strong) NSMutableArray *allConnectedSockets;
@property (nonatomic, strong) SOCKSProxy *proxy;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.proxy = [[SOCKSProxy alloc] init];
	[self.proxy startProxyOnPort:9998];

//	NSData *key = [[NSData new] generateKey:[@"barfoo!" dataUsingEncoding:NSUTF8StringEncoding] keyLen:32 IVLen:16];
//	NSData *iv = [[NSData new] convertHexStrToData:@"3d32955f8615096eee96038ba2dc4b61"];
//	NSData *originalData = [[NSData new] convertHexStrToData:@"017f0000011808"];
//	NSData *encodedData = [originalData AES256EncryptWithKeyAndIV:key withIV:iv];
//	NSData *sec = [[[NSData new] convertHexStrToData:@"474554202f20485454502f312e310d0a486f73743a2062616964752e636f6d0d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a4163636570743a202a2f2a0d0a557365722d4167656e743a204d6f7a696c6c612f352e303031202877696e646f77733b20553b204e54342e303b20656e2d55533b2072763a312e3029204765636b6f2f32353235303130310d0a0d0a"] AES256EncryptWithKeyAndIV:key withIV:iv];
//	NSData *decodedData = [encodedData AES256DecryptWithKeyAndIV:key withIV:iv];
//	NSLog(@"1");
//	CCCrypto *crypto = [[CCCrypto shareInstance] initWithCCOperation:kCCEncrypt CCMode:kCCModeCFB CCAlgorithm:kCCAlgorithmAES IV:iv Key:key];
//	NSData *enc1 = [crypto encryptData:[[NSData new] convertHexStrToData:@"017f0000011808"]];
//	NSData *enc2 = [crypto encryptData:[[NSData new] convertHexStrToData:@"017f0000011808"]];
//	NSLog(@"1111111");
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	ProxySocket *proxySocket = [[ProxySocket alloc] initWithClientSocket:newSocket];
	[self.allConnectedSockets addObject:proxySocket];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
