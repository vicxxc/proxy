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
//#import "RawTCPSocketProtocol.h"

typedef NS_ENUM(NSUInteger, SocketStatus) {
	SocketInvalid,
	SocketConnecting,
	SocketEstablished,
	SocketDisconnecting,
	SocketClosed
};

@protocol socketDelegate;
@protocol SocketProtocol <NSObject>
@property (nonatomic, strong) id<RawTCPSocketProtocol> socket;
@property (nonatomic, weak) id<socketDelegate> delegate;
@property (nonatomic, assign) SocketStatus status;
//@property (nonatomic, assign) BOOL isDisconnected;
//@property (nonatomic, strong) NSString *typeName;
- (void)readData;
- (void)writeData:(NSData *)data;
- (void)disconnectOf:(NSError *)error;
- (void)forceDisconnect:(NSError *)error;
@end


@class LocalSocket;
@class RemoteSocket;
@class SocketProtocol;
@protocol socketDelegate <NSObject>
- (void)didConnectToRemoteSocket:(RemoteSocket *)remoteSocket;
- (void)didDisconnectWithSocket:(id<SocketProtocol>)socket;
- (void)didReadData:(NSData *)data from:(id<SocketProtocol>)socket;
- (void)didWriteData:(NSData *)data by:(id<SocketProtocol>)socket;
- (void)didReceiveSession:(ConnectSession *)session localSocket:(LocalSocket *)localSocket;
- (void)didBecomeReadyToForwardWithSocket:(id<SocketProtocol>)socket;
- (void)updateAdapterWithRemoteSocket:(RemoteSocket *)remoteSocket;
@end
