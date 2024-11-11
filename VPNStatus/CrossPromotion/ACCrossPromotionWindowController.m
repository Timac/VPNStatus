//
//  ACCrossPromotionWindowController.m
//  VPNStatus
//
//  Created by Alexandre Colucci on 16.03.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.

#import "ACCrossPromotionWindowController.h"
#import <WebKit/WebKit.h>

@interface ACCrossPromotionWindowController () <WKNavigationDelegate>

@property (weak) IBOutlet WKWebView *webView;

@end


@implementation ACCrossPromotionWindowController

+ (ACCrossPromotionWindowController *)sharedWindowController
{
	static ACCrossPromotionWindowController *sharedWindowController = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedWindowController = [[self alloc] initCrossPromotionWindow];
	});
	
	return sharedWindowController;
}

-(instancetype)initCrossPromotionWindow
{
	self = [super initWithWindowNibName:@"ACCrossPromotionWindow"];
	if (self)
	{
	}
	
	return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];

	[self.webView setNavigationDelegate:self];
	NSURL *url = [NSURL URLWithString:@"https://blog.timac.org/apps"];
	NSURLRequest *request = [NSURLRequest requestWithURL: url];
	[self.webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
	NSURL *url = navigationAction.request.URL;
	if([url.absoluteString isEqualToString:@"https://blog.timac.org/apps"])
	{
		decisionHandler(WKNavigationActionPolicyAllow);
		return;
	}
	else if(url != nil)
	{
		[[NSWorkspace sharedWorkspace] openURL:url];
	}

	decisionHandler(WKNavigationActionPolicyCancel);
}

@end
