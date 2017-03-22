//
//  Tunnel.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "Tunnel.h"
#import "HttpRemoteSocket.h"

@implementation Tunnel

- (NSString *)description
{
	return [NSString stringWithFormat:@"这是个%@",@"Tunnel"];
}

- (instancetype)initWithLocalSocket:(LocalSocket *)localSocket
{
	self = [super init];
	if (self) {
		self.localSocket = localSocket;
		self.localSocket.socketDelegate = self;
		self.status = TunnelStatusInvalid;
	}
	return self;
}

- (void)openTunnel
{
	self.status = TunnelStatusReadingRequest;
	[self.localSocket openSocket];
}

- (void)socket:(LocalSocket *)sock didReceive:(ConnectSession *)session
{
	session.ipAddress = session.host;
	[self openAdapter:session];
}

- (void)openAdapter:(ConnectSession *)session
{
	self.remoteSocket  = [HttpRemoteSocket alloc];
	self.remoteSocket.remoteSocketDelegate = self;
	[self.remoteSocket openSocketWithSession:session];
}

- (void)forceClose
{
	
}

- (void)didConnectToSocket:(RemoteSocket *)socket
{
	
}

- (void)didBecomeReadyToForwardWith:(RemoteSocket *)socket
{
	
}







@end
