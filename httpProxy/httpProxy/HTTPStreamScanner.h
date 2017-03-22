//
//  HTTPStreamScanner.h
//  httpProxy
//
//  Created by scorpio on 2017/3/20.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTTPStreamScannerResultType) {
	HTTPStreamScannerResultHeader,
	HTTPStreamScannerResultContent
};

@class HTTPStreamScannerResult;
@interface HTTPStreamScanner : NSObject
- (HTTPStreamScannerResult *)analysis:(NSData *)data error:(NSError **)errPtr;
@end

@interface HTTPStreamScannerResult : NSObject
@property (nonatomic, assign) HTTPStreamScannerResultType resultType;
@property (nonatomic, strong) id resultData;
@end
