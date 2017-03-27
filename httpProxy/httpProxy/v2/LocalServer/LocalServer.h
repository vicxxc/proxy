//
//  LocalServer.h
//  httpProxy
//
//  Created by scorpio on 2017/3/22.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalSocket.h"
#import "Tunnel.h"

@interface LocalServer : NSObject<TunnelDelegate>
@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic, assign) uint16_t	port;

- (instancetype)initWithIpAddress:(NSString *)ipAddress port:(uint16_t)port;
- (void)start;
- (void)stop;
- (void)didAcceptNewSocket:(LocalSocket *)localSocket;
@end
