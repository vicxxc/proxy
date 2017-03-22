//
//  LocalSocket.h
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>
#import "GCDTCPSocket.h"
#import "ConnectSession.h"
#import "SocketProtocol.h"

@protocol socketDelegate;
@interface LocalSocket : NSObject
@property (nonatomic, strong) GCDTCPSocket *socket;
@property (nonatomic, weak) id<socketDelegate> socketDelegate;
- (instancetype)initWithSocket:(GCDTCPSocket *)socket;
- (void)openSocket;
@end
