//
//  GCDTCPSocket.h
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>
#import "RawTCPSocketProtocol.h"

@interface GCDTCPSocket : NSObject<GCDAsyncSocketDelegate,RawTCPSocketProtocol>
@property (nonatomic, weak) id<RawTCPSocketDelegate> delegate;
@property (nonatomic, assign) BOOL isConnected;
- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket;
@end
