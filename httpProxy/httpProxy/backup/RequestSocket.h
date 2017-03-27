//
//  RequestSocket.h
//  httpProxy
//
//  Created by scorpio on 2017/3/6.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProxySocket.h"
#import <GCDAsyncSocket.h>

@interface RequestSocket : NSObject

@property (nonatomic, copy) void(^request_didReadData)(GCDAsyncSocket *socket,NSData *data,long tag);
- (instancetype)initWithData:(NSData *)data socket:(GCDAsyncSocket *)clientSocket;

@end
