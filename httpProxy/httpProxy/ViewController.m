//
//  ViewController.m
//  httpProxy
//
//  Created by scorpio on 2017/3/2.
//  Copyright © 2017年 FinalFantasy. All rights reserved.
//

#import "ViewController.h"
#import "GCDHTTPLocalServer.h"

@interface ViewController ()
@property (nonatomic, strong) GCDHTTPLocalServer *httpLocalServer;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.httpLocalServer = [[GCDHTTPLocalServer alloc] initWithIpAddress:@"127.0.0.1" port:6543];
	[self.httpLocalServer start];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
