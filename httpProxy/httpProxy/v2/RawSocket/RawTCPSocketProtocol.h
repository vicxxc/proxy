//
//  RawTCPSocketProtocol.h
//  httpProxy
//
//  Created by scorpio on 2017/3/23.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RawTCPSocketDelegate;
@protocol RawTCPSocketProtocol <NSObject>
@property (nonatomic, weak) id<RawTCPSocketDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, strong, readonly) NSString *sourceHost;
@property (nonatomic, assign, readonly) uint16_t sourcePort;
@property (nonatomic, strong, readonly) NSString *destinationHost;
@property (nonatomic, assign, readonly) uint16_t destinationPort;
- (void)connectToHost:(NSString *)host onPort:(uint16_t)port;
- (void)disconnect;
- (void)forceDisconnect;
- (void)readData;
- (void)readDataTo:(NSData *)data;
- (void)writeData:(NSData *)data;
@end

@protocol RawTCPSocketDelegate <NSObject>
- (void)didDisconnectWithSocket:(id<RawTCPSocketProtocol>)socket;
- (void)didConnectWithSocket:(id<RawTCPSocketProtocol>)socket;
- (void)didReadData:(NSData *)data from:(id<RawTCPSocketProtocol>)socket;
- (void)didWriteData:(NSData *)data by:(id<RawTCPSocketProtocol>)socket;
@end
