//
//  HttpLocalSocket.m
//  httpProxy
//
//  Created by scorpio on 2017/3/21.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "HttpLocalSocket.h"
#import "Utils.h"
#import "GCDTCPSocket.h"
#import "HTTPStreamScanner.h"
#import "HTTPHeader.h"

typedef NS_ENUM(NSUInteger, HTTPLocalSocketReadStatus) {
	HTTPLocalSocketReadInvalid,
	HTTPLocalSocketReadingFirstHeader,
	HTTPLocalSocketToSendFirstHeader,
	HTTPLocalSocketReadingHeader,
	HTTPLocalSocketReadingContent,
	HTTPLocalSocketReadStopped
};

typedef NS_ENUM(NSUInteger, HTTPLocalSocketWriteStatus) {
	HTTPLocalSocketWriteInvalid,
	HTTPLocalSocketWriteConnectResponse,
	HTTPLocalSocketWriteForwarding,
	HTTPLocalSocketWriteStopped
};

@interface HttpLocalSocket()<RawTCPSocketDelegate>
//@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
//@property (nonatomic, strong) GCDAsyncSocket *requestSocket;
//@property (nonatomic, strong) NSData *toSendData;
@property (nonatomic, strong) HTTPHeader *header;
@property (nonatomic, strong) HTTPStreamScanner *scanner;
@property (nonatomic, strong) NSString *destinationHost;
@property (nonatomic, assign) NSInteger destinationPort;
@property (nonatomic, assign) HTTPLocalSocketReadStatus httpLocalSocketWriteStatus;
@property (nonatomic, assign) HTTPLocalSocketWriteStatus httpLocalSocketReadStatus;
@property (nonatomic, assign) BOOL isConnectMethod;
@end

@implementation HttpLocalSocket

- (instancetype)initWithSocket:(GCDTCPSocket *)socket
{
	self = [super initWithSocket:socket];
	if (self) {
		self.scanner = [HTTPStreamScanner new];
		self.socket.delegate = self;
	}
	return self;
}

- (void)openSocket
{
	[super openSocket];
	self.httpLocalSocketReadStatus = HTTPLocalSocketReadingFirstHeader;
	[self.socket readDataToData:[Utils new].HTTPData.DoubleCRLF];
}

- (void)socket:(GCDTCPSocket *)sock didReadData:(NSData *)data
{
	NSError *error;
	HTTPStreamScannerResult *result = [self.scanner analysis:data error:&error];
	if(self.httpLocalSocketReadStatus == HTTPLocalSocketReadingFirstHeader){
		if(result.resultType == HTTPStreamScannerResultHeader){
			self.header = (HTTPHeader *)result.resultData;
			[self.header removeProxyHeader];
			self.isConnectMethod = self.header.isConnectMethod;
			self.destinationHost = self.header.host;
			self.destinationPort = self.header.port;
			if(!self.isConnectMethod){
				self.httpLocalSocketReadStatus = HTTPLocalSocketToSendFirstHeader;
			}else{
				self.httpLocalSocketReadStatus = HTTPLocalSocketReadingContent;
			}
			ConnectSession *session = [[ConnectSession alloc] initWithHost:self.header.host port:self.header.port];
			if (self.socketDelegate && [self.socketDelegate respondsToSelector:@selector(socket:didReceive:)]) {
				[self.socketDelegate socket:self didReceive:session];
			}
		}
//		currentHeader = header
//		currentHeader.removeProxyHeader()
//		currentHeader.rewriteToRelativePath()
//		
//		destinationHost = currentHeader.host
//		destinationPort = currentHeader.port
//		isConnectCommand = currentHeader.isConnect
//		
//		if !isConnectCommand {
//			readStatus = .pendingFirstHeader
//		} else {
//			readStatus = .readingContent
//		}
//		
//		session = ConnectSession(host: destinationHost!, port: destinationPort!)
//		observer?.signal(.receivedRequest(session!, on: self))
//		delegate?.didReceive(session: session!, from: self)
		
//		self.requestSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//		[self.requestSocket connectToHost:self.header.host onPort:self.header.port error:&error];
//		self.toSendData = data;
//		if(self.isConnectMethod){
//			self.httpProxyReadStatus = HTTPProxyToSendFirstHeader;
//		}else{
//			self.httpProxyReadStatus = HTTPProxyReadingContent;
//		}
		//		self.header = [[HTTPHeader alloc] initWithHeaderData:data];
	}
//	if(self.httpProxyReadStatus == HTTPProxyReadingContent){
//		
//	}
}



























@end
