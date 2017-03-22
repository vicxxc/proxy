//
//  HttpRemoteSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "HttpRemoteSocket.h"

typedef NS_ENUM(NSUInteger, HttpRemoteSocketStatus) {
	HttpRemoteSocketInvalid,
	HttpRemoteSocketConnecting,
	HttpRemoteSocketReadingResponse,
	HttpRemoteSocketForwarding,
	HttpRemoteSocketStopped
};

@interface HttpRemoteSocket()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) NSString *serverHost;
@property (nonatomic, assign) NSInteger serverPort;
@property (nonatomic, assign) HttpRemoteSocketStatus status;
@end

@implementation HttpRemoteSocket
- (void)openSocketWithSession:(ConnectSession *)session
{
	[super openSocketWithSession:session];
	self.status = HttpRemoteSocketConnecting;
	self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	NSError *error;
	[self.socket connectToHost:session.host onPort:session.port error:&error];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
	if (self.remoteSocketDelegate && [self.remoteSocketDelegate respondsToSelector:@selector(didConnectToSocket:)]) {
		[self.remoteSocketDelegate didConnectToSocket:self];
	}
	if (self.remoteSocketDelegate && [self.remoteSocketDelegate respondsToSelector:@selector(didBecomeReadyToForwardWith:)]) {
		[self.remoteSocketDelegate didBecomeReadyToForwardWith:self];
	}
}
@end
