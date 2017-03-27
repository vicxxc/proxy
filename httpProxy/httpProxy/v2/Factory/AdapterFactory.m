//
//  AdapterFactory.m
//  httpProxy
//
//  Created by scorpio on 2017/3/23.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "AdapterFactory.h"
#import "GCDTCPSocket.h"

@implementation AdapterFactory

- (RemoteSocket *)getAdapterForSession:(ConnectSession *)session
{
	return [self getDirectRemoteSocket];
}

- (RemoteSocket *)getDirectRemoteSocket
{
	DirectRemoteSocket *directRemoteSocket = [[DirectRemoteSocket alloc] init];
	directRemoteSocket.socket = [[GCDTCPSocket alloc] initWithClientSocket:nil];
	return directRemoteSocket;
}

@end

@implementation DirectAdapterFactory

@end
