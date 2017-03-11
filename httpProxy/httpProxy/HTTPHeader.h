//
//  HTTPHeader.h
//  httpProxy
//
//  Created by scorpio on 2017/3/2.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPHeader : NSObject
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, assign) BOOL isConnect;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, assign) NSInteger contentLength;
@property (nonatomic, strong) NSMutableArray *headers;

- (instancetype)initWithHeaderData:(NSData *)data;
@end
