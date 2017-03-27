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

typedef NS_ENUM(NSUInteger, HTTPStreamScannerReadStatus) {
	HTTPStreamScannerReadHeader,
	HTTPStreamScannerReadContent,
	HTTPStreamScannerStop
};

@class HTTPStreamScannerResult;
@interface HTTPStreamScanner : NSObject
@property (nonatomic, assign) HTTPStreamScannerReadStatus readStatus;
- (HTTPStreamScannerResult *)analysis:(NSData *)data error:(NSError **)errPtr;
@end

@interface HTTPStreamScannerResult : NSObject
@property (nonatomic, assign) HTTPStreamScannerResultType resultType;
@property (nonatomic, strong) id resultData;
@end
