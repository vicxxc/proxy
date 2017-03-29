//
//  HttpRemoteSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "DirectRemoteSocket.h"

@interface DirectRemoteSocket()
@end

@implementation DirectRemoteSocket

- (void)openSocketWithSession:(ConnectSession *)session
{
	[super openSocketWithSession:session];
	[self.socket connectToHost:session.host onPort:session.port];
}

- (void)didConnectWithSocket:(id<RawTCPSocketProtocol>)socket
{
	[super didConnectWithSocket:socket];
	if (self.delegate && [self.delegate respondsToSelector:@selector(didBecomeReadyToForwardWithSocket:)]) {
		[self.delegate didBecomeReadyToForwardWithSocket:self];
	}
}

- (void)didReadData:(NSData *)data from:(id<RawTCPSocketProtocol>)socket
{
	[super didReadData:data from:socket];
	if (self.delegate && [self.delegate respondsToSelector:@selector(didReadData:from:)]) {
		[self.delegate didReadData:data from:self];
	}
}

- (void)didWriteData:(NSData *)data by:(id<RawTCPSocketProtocol>)socket
{
	[super didWriteData:data by:socket];
	if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteData:by:)]) {
		[self.delegate didWriteData:data by:self];
	}
}

@end
