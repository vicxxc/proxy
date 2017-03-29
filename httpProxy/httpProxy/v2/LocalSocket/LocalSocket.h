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
#import "SocketProtocol.h"

@class RemoteSocket;
@protocol socketDelegate;
@protocol SocketProtocol;
@interface LocalSocket : NSObject<SocketProtocol,RawTCPSocketDelegate>
@property (nonatomic, strong) ConnectSession *session;
@property (nonatomic, strong) id<RawTCPSocketProtocol> socket;
@property (nonatomic, weak) id<socketDelegate> delegate;
//@property (nonatomic, assign) SocketStatus status;
- (instancetype)initWithSocket:(id<RawTCPSocketProtocol>)socket;
- (void)openSocket;
- (void)respondToRemoteSocket:(RemoteSocket *)remoteSocket;
@end
