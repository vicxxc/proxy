//
//  GCDHTTPLocalServer.m
//  httpProxy
//
//  Created by scorpio on 2017/3/22.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "GCDHTTPLocalServer.h"
#import "HttpLocalSocket.h"

@implementation GCDHTTPLocalServer

- (void)handleNewGCDSocket:(GCDTCPSocket *)socket
{
	HttpLocalSocket *httpLocalSocket = [[HttpLocalSocket alloc] initWithSocket:socket];
	DDLogVerbose(@"handleNewGCDHttpSocket");
	[self didAcceptNewSocket:httpLocalSocket];
}

@end
