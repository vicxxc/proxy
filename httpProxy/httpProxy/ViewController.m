//
//  ViewController.m
//  httpProxy
//
//  Created by scorpio on 2017/3/2.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "ViewController.h"
//#import "HTTPHeader.h"
//#import <GCDAsyncSocket.h>
//#import "ProxySocket.h"
//#import "SOCKSProxy.h"
//#import <NAChloride.h>
//#import "NSData+AES256.h"
//#import "CCCrypto.h"
//#import <CommonCrypto/CommonCryptor.h>
//#import <CommonCrypto/CommonDigest.h>
//#import "Encryptor.h"
//#import <NAAEAD.h>
//#import "Tunnel.h"
//#import "HttpLocalSocket.h"
//#import "GCDTCPSocket.h"

@interface ViewController ()
//@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
//@property (nonatomic, strong) NSMutableArray *allConnectedSockets;
//@property (nonatomic, strong) SOCKSProxy *proxy;
//@property (nonatomic, strong) NSMutableArray<Tunnel *> *tunnelArray;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
//	self.proxy = [[SOCKSProxy alloc] init];
//	[self.proxy startProxyOnPort:9997];
//	
//	self.allConnectedSockets = [NSMutableArray new];
//	self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//	self.serverSocket.delegate = self;
//	NSError *error;
//	[self.serverSocket acceptOnPort:6543 error:&error];
//	NSLog(@"error,%@",error);
//	
//	self.tunnelArray = [NSMutableArray new];
}

//- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
//{
//	GCDTCPSocket *socket = [[GCDTCPSocket alloc] initWithClientSocket:newSocket];
//	HttpLocalSocket *httpLocalSocket = [[HttpLocalSocket alloc] initWithSocket:socket];
//	Tunnel *tunnel = [[Tunnel alloc] initWithLocalSocket:httpLocalSocket];
//	[self.tunnelArray addObject:tunnel];
//	[tunnel openTunnel];
////	ProxySocket *proxySocket = [[ProxySocket alloc] initWithClientSocket:newSocket];
////	[self.allConnectedSockets addObject:proxySocket];
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//{
//	
//}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
