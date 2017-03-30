//
//  GCDSOCKS5LocalServer.m
//  httpProxy
//
//  Created by scorpio on 2017/3/30.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "GCDSOCKS5LocalServer.h"
#import "SOCKS5LocalSocket.h"

@implementation GCDSOCKS5LocalServer

- (void)handleNewGCDSocket:(GCDTCPSocket *)socket
{
	SOCKS5LocalSocket *socks5LocalSocket = [[SOCKS5LocalSocket alloc] initWithSocket:socket];
	[self didAcceptNewSocket:socks5LocalSocket];
}

@end
