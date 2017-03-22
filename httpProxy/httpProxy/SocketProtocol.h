//
//  SocketProtocol.h
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalSocket.h"
#import "RemoteSocket.h"

@protocol SocketProtocol <NSObject>

@end

@class LocalSocket;
@class RemoteSocket;
@protocol socketDelegate <NSObject>
- (void)socket:(LocalSocket *)sock didReceive:(ConnectSession *)session;
- (void)didConnectToSocket:(RemoteSocket *)socket;
- (void)didBecomeReadyToForwardWith:(RemoteSocket *)socket;
@end
