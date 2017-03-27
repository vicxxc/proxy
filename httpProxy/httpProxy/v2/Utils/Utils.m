//
//  Utils.m
//  httpProxy
//
//  Created by scorpio on 2017/3/20.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "Utils.h"

@implementation HTTPData

- (instancetype)init {
	self = [super init];
	if (self) {
		self.DoubleCRLF = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
		self.ConnectSuccessResponse = [@"HTTP/1.1 200 Connection Established\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
	}
	return self;
}
@end

@implementation Utils

- (instancetype)init {
	self = [super init];
	if (self) {
		self.HTTPData = [[HTTPData alloc] init];
	}
	return self;
}
@end
