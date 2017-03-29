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
#import "RawTCPSocketProtocol.h"

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
@property (nonatomic, assign) HTTPLocalSocketReadStatus httpLocalSocketReadStatus;
@property (nonatomic, assign) HTTPLocalSocketWriteStatus httpLocalSocketWriteStatus;
@property (nonatomic, assign) BOOL isConnectMethod;
@end

@implementation HttpLocalSocket

- (void)openSocket
{
	[super openSocket];
	self.httpLocalSocketReadStatus = HTTPLocalSocketReadingFirstHeader;
	[self.socket readDataTo:[Utils new].HTTPData.DoubleCRLF];
}

- (void)readData
{
	if(self.httpLocalSocketReadStatus == HTTPLocalSocketToSendFirstHeader){
		self.httpLocalSocketReadStatus = HTTPLocalSocketReadingContent;
		[self.delegate didReadData:[self.header toData] from:self];
		return;
	}
	if(self.scanner.readStatus == HTTPStreamScannerReadContent){
		[self.socket readData];
	}else if(self.scanner.readStatus == HTTPStreamScannerReadHeader){
		[self.socket readDataTo:[Utils new].HTTPData.DoubleCRLF];
		// [self.socket readData];
	}else if(self.scanner.readStatus == HTTPStreamScannerStop){
		self.httpLocalSocketReadStatus = HTTPLocalSocketReadStopped;
		[self disconnectOf:nil];
	}
}

- (void)didReadData:(NSData *)data from:(id<RawTCPSocketProtocol>)socket
{
	NSError *error;
	HTTPStreamScannerResult *result = [self.scanner analysis:data error:&error];
	if(!error){
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
				if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveSession:localSocket:)]) {
					[self.delegate didReceiveSession:session localSocket:self];
				}
			}
		}
		if(self.httpLocalSocketReadStatus == HTTPLocalSocketReadingHeader){
			self.header = (HTTPHeader *)result.resultData;
			[self.header removeProxyHeader];
			if (self.delegate && [self.delegate respondsToSelector:@selector(didReadData:from:)]) {
				[self.delegate didReadData:data from:self];
			}
		}
		if(self.httpLocalSocketReadStatus == HTTPLocalSocketReadingContent){
			if (self.delegate && [self.delegate respondsToSelector:@selector(didReadData:from:)]) {
				[self.delegate didReadData:data from:self];
			}
		}
	}else{
		[self disconnectOf:error];
	}
}

- (void)didWriteData:(NSData *)data by:(id<RawTCPSocketProtocol>)socket
{
	[super didWriteData:data by:socket];
	
	switch (self.httpLocalSocketWriteStatus) {
		case HTTPLocalSocketWriteConnectResponse:
		{
			self.httpLocalSocketWriteStatus = HTTPLocalSocketWriteForwarding;
			if (self.delegate && [self.delegate respondsToSelector:@selector(didBecomeReadyToForwardWithSocket:)]) {
				[self.delegate didBecomeReadyToForwardWithSocket:self];
			}
		}
			break;
			
		default:
		{
			if (self.delegate && [self.delegate respondsToSelector:@selector(didWriteData:by:)]) {
				[self.delegate didWriteData:data by:self];
			}
		}
			break;
	}
}

- (void)respondToRemoteSocket:(RemoteSocket *)remoteSocket
{
	[super respondToRemoteSocket:remoteSocket];
	if(self.isConnectMethod){
		self.httpLocalSocketWriteStatus = HTTPLocalSocketWriteConnectResponse;
		[self writeData:[Utils new].HTTPData.ConnectSuccessResponse];
	}else{
		self.httpLocalSocketWriteStatus = HTTPLocalSocketWriteForwarding;
		if (self.delegate && [self.delegate respondsToSelector:@selector(didBecomeReadyToForwardWithSocket:)]) {
			[self.delegate didBecomeReadyToForwardWithSocket:self];
		}
	}
}

- (HTTPStreamScanner *)scanner{
	if (!_scanner) {
		_scanner = [HTTPStreamScanner new];
	}
	return _scanner;
}
@end
