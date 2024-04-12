//
//  ACPreferencesGeneralViewController.m
//
//  Created by Alexandre Colucci on 06.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.

#import "ACPreferencesGeneralViewController.h"

#import "ACPreferences.h"
#import "VPNStatus-Swift.h"

@interface ACPreferencesGeneralViewController ()

@property (weak) IBOutlet NSTextField *retryDelayField;

@end


@implementation ACPreferencesGeneralViewController

- (instancetype)initViewController
{
	self = [super initWithNibName:@"ACPreferencesGeneralView" bundle:nil];
	if (self)
	{
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	NSInteger retryDelay = [[ACPreferences sharedPreferences] alwaysConnectedRetryDelay];
	[self.retryDelayField setIntegerValue:retryDelay];
}

- (void)viewWillDisappear
{
	[super viewWillDisappear];

	// Save when closing the window
	NSInteger retryDelay = [self.retryDelayField integerValue];
	[[ACPreferences sharedPreferences] setAlwaysConnectedRetryDelay:retryDelay];
}

-(NSString*)identifier
{
	return [[self title] lowercaseString];
}

-(NSString*)title
{
	return @"General";
}

- (IBAction)retryDelayDidChange:(id)sender
{
	NSInteger retryDelay = [sender integerValue];
	[[ACPreferences sharedPreferences] setAlwaysConnectedRetryDelay:retryDelay];
}

- (IBAction)doCheckForUpdates:(id)sender
{
	[[UpdateManager shared] checkForUpdateWithShowUpToDateAlert:YES];
}

- (IBAction)doCheckForUpdatesAutomatically:(id)sender
{
	NSButton *checkbox = (NSButton *)sender;
	[[ACPreferences sharedPreferences] setDisabledCheckForUpdatesAutomatically:(checkbox.state != NSControlStateValueOn)];
}

@end
