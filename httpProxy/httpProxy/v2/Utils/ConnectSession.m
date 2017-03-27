//
//  ConnectSession.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "ConnectSession.h"

@implementation ConnectSession
- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port
{
	self = [super init];
	if (self) {
		self.host = host;
		self.port = port;
	}
	return self;
}

- (NSString *)ipAddress{
	if (!_ipAddress) {
		_ipAddress = self.host;
	}
	return _ipAddress;
}

- (void)disconnected:(NSError *)error
{
	
}

@end
