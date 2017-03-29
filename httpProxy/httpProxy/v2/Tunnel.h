//
//  Tunnel.h
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalSocket.h"
#import "RemoteSocket.h"
#import "HttpLocalSocket.h"
#import "SocketProtocol.h"

typedef NS_ENUM(NSUInteger, TunnelStatus) {
	TunnelStatusInvalid,
	TunnelStatusReadingRequest,
	TunnelStatusWaitingToBeReady,
	TunnelStatusForwarding,
	TunnelStatusClosing,
	TunnelStatusClosed
};

@class Tunnel;
@protocol TunnelDelegate <NSObject>
- (void)tunnelDidClose:(Tunnel *)tunnel;
@end

@interface Tunnel : NSObject<socketDelegate>
@property (nonatomic, assign) TunnelStatus status;
@property (nonatomic, weak) id<TunnelDelegate> tunnelDelegate;

- (instancetype)initWithLocalSocket:(LocalSocket *)localSocket;
- (void)openTunnel;
- (void)forceClose;
@end
