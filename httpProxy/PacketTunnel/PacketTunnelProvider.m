//
//  PacketTunnelProvider.m
//  PacketTunnel
//
//  Created by scorpio on 2017/3/30.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import "GCDHTTPLocalServer.h"
//#import <CocoaLumberjack/CocoaLumberjack.h>

//static const int ddLogLevel = DDLogLevelVerbose;

@interface PacketTunnelProvider ()
@property NWTCPConnection *connection;
@property (strong) void (^pendingStartCompletion)(NSError *);
@property (nonatomic, strong) GCDHTTPLocalServer *httpLocalServer;
@property (nonatomic, assign) BOOL enablePacketProcess;
@end

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler
{
	self.enablePacketProcess = YES;
	[self setLog];
	DDLogVerbose(@"startTunnel");
	
	NSArray *addresses = @[@"10.0.1.100"];
	NSArray *subnetMasks = @[@"255.255.255.0"];
	
	NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"192.168.1.1"];
	
	settings.IPv4Settings = [[NEIPv4Settings alloc] initWithAddresses:addresses subnetMasks:subnetMasks];
	if(self.enablePacketProcess){
		NEIPv4Route *defaultRoute = [NEIPv4Route defaultRoute];
		NEIPv4Route *localRoute = [[NEIPv4Route alloc] initWithDestinationAddress:@"10.0.0.0" subnetMask:@"255.255.255.0"];
		settings.IPv4Settings.includedRoutes = @[defaultRoute, localRoute];
		settings.IPv4Settings.excludedRoutes = @[];
	}
	settings.MTU = [NSNumber numberWithInt:1500];
	
	NEProxySettings* proxySettings = [[NEProxySettings alloc] init];
	NSInteger proxyServerPort = 6543;
	NSString *proxyServerName = @"127.0.0.1";
	
	proxySettings.HTTPEnabled = YES;
	proxySettings.HTTPServer = [[NEProxyServer alloc] initWithAddress:proxyServerName port:proxyServerPort];
	proxySettings.HTTPSEnabled = YES;
	proxySettings.HTTPSServer = [[NEProxyServer alloc] initWithAddress:proxyServerName port:proxyServerPort];
	proxySettings.excludeSimpleHostnames = YES;
	settings.proxySettings = proxySettings;
	
	if (self.enablePacketProcess) {
		NSArray<NSString *> *dnsServers = @[@"8.8.8.8", @"8.8.4.4"];
		NEDNSSettings *dnsSettings = [[NEDNSSettings alloc] initWithServers:dnsServers];
		dnsSettings.matchDomains = @[@""];
		settings.DNSSettings = dnsSettings;
	}
	
	
	WEAKSELF(ws);
	
	[self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
		DDLogVerbose(@"setTunnelNetworkSettings error: %@", error);
		
		ws.httpLocalServer = [[GCDHTTPLocalServer alloc] initWithIpAddress:@"127.0.0.1" port:6543];
		[ws.httpLocalServer start];
		
		if (ws.enablePacketProcess) {
			[ws dealPacketFlow];
		}
		
		completionHandler(error);
	}];
}

- (void)dealPacketFlow
{
	WEAKSELF(ws);
	[self.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> * _Nonnull packets, NSArray<NSNumber *> * _Nonnull protocols) {
		DDLogVerbose(@"packets=>%@,protocols=>%@",packets,protocols);
		[ws dealPacketFlow];
	}];
}

- (void)setLog
{
	[DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
	[DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
	
	DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
	fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
	fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
	[DDLog addLogger:fileLogger];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"state"]) {
		NWTCPConnection *conn = (NWTCPConnection *)object;
		if (conn.state == NWTCPConnectionStateConnected) {
			NWHostEndpoint *ra = (NWHostEndpoint *)conn.remoteAddress;
			__weak PacketTunnelProvider *weakself = self;
			[self setTunnelNetworkSettings:[[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:ra.hostname] completionHandler:^(NSError *error) {
				if (error == nil) {
					[weakself addObserver:weakself forKeyPath:@"defaultPath" options:NSKeyValueObservingOptionInitial context:nil];
					[weakself.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> *packets, NSArray<NSNumber *> *protocols) {
						// Add code here to deal with packets, and call readPacketsWithCompletionHandler again when ready for more.
					}];
					[conn readMinimumLength:0 maximumLength:8192 completionHandler:^(NSData *data, NSError *error) {
						// Add code here to parse packets from the data, call [self.packetFlow writePackets] with the result
					}];
				}
				if (weakself.pendingStartCompletion != nil) {
					weakself.pendingStartCompletion(nil);
					weakself.pendingStartCompletion = nil;
				}
			}];
		} else if (conn.state == NWTCPConnectionStateDisconnected) {
			NSError *error = [NSError errorWithDomain:@"PacketTunnelProviderDomain" code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"Connection closed by server" }];
			if (self.pendingStartCompletion != nil) {
				self.pendingStartCompletion(error);
				self.pendingStartCompletion = nil;
			} else {
				[self cancelTunnelWithError:error];
			}
			[conn cancel];
		} else if (conn.state == NWTCPConnectionStateCancelled) {
			[self removeObserver:self forKeyPath:@"defaultPath"];
			[conn removeObserver:self forKeyPath:@"state"];
			self.connection = nil;
		}
	} else if ([keyPath isEqualToString:@"defaultPath"]) {
		// Add code here to deal with changes to the network
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
	// Add code here to start the process of stopping the tunnel
	[self.connection cancel];
	completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler
{
	// Add code here to handle the message
	if (completionHandler != nil) {
		completionHandler(messageData);
	}
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler
{
	// Add code here to get ready to sleep
	completionHandler();
}

- (void)wake
{
	// Add code here to wake up
}

@end
