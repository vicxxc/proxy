//
//  Utils.h
//  httpProxy
//
//  Created by scorpio on 2017/3/20.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPData : NSObject
@property (nonatomic, strong) NSData *DoubleCRLF;
@end

@interface Utils : NSObject
@property (nonatomic, strong) HTTPData *HTTPData;
@end
