//
//  LocalServer.m
//  httpProxy
//
//  Created by scorpio on 2017/3/22.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "LocalServer.h"

@interface LocalServer ()
@property (nonatomic, strong) NSMutableArray<Tunnel *> *tunnelArray;
@end

@implementation LocalServer

- (instancetype)initWithIpAddress:(NSString *)ipAddress port:(uint16_t)port {
	self = [super init];
	if (self) {
		self.ipAddress = ipAddress;
		self.port = port;
		self.tunnelArray = [NSMutableArray new];
	}
	return self;
}

- (void)start{
	
}

- (void)stop{
	for(Tunnel *tunnel in self.tunnelArray){
		[tunnel forceClose];
	}
}

- (void)didAcceptNewSocket:(LocalSocket *)localSocket{
	Tunnel *tunnel = [[Tunnel alloc] initWithLocalSocket:localSocket];
	tunnel.tunnelDelegate = self;
	[self.tunnelArray addObject:tunnel];
	[tunnel openTunnel];
}

- (void)tunnelDidClose:(Tunnel *)tunnel
{
	[self.tunnelArray removeObject:tunnel];
}

@end
