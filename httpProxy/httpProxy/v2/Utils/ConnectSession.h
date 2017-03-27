//
//  ConnectSession.h
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectSession : NSObject
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic, assign) NSInteger port;
- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port;
- (void)disconnected:(NSError *)error;
@end
