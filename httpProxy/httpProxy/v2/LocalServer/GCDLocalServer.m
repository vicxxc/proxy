//
//  GCDLocalServer.m
//  httpProxy
//
//  Created by scorpio on 2017/3/22.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "GCDLocalServer.h"

@interface GCDLocalServer ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *localSocket;
@end

@implementation GCDLocalServer

- (void)start{
	self.localSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	self.localSocket.delegate = self;
	NSError *error;
	[self.localSocket acceptOnInterface:self.ipAddress port:self.port error:&error];
}

- (void)stop{
	[self.localSocket setDelegate:nil delegateQueue:nil];
	[self.localSocket disconnect];
	self.localSocket = nil;
	[super stop];
}

- (void)handleNewGCDSocket:(GCDTCPSocket *)socket
{
	
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	GCDTCPSocket *clientSocket = [[GCDTCPSocket alloc] initWithClientSocket:newSocket];
	[self handleNewGCDSocket:clientSocket];
}

@end
