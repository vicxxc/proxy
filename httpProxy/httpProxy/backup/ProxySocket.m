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
#import "HTTPStreamScanner.h"

typedef NS_ENUM(NSUInteger, HTTPProxyReadStatus) {
	HTTPProxyReadInvalid,
	HTTPProxyReadingFirstHeader,
	HTTPProxyToSendFirstHeader,
	HTTPProxyReadingHeader,
	HTTPProxyReadingContent,
	HTTPProxyReadStopped
};

typedef NS_ENUM(NSUInteger, HTTPProxyWriteStatus) {
	HTTPProxyWriteInvalid,
	HTTPProxyWriteConnectResponse,
	HTTPProxyWriteForwarding,
	HTTPProxyWriteStopped
};

@interface ProxySocket()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@property (nonatomic, strong) GCDAsyncSocket *requestSocket;
@property (nonatomic, strong) NSData *toSendData;
@property (nonatomic, strong) HTTPHeader *header;
@property (nonatomic, strong) HTTPStreamScanner *scanner;
@property (nonatomic, assign) HTTPProxyWriteStatus httpProxyWriteStatus;
@property (nonatomic, assign) HTTPProxyReadStatus httpProxyReadStatus;
@property (nonatomic, assign) BOOL isConnectMethod;
@end

@implementation ProxySocket

- (instancetype)initWithClientSocket:(GCDAsyncSocket *)clientSocket{
	self = [super init];
	if (self) {
		self.clientSocket = clientSocket;
		self.clientSocket.delegate = self;
		self.isConnectMethod = NO;
//		self.toSendData = [NSMutableData new];
//		[self.clientSocket readDataWithTimeout:-1 tag:0];
		self.httpProxyReadStatus = HTTPProxyReadingFirstHeader;
		self.scanner = [HTTPStreamScanner new];
		[self.clientSocket readDataToData:[@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
	}
	return self;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSError *error;
	HTTPStreamScannerResult *result = [self.scanner analysis:data error:&error];
	if(self.httpProxyReadStatus == HTTPProxyReadingFirstHeader){
//		self.header = [[HTTPHeader alloc] initWithHeaderData:data];
//		NSError *error;
		if(result.resultType == HTTPStreamScannerResultHeader){
			self.header = (HTTPHeader *)result.resultData;
		}
		self.isConnectMethod = self.header.isConnectMethod;
		self.requestSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		[self.requestSocket connectToHost:self.header.host onPort:self.header.port error:&error];
		self.toSendData = data;
		if(self.isConnectMethod){
			self.httpProxyReadStatus = HTTPProxyToSendFirstHeader;
		}else{
			self.httpProxyReadStatus = HTTPProxyReadingContent;
		}
//		self.header = [[HTTPHeader alloc] initWithHeaderData:data];
	}
	if(self.httpProxyReadStatus == HTTPProxyReadingContent){
		
	}
//	if(!self.requestSocket){
//		self.header = [[HTTPHeader alloc] initWithHeaderData:data];
//		NSError *error;
//		self.requestSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//		[self.requestSocket connectToHost:self.header.host onPort:self.header.port error:&error];
//		self.toSendData = data;
////		if(![self.header.method isEqualToString:@"CONNECT"]){
////			[self.requestSocket writeData:data withTimeout:-1 tag:0];
////		}
//	}
	if(tag == 1000){
		[self.requestSocket writeData:data withTimeout:-1 tag:1000];
		[self.requestSocket readDataWithTimeout:-1 tag:1001];
		[self.clientSocket readDataWithTimeout:-1 tag:1000];
	}
	if(tag == 1001){
		[self.clientSocket writeData:data withTimeout:-1 tag:1000];
		[self.requestSocket readDataWithTimeout:-1 tag:1001];
		[self.clientSocket readDataWithTimeout:-1 tag:1000];
	}
//	[self.toSendData appendData:data];
//	WEAKSELF(ws);
//	self.requestSocket = [[RequestSocket alloc] initWithData:data socket:self.clientSocket];
//	self.requestSocket.request_didReadData = ^(GCDAsyncSocket *socket,NSData *data,long tag){
//		[ws.clientSocket writeData:data withTimeout:-1 tag:0];
//	};
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
	if(self.isConnectMethod){
		NSLog(@"HTTP请求Url=>%@",self.header.path);
		self.httpProxyWriteStatus = HTTPProxyWriteConnectResponse;
		self.httpProxyReadStatus = HTTPProxyReadingContent;
		[self.clientSocket writeData:[@"HTTP/1.1 200 Connection Established\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
		[self.clientSocket readDataWithTimeout:-1 tag:1000];
	}else{
		self.httpProxyWriteStatus = HTTPProxyWriteForwarding;
		[self.requestSocket writeData:self.toSendData withTimeout:-1 tag:0];
		[self.requestSocket readDataWithTimeout:-1 tag:1001];
	}
//	[self.clientSocket readDataWithTimeout:-1 tag:1000];
	//	if(self.request_didReadData){
	//		self.request_didReadData(sock, [@"HTTP/1.1 200 Connection Established\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding], 0);
	//	}
	//	[self.requestSocket writeData:self.toSendData withTimeout:-1 tag:0];
}

//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
//{
//	
//}

@end
