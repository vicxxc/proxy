//
//  ProxySocket.h
//  httpProxy
//
//  Created by scorpio on 2017/3/3.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>

@interface ProxySocket : NSObject

- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket;

@end
