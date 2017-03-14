//
//  SOCKSProxy.m
//  Tether
//
//  Created by Christopher Ballinger on 11/26/13.
//  Copyright (c) 2013 Christopher Ballinger. All rights reserved.
//

#import "SOCKSProxy.h"
#import "SOCKSProxySocket.h"

@interface SOCKSProxy()
@property (nonatomic, strong) GCDAsyncSocket *listeningSocket;
@property (nonatomic) dispatch_queue_t listeningQueue;
@property (nonatomic, strong) NSMutableSet *activeSockets;
//@property (nonatomic) NSUInteger totalBytesWritten;
//@property (nonatomic) NSUInteger totalBytesRead;
@property (nonatomic, strong) NSMutableDictionary *authorizedUsers;

@end

@implementation SOCKSProxy

- (void) dealloc {
    [self disconnect];
}

- (id) init {
    if (self = [super init]) {
        self.listeningQueue = dispatch_queue_create("SOCKS delegate queue", 0);
        self.callbackQueue = dispatch_get_main_queue();
        self.authorizedUsers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL) startProxy {
    return [self startProxyOnPort:9050];
}

- (BOOL) startProxyOnPort:(uint16_t)port {
    return [self startProxyOnPort:port error:nil];
}

- (BOOL) startProxyOnPort:(uint16_t)port error:(NSError**)error {
    [self disconnect];
    self.listeningSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.listeningQueue];
    self.activeSockets = [NSMutableSet set];
    _listeningPort = port;
    return [self.listeningSocket acceptOnPort:port error:error];
}

// SOCKS authorization
// btw this is horribly insecure, especially over the open internet
- (void) addAuthorizedUser:(NSString*)username password:(NSString*)password {
    [self.authorizedUsers setObject:password forKey:username];
}
- (void) removeAuthorizedUser:(NSString*)username {
    [self.authorizedUsers removeObjectForKey:username];
}
- (void) removeAllAuthorizedUsers {
    [self.authorizedUsers removeAllObjects];
}

- (BOOL) checkAuthorizationForUser:(NSString*)username password:(NSString*)password {
    NSString *existingPassword = [self.authorizedUsers objectForKey:username];
    if (!existingPassword.length) {
        return NO;
    }
    return [existingPassword isEqualToString:password];
}

- (void) socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Accepted new socket: %@", newSocket);
    ShadowSocksProxySocket *proxySocket = [[ShadowSocksProxySocket alloc] initWithSocket:newSocket];
//	SOCKSProxySocket *proxySocket = [[SOCKSProxySocket alloc] initWithSocket:newSocket delegate:self];
    [self.activeSockets addObject:proxySocket];
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(socksProxy:clientDidConnect:)]) {
//        dispatch_async(self.callbackQueue, ^{
//            [self.delegate socksProxy:self clientDidConnect:proxySocket];
//        });
//    }
}

- (NSUInteger) connectionCount {
    return _activeSockets.count;
}

- (void) disconnect {
    [self.activeSockets enumerateObjectsUsingBlock:^(ShadowSocksProxySocket *proxySocket, BOOL * _Nonnull stop) {
//        [proxySocket disconnect];
    }];
    self.activeSockets = nil;
    [self.listeningSocket disconnect];
    self.listeningSocket.delegate = nil;
    self.listeningSocket = nil;
}

//- (void) proxySocketDidDisconnect:(SOCKSProxySocket *)proxySocket withError:(NSError *)error {
//    dispatch_async(self.listeningQueue, ^{
//        [self.activeSockets removeObject:proxySocket];
//    });
//    if (self.delegate && [self.delegate respondsToSelector:@selector(socksProxy:clientDidDisconnect:)]) {
//        dispatch_async(self.callbackQueue, ^{
//            [self.delegate socksProxy:self clientDidDisconnect:proxySocket];
//        });
//    }
//}

//- (BOOL) proxySocket:(SOCKSProxySocket*)proxySocket
//checkAuthorizationForUser:(NSString*)username
//            password:(NSString*)password {
//    return [self checkAuthorizationForUser:username password:password];
//}
//
//- (void) resetNetworkStatistics {
//    self.totalBytesWritten = 0;
//    self.totalBytesRead = 0;
//}

@end
