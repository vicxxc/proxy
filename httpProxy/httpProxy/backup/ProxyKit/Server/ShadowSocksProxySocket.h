//
//  ShadowSocksProxySocket.h
//  httpProxy
//
//  Created by scorpio on 2017/3/10.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>

@interface ShadowSocksProxySocket : NSObject

- (id) initWithSocket:(GCDAsyncSocket*)socket;

@end
