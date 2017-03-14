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
	[self.proxy startProxyOnPort:9997];
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
