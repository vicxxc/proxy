//
//  HttpRemoteSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "DirectRemoteSocket.h"

//typedef NS_ENUM(NSUInteger, DirectRemoteSocketStatus) {
//	HttpRemoteSocketInvalid,
//	HttpRemoteSocketConnecting,
//	HttpRemoteSocketReadingResponse,
//	HttpRemoteSocketForwarding,
//	HttpRemoteSocketStopped
//};

@interface DirectRemoteSocket()
//@property (nonatomic, strong) NSString *serverHost;
//@property (nonatomic, assign) uint16_t serverPort;
//@property (nonatomic, assign) DirectRemoteSocketStatus status;
@end

@implementation DirectRemoteSocket
//- (instancetype)initWithServerHost:(NSString *)serverHost serverPort:(uint16_t)serverPort{
//	self = [super init];
//	if (self) {
//		self.serverHost = self.serverHost;
//		self.serverPort = self.serverPort;
//	}
//	return self;
//}
- (void)openSocketWithSession:(ConnectSession *)session
{
	[super openSocketWithSession:session];
//	self.status = HttpRemoteSocketConnecting;
//	[self.socket connectToHost:self.serverHost onPort:self.serverPort];
//	[self.socket connectToHost:session.host onPort:session.port];
}

- (void)didConnectToSocket:(RemoteSocket *)socket
{
//	[super didConnectToSocket:socket];
//	[self.remoteSocketDelegate didBecomeReadyToForwardWithSocket:<#(SocketProtocol *)#>]
}

@end
