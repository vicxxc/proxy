//
//  GCDLocalServer.h
//  httpProxy
//
//  Created by scorpio on 2017/3/22.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "LocalServer.h"
#import "GCDTCPSocket.h"
#import <GCDAsyncSocket.h>

@interface GCDLocalServer : LocalServer
- (void)handleNewGCDSocket:(GCDTCPSocket *)socket;
@end
