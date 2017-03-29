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

- (void)didBecomeReadyToForwardWithSocket:(id<SocketProtocol>)socket
{
	self.readySignal += 1;
	if(self.readySignal == 2){
		self.status = TunnelStatusForwarding;
		[self.remoteSocket readData];
		[self.localSocket readData];
	}
	if([socket isKindOfClass:[RemoteSocket class]]){
		[self.localSocket respondToRemoteSocket:(RemoteSocket *)socket];
	}
}

- (void)didReadData:(NSData *)data from:(id<SocketProtocol>)socket
{
	if([socket isKindOfClass:[LocalSocket class]]){
		[self.remoteSocket writeData:data];
	}else if([socket isKindOfClass:[RemoteSocket class]]){
		[self.localSocket writeData:data];
	}
}

- (void)didWriteData:(NSData *)data by:(id<SocketProtocol>)socket
{
	if([socket isKindOfClass:[LocalSocket class]]){
		WEAKSELF(ws);
		// 延迟50ms
		dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((50/1000.0f) * NSEC_PER_SEC));
		
		dispatch_after(delayTime, dispatch_get_main_queue(), ^{
			[ws.remoteSocket readData];
		});
	}else if([socket isKindOfClass:[RemoteSocket class]]){
		[self.localSocket readData];
	}
}

- (void)didReceiveSession:(ConnectSession *)session localSocket:(LocalSocket *)localSocket
{
	self.status = TunnelStatusWaitingToBeReady;
	session.ipAddress = session.host;
	[self openAdapter:session];
}

- (void)openAdapter:(ConnectSession *)session
{
	self.remoteSocket = [[[DirectAdapterFactory alloc] init] getAdapterForSession:session];
	self.remoteSocket.delegate = self;
	[self.remoteSocket openSocketWithSession:session];
}

- (void)didConnectToRemoteSocket:(RemoteSocket *)remoteSocket
{
	
}

- (void)didDisconnectWithSocket:(SocketProtocol *)socket
{
	[self close];
	[self checkStatus];
}

- (void)updateAdapterWithRemoteSocket:(RemoteSocket *)remoteSocket
{
	
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
