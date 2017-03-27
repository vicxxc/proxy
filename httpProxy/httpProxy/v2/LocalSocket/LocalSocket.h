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
#import "RawTCPSocketProtocol.h"

@class RemoteSocket;
@protocol SocketProtocol;
@protocol socketDelegate;
@interface LocalSocket : NSObject<SocketProtocol,RawTCPSocketDelegate>
@property (nonatomic, strong) ConnectSession *session;
@property (nonatomic, strong) id<RawTCPSocketProtocol> socket;
@property (nonatomic, weak) id<socketDelegate> delegate;
- (instancetype)initWithSocket:(id<RawTCPSocketProtocol>)socket;
- (void)openSocket;
- (void)respondToRemoteSocket:(RemoteSocket *)remoteSocket;
@end
