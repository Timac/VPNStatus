//
//  ACCrossPromotionWindowController.m
//  Dependencies
//
//  Created by Alexandre Colucci on 16.03.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.

#import "ACCrossPromotionWindowController.h"

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

-(IBAction)doDependencies:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://apps.apple.com/app/dependencies/id1538972026"]];
}

-(IBAction)doMarkChart:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://apps.apple.com/us/app/markchart-mermaid-preview/id6475648822"]];
}

-(IBAction)doVPNStatus:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Timac/VPNStatus/releases"]];
}

@end
