//
//  SOCKS5LocalSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/30.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "SOCKS5LocalSocket.h"

typedef NS_ENUM(NSUInteger, SOCKS5LocalSocketReadStatus) {
	SOCKS5LocalSocketReadInvalid,
	SOCKS5LocalSocketReadVersionIdentifierAndNumberOfMethods,
	SOCKS5LocalSocketReadMethods,
	SOCKS5LocalSocketReadConnectHeader,
	SOCKS5LocalSocketReadIPv4Address,
	SOCKS5LocalSocketReadDomainLength,
	SOCKS5LocalSocketReadDomain,
	SOCKS5LocalSocketReadIPv6Address,
	SOCKS5LocalSocketReadPort,
	SOCKS5LocalSocketReadForwarding,
	SOCKS5LocalSocketReadStopped
};

typedef NS_ENUM(NSUInteger, SOCKS5LocalSocketWriteStatus) {
	SOCKS5LocalSocketWriteInvalid,
	SOCKS5LocalSocketWriteSendingResponse,
	SOCKS5LocalSocketWriteForwarding,
	SOCKS5LocalSocketWriteStopped
};

@interface SOCKS5LocalSocket()
@property (nonatomic, assign) SOCKS5LocalSocketReadStatus socks5LocalSocketReadStatus;
@property (nonatomic, assign) SOCKS5LocalSocketWriteStatus socks5LocalSocketWriteStatus;
@end


@implementation SOCKS5LocalSocket

- (void)openSocket
{
	[super openSocket];
	self.socks5LocalSocketReadStatus = SOCKS5LocalSocketReadVersionIdentifierAndNumberOfMethods;
	[self.socket readDataToLength:2];
}

- (void)didReadData:(NSData *)data from:(id<RawTCPSocketProtocol>)socket
{
	
}

@end
