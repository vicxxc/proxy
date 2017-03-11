//
//  RequestSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/6.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "RequestSocket.h"
#import "HTTPHeader.h"

@interface RequestSocket()<GCDAsyncSocketDelegate>
//@property (nonatomic, strong) ProxySocket *proxySocket;
@property (nonatomic, strong) GCDAsyncSocket *requestSocket;
@property (nonatomic, strong) NSData *toSendData;
@property (nonatomic, strong) HTTPHeader *header;
@end

@implementation RequestSocket

- (instancetype)initWithData:(NSData *)data{
	if (self) {
		self.requestSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		self.requestSocket.delegate = self;
		self.header = [[HTTPHeader alloc] initWithHeaderData:data];
		NSError *error;
		[self.requestSocket connectToHost:self.header.host onPort:self.header.port error:&error];
		self.toSendData = data;
	}
	return self;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if(self.request_didReadData){
		self.request_didReadData(sock, data, tag);
	}
	[self.requestSocket readDataWithTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
	NSLog(@"HTTP请求Url=>%@",self.header.path);
	[self.requestSocket writeData:self.toSendData withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	[self.requestSocket readDataWithTimeout:-1 tag:0];
}

@end
