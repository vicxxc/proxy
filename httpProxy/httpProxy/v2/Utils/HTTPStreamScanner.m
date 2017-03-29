//
//  HTTPStreamScanner.m
//  httpProxy
//
//  Created by scorpio on 2017/3/20.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "HTTPStreamScanner.h"
#import "HTTPHeader.h"

@implementation HTTPStreamScannerResult

@end

@interface HTTPStreamScanner()
@property (nonatomic, strong) HTTPHeader *httpHeader;
@property (nonatomic, assign) BOOL isConnect;
@property (nonatomic, assign) NSInteger remainContentLength;
@end

@implementation HTTPStreamScanner

- (id)init
{
	self = [super init];
	if (self) {
		self.readStatus = HTTPStreamScannerReadHeader;
	}
	return self;
}

- (HTTPStreamScannerResult *)analysis:(NSData *)data error:(NSError **)errPtr
{
	HTTPStreamScannerResult *result = [HTTPStreamScannerResult new];
	NSError *analysisError = [NSError errorWithDomain:@"error" code:-1 userInfo:nil];
	switch (self.readStatus) {
		case HTTPStreamScannerReadHeader:
		{
			NSError *error;
			HTTPHeader *header = [[HTTPHeader alloc] initWithHeaderData:data error:&error];
			if(error){
				self.readStatus = HTTPStreamScannerStop;
				if (errPtr) *errPtr = analysisError;
				return result;
			}
			if(!self.httpHeader){
				if(header.isConnectMethod){
					self.isConnect = YES;
					self.remainContentLength = -1;
				}else{
					self.isConnect = NO;
					self.remainContentLength = header.contentLength;
				}
			}else{
				self.remainContentLength = header.contentLength;
			}
			self.httpHeader = header;
			[self setNextAction];
			result.resultData = header;
			result.resultType = HTTPStreamScannerResultHeader;
			return result;
		}
			break;
		case HTTPStreamScannerReadContent:
		{
			self.remainContentLength -= data.length;
			if (!self.isConnect && self.remainContentLength < 0) {
				self.readStatus = HTTPStreamScannerStop;
				return result;
			}
			
			[self setNextAction];
			result.resultData = data;
			result.resultType = HTTPStreamScannerResultContent;
			return result;
		}
		default:
			return result;
			break;
	}
}

- (void)setNextAction
{
	if(self.remainContentLength == 0){
		self.readStatus = HTTPStreamScannerReadHeader;
	}else if(self.remainContentLength < 0){
		self.readStatus = HTTPStreamScannerReadContent;
	}else if(self.remainContentLength > 0){
		self.readStatus = HTTPStreamScannerReadContent;
	}
}
@end
