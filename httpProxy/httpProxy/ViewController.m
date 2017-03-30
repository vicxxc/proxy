//
//  ViewController.m
//  httpProxy
//
//  Created by scorpio on 2017/3/2.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import <Masonry.h>

@interface ViewController ()
@property (nonatomic, strong) UIButton *connectButton;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view addSubview:self.connectButton];
	[self.connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.mas_equalTo(40);
		make.width.mas_equalTo(200);
		make.center.equalTo(self.view);
	}];
	[self.connectButton addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
}

- (void)connect{
	WEAKSELF(ws);
		[NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
			if(!error){
				if([managers count] > 0){
					NETunnelProviderManager *manager = managers[0];
					if (manager.connection.status != NEVPNStatusDisconnected && manager.connection.status != NEVPNStatusInvalid) {
						[manager.connection stopVPNTunnel];
					}else{
						NSError *startVPNError;
						[manager.connection startVPNTunnelAndReturnError:&startVPNError];
						if(startVPNError){
							[ws.connectButton setTitle:@"连接失败" forState:UIControlStateNormal];
						}else{
							[ws.connectButton setTitle:@"连接成功" forState:UIControlStateNormal];
						}
						[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeVpnStatus) name:NEVPNStatusDidChangeNotification object:nil];
					}
				}else{
					NETunnelProviderManager *manager = [NETunnelProviderManager new];
					NETunnelProviderProtocol *configuration = [NETunnelProviderProtocol new];
					configuration.serverAddress = @"Wave VPN";
					manager.protocolConfiguration = configuration;
					manager.localizedDescription = @"Wave";
					manager.enabled = YES;
					manager.onDemandEnabled = YES;
					[manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
						if(error){
							[ws.connectButton setTitle:@"保存失败" forState:UIControlStateNormal];
						}else{
							[ws startVpn];
						}
					}];
				}
			}else{
				[self.connectButton setTitle:@"连接失败" forState:UIControlStateNormal];
			}
		}];
}

- (void)didChangeVpnStatus
{
	NEVPNManager * vpnManager = [NEVPNManager sharedManager];
	switch (vpnManager.connection.status) {
		case NEVPNStatusInvalid:
			[self.connectButton setTitle:@"NEVPNStatusInvalid" forState:UIControlStateNormal];
			break;
		case NEVPNStatusDisconnected:
			[self.connectButton setTitle:@"NEVPNStatusDisconnected" forState:UIControlStateNormal];
			break;
		case NEVPNStatusConnecting:
			[self.connectButton setTitle:@"NEVPNStatusConnecting" forState:UIControlStateNormal];
			break;
		case NEVPNStatusConnected:
			[self.connectButton setTitle:@"NEVPNStatusConnected" forState:UIControlStateNormal];
			break;
		case NEVPNStatusReasserting:
			[self.connectButton setTitle:@"NEVPNStatusReasserting" forState:UIControlStateNormal];
			break;
		case NEVPNStatusDisconnecting:
			[self.connectButton setTitle:@"NEVPNStatusDisconnecting" forState:UIControlStateNormal];
			break;
	}
}

- (void)startVpn{
	[NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
		if(!error){
			if([managers count] > 0){
				NETunnelProviderManager *manager = managers[0];
				NSError *startVPNError;
				[manager.connection startVPNTunnelAndReturnError:&startVPNError];
				if(startVPNError){
					[self.connectButton setTitle:@"连接失败" forState:UIControlStateNormal];
				}else{
					[self.connectButton setTitle:@"连接成功" forState:UIControlStateNormal];
				}
			}
		}
	}];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (UIButton *)connectButton{
	if (!_connectButton) {
		_connectButton = [UIButton new];
		[_connectButton setTitle:@"连接" forState:UIControlStateNormal];
		[_connectButton setClipsToBounds:YES];
		[_connectButton.layer setCornerRadius:5];
		[_connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_connectButton setBackgroundColor:TTBLUE];
	}
	return _connectButton;
}

@end
