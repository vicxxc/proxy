//
//  GCDTCPSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "GCDTCPSocket.h"

@interface GCDTCPSocket()
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@end

@implementation GCDTCPSocket

- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket
{
	self = [super init];
	if (self) {
		if(clientSocket){
			self.clientSocket = clientSocket;
			self.clientSocket.delegate = self;
		}else{
			self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		}
	}
	return self;
}

- (BOOL)isConnected
{
	return !self.clientSocket.isDisconnected;
}

- (NSString *)sourceHost
{
	return self.clientSocket.localHost;
}

- (uint16_t)sourcePort
{
	return self.clientSocket.localPort;
}

- (NSString *)destinationHost
{
	return nil;
}

- (uint16_t)destinationPort
{
	return 0;
}

- (void)connectToHost:(NSString *)host onPort:(uint16_t)port
{
	NSError *error;
	[self.clientSocket connectToHost:host onPort:port error:&error];
}

- (void)disconnect
{
	[self.clientSocket disconnectAfterWriting];
}

- (void)forceDisconnect
{
	[self.clientSocket disconnect];
}

- (void)readData
{
	[self.clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)readDataToLength:(NSInteger)length
{
	[self.clientSocket readDataToLength:length withTimeout:-1 tag:0];
}

- (void)readDataTo:(NSData *)data
{
	[self.clientSocket readDataToData:data withTimeout:-1 tag:0];
}

- (void)writeData:(NSData *)data
{
	if([data length] > 0){
		if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteData:by:)]) {
			[self.delegate didWriteData:data by:self];
		}
	}
	[self.clientSocket writeData:data withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteData:by:)]) {
		[self.delegate didWriteData:nil by:self];
	}
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(didReadData:from:)]) {
		[self.delegate didReadData:data from:self];
	}
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(didDisconnectWithSocket:)]) {
		[self.delegate didDisconnectWithSocket:self];
	}
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(didConnectWithSocket:)]) {
		[self.delegate didConnectWithSocket:self];
	}
}

@end
