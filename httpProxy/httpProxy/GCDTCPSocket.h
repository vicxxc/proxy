//
//  GCDTCPSocket.h
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>

@class GCDTCPSocket;
@protocol RawTCPSocketDelegate  <NSObject>
- (void)socket:(GCDTCPSocket *)sock didReadData:(NSData *)data;
@end

@interface GCDTCPSocket : NSObject
@property (nonatomic, weak) id<RawTCPSocketDelegate> delegate;

- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket;
- (void)readData;
- (void)readDataToData:(NSData *)data;
@end
