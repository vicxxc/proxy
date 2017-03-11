//
//  ProxySocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/3.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "ProxySocket.h"
#import "HTTPHeader.h"
#import "RequestSocket.h"

@interface ProxySocket()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@property (nonatomic, strong) RequestSocket *requestSocket;
@property (nonatomic, strong) NSMutableData *toSendData;
@end

@implementation ProxySocket

- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket{
	self = [super init];
	if (self) {
		self.clientSocket = clientSocket;
		self.clientSocket.delegate = self;
		self.toSendData = [NSMutableData new];
		[self.clientSocket readDataWithTimeout:-1 tag:0];
	}
	return self;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	[self.toSendData appendData:data];
	WEAKSELF(ws);
	self.requestSocket = [[RequestSocket alloc] initWithData:data];
	self.requestSocket.request_didReadData = ^(GCDAsyncSocket *socket,NSData *data,long tag){
		[ws.clientSocket writeData:data withTimeout:-1 tag:0];
	};
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	
}

@end
