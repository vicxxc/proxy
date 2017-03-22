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

@protocol socketDelegate;
@interface RemoteSocket : NSObject
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, weak) id<socketDelegate> remoteSocketDelegate;
- (void)openSocketWithSession:(ConnectSession *)session;
@end
