//
//  RemoteSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "RemoteSocket.h"

@interface RemoteSocket()
@end

@implementation RemoteSocket

@synthesize status = _status;

- (void)openSocketWithSession:(ConnectSession *)session
{
	self.session = session;
	self.socket.delegate = self;
	self.status = SocketConnecting;
}
//
//- (void)respondToRemoteSocket:(RemoteSocket *)remoteSocket
//{
//	
//}

- (void)readData
{
	[self.socket readData];
}

- (void)writeData:(NSData *)data
{
	[self.socket writeData:data];
}

- (void)disconnectOf:(NSError *)error
{
	self.status = SocketDisconnecting;
	[self.session disconnected:error];
	[self.socket disconnect];
}

- (void)forceDisconnect:(NSError *)error
{
	self.status = SocketDisconnecting;
	[self.session disconnected:error];
	[self.socket forceDisconnect];
}

- (void)didDisconnectWithSocket:(id<RawTCPSocketProtocol>)socket
{
	self.status = SocketClosed;
	if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectWithSocket:)]) {
		[self.delegate didDisconnectWithSocket:self];
	}
}

- (void)didConnectWithSocket:(id<RawTCPSocketProtocol>)socket
{
	self.status = SocketEstablished;
	if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectToRemoteSocket:)]) {
		[self.delegate didConnectToRemoteSocket:self];
	}
}

- (void)didReadData:(NSData *)data from:(id<RawTCPSocketProtocol>)socket
{
	
}

- (void)didWriteData:(NSData *)data by:(id<RawTCPSocketProtocol>)socket
{
	
}

@end
