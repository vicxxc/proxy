//
//  Tunnel.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "Tunnel.h"
#import "DirectRemoteSocket.h"
#import "AdapterFactory.h"

@interface Tunnel () <socketDelegate>
@property (nonatomic, strong) LocalSocket *localSocket;
@property (nonatomic, strong) RemoteSocket *remoteSocket;
@property (nonatomic, assign) BOOL isClosed;
@property (nonatomic, assign) NSInteger readySignal;
@end

@implementation Tunnel

//- (NSString *)description
//{
//	return [NSString stringWithFormat:@"这是个%@",@"Tunnel"];
//}

- (instancetype)initWithLocalSocket:(LocalSocket *)localSocket
{
	self = [super init];
	if (self) {
		self.localSocket = localSocket;
		self.localSocket.delegate = self;
		self.status = TunnelStatusInvalid;
		self.readySignal = 0;
	}
	return self;
}

//- (BOOL)isClosed
//{
//	
//}

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
	self.remoteSocket = [[[DirectAdapterFactory alloc] init] getAdapterForSession:session];
	self.remoteSocket.remoteSocketDelegate = self;
	[self.remoteSocket openSocketWithSession:session];
}

- (void)didBecomeReadyToForwardWithSocket:(SocketProtocol *)socket
{
	self.readySignal += 1;
	if(self.readySignal == 2){
		self.status = TunnelStatusForwarding;
//		[self.remoteSocket ]
//		[self.localSocket ]
	}
//	[self.remoteSocket ]
}

- (void)didReadData:(NSData *)data from:(SocketProtocol *)socket
{
	
}

- (void)didWriteData:(NSData *)data by:(SocketProtocol *)socket
{
	
}


- (void)didDisconnectWithSocket:(SocketProtocol *)socket
{
	[self close];
	[self checkStatus];
}

- (void)checkStatus
{
	if(self.isClosed){
		self.status = TunnelStatusClosed;
		if (self.tunnelDelegate && [self.tunnelDelegate respondsToSelector:@selector(tunnelDidClose:)]) {
			[self.tunnelDelegate tunnelDidClose:self];
		}
	}
}

- (void)close
{
	self.status = TunnelStatusClosed;
	
}

- (void)forceClose
{
	self.status = TunnelStatusClosed;
}

@end
