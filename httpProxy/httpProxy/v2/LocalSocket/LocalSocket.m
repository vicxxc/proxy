//
//  LocalSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "LocalSocket.h"

@interface LocalSocket()<GCDAsyncSocketDelegate>

@end

@implementation LocalSocket

- (instancetype)initWithSocket:(GCDTCPSocket *)socket
{
	self = [super init];
	if (self) {
		self.socket = socket;
	}
	return self;
}

- (void)openSocket
{
	
}

@end
