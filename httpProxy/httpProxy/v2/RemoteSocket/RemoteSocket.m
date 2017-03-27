//
//  RemoteSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "RemoteSocket.h"

@interface RemoteSocket()<SocketProtocol,RawTCPSocketDelegate>
@end

@implementation RemoteSocket
- (void)openSocketWithSession:(ConnectSession *)session
{
	self.session = session;
	self.socket.delegate = self;
	self.status = SocketConnecting;	
}

- (void)didConnectWithsocket:(GCDTCPSocket *)sock
{
	self.status = SocketEstablished;
//	if (self.remoteSocketDelegate && [self.remoteSocketDelegate respondsToSelector:@selector(didConnectToRemoteSocket:)]) {
//		[self.remoteSocketDelegate didConnectToRemoteSocket:socket];
//	}
}

@end
