//
//  LocalSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "LocalSocket.h"

@interface LocalSocket()

@end

@implementation LocalSocket
@synthesize status = _status;
- (instancetype)initWithSocket:(id<RawTCPSocketProtocol>)socket
{
	self = [super init];
	if (self) {
		self.socket = socket;
		self.socket.delegate = self;
	}
	return self;
}

- (void)openSocket
{
	
}

- (void)respondToRemoteSocket:(RemoteSocket *)remoteSocket
{
	
}

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

- (void)didReadData:(NSData *)data from:(id<RawTCPSocketProtocol>)socket
{
	
}

- (void)didWriteData:(NSData *)data by:(id<RawTCPSocketProtocol>)socket
{
	
}

- (void)didConnectWithSocket:(id<RawTCPSocketProtocol>)socket
{
	
}

@end
