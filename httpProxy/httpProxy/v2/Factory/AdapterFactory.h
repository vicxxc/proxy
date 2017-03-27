//
//  AdapterFactory.h
//  httpProxy
//
//  Created by scorpio on 2017/3/23.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteSocket.h"
#import "DirectRemoteSocket.h"

@interface AdapterFactory : NSObject
- (RemoteSocket *)getAdapterForSession:(ConnectSession *)session;
@end

@interface DirectAdapterFactory : AdapterFactory

@end
