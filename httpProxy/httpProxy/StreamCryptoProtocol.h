//
//  StreamCryptoProtocol.h
//  httpProxy
//
//  Created by scorpio on 2017/3/15.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StreamCryptoProtocol <NSObject>

- (NSData *)update: (NSData *)data;

@end
