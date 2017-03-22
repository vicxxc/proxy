//
//  GCDTCPSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "GCDTCPSocket.h"

@interface GCDTCPSocket()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@end

@implementation GCDTCPSocket

- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket
{
	self = [super init];
	if (self) {
		self.clientSocket = clientSocket;
		self.clientSocket.delegate = self;
	}
	return self;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
	
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didReadData:)]) {
		[self.delegate socket:self didReadData:data];
	}
}

- (void)readData
{
	[self.clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)readDataToData:(NSData *)data
{
	[self.clientSocket readDataToData:data withTimeout:-1 tag:0];
}

@end
