//
//  HTTPHeader.m
//  httpProxy
//
//  Created by scorpio on 2017/3/2.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "HTTPHeader.h"
#import <NSString+JKTrims.h>

NSString *const HTTPHeaderErrorDomain = @"com.FinalFantasy.HTTPHeader";
typedef NS_ENUM(NSUInteger, HTTPHeaderError) {
	HTTPHeaderMalformedHeader,
	HTTPHeaderInvalidRequestLine,
	HTTPHeaderInvalidHeaderField,
	HTTPHeaderInvalidConnectURL,
	HTTPHeaderInvalidConnectPort,
	HTTPHeaderInvalidURL,
	HTTPHeaderMissingHostField,
	HTTPHeaderInvalidHostField,
	HTTPHeaderInvalidHostPort,
	HTTPHeaderInvalidContentLength,
	HTTPHeaderIllegalEnco
};

@implementation HTTPHeader
- (instancetype)initWithHeaderData:(NSData *)data error:(NSError **)errPtr{
	self = [super init];
	if (self) {
		NSError *error;
		self.headers = [NSMutableArray new];
		NSString *headerString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		NSArray *lines = [headerString componentsSeparatedByString:@"\r\n"];
		if([lines count] < 3){
			error = [NSError errorWithDomain:HTTPHeaderErrorDomain code:HTTPHeaderMalformedHeader userInfo:nil];
			if (errPtr) *errPtr = error;
			return nil;
		}
		NSArray *request = [lines[0] componentsSeparatedByString:@" "];
		if([request count] != 3){
			error = [NSError errorWithDomain:HTTPHeaderErrorDomain code:HTTPHeaderInvalidRequestLine userInfo:nil];
			if (errPtr) *errPtr = error;
			return nil;
		}
		self.method = request[0];
		self.path = request[1];
		self.version = request[2];
		
		for (int i = 1 ; i < [lines count]-2; i++) {
			NSArray *tmp_headers = [self splitStringMaxSplit1:lines[i] separator:@":"];
			if([tmp_headers count] != 2){
				error = [NSError errorWithDomain:HTTPHeaderErrorDomain code:HTTPHeaderInvalidHeaderField userInfo:nil];
				if (errPtr) *errPtr = error;
				return nil;
			}
			
			[self.headers addObject:@{@"key":[tmp_headers[0] jk_trimmingWhitespace],@"value":[tmp_headers[1] jk_trimmingWhitespace]}];
		}
		
		if([[self.method uppercaseString] isEqualToString:@"CONNECT"]){
			self.isConnectMethod = YES;
			NSArray *urlInfo = [self.path componentsSeparatedByString:@":"];
			if([urlInfo count] != 2){
				error = [NSError errorWithDomain:HTTPHeaderErrorDomain code:HTTPHeaderInvalidConnectURL userInfo:nil];
				if (errPtr) *errPtr = error;
				return nil;
			}
			self.host = urlInfo[0];
			self.port = [urlInfo[1] integerValue];
			self.contentLength = 0;
		}else{
			NSURL *urlInfo = [[NSURL alloc] initWithString:self.path];
			if(urlInfo.host){
				self.host = urlInfo.host;
				self.port = [urlInfo.port integerValue]?[urlInfo.port integerValue]:80;
			}else{
				 NSAssert(0 != 1, @"url为空");
			}
			[self.headers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				if([obj[@"key"] isEqualToString:@"Content-Length"]){
					self.contentLength = [obj[@"value"] integerValue];
				}
			}];
		}

	}
	return self;
}

- (void)removeProxyHeader
{
	NSArray *toRemoveHeader = @[@"Proxy-Authenticate", @"Proxy-Authorization", @"Proxy-Connection"];
	for (NSString *header in toRemoveHeader) {
		for(id obj in self.headers){
			if([[obj[@"key"] lowercaseString] isEqualToString:[header lowercaseString]]){
				[self.headers removeObject:obj];
			}
		}
	}
}

- (NSData *)toData
{
	NSMutableString *header = [NSMutableString new];
	[header appendFormat:@"%@ %@ %@\r\n",self.method,self.path,self.version];
	for(id obj in self.headers){
		[header appendString:[NSString stringWithFormat:@"%@: %@\r\n",obj[@"key"],obj[@"value"]]];
	}
	[header appendString:@"\r\n"];
	return [header dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSMutableArray *)splitStringMaxSplit1:(NSString *)sourcestring separator:(NSString *)separator
{
	NSArray *array = [sourcestring componentsSeparatedByString:separator];
	NSMutableArray *mutableArray = [array mutableCopy];
	if([array count]<=2){
		return mutableArray;
	}else{
		[mutableArray removeObjectAtIndex:0];
		NSString *firstString = array[0];
		NSString *secondString = [mutableArray componentsJoinedByString:separator];
		return [[NSMutableArray alloc] initWithObjects:firstString,secondString, nil];
	}
}
@end
