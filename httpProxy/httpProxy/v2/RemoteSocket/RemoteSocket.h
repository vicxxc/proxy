//
//  RemoteSocket.h
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectSession.h"
#import <GCDAsyncSocket.h>
#import "SocketProtocol.h"
#import "GCDTCPSocket.h"

@protocol SocketProtocol;
@protocol socketDelegate;
@interface RemoteSocket : NSObject<SocketProtocol,RawTCPSocketDelegate>
@property (nonatomic, strong) ConnectSession *session;
@property (nonatomic, strong) id<RawTCPSocketProtocol> socket;
@property (nonatomic, weak) id<socketDelegate> delegate;
- (void)openSocketWithSession:(ConnectSession *)session;
- (void)didConnectWithSocket:(id<RawTCPSocketProtocol>)socket;
- (void)didReadData:(NSData *)data from:(id<RawTCPSocketProtocol>)socket;
- (void)didWriteData:(NSData *)data by:(id<RawTCPSocketProtocol>)socket;
@end
