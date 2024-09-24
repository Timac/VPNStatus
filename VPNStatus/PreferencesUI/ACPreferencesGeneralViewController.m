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
@property (weak) IBOutlet NSButton *automaticCheckForUpdatesButton;
@property (weak) IBOutlet NSButton *singleAutoConnectButton;
@property (weak) IBOutlet NSPopUpButton *menuBarImagePopUpButton;

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

	BOOL disabledCheckForUpdatesAutomatically = [[ACPreferences sharedPreferences] disabledCheckForUpdatesAutomatically];
	if(disabledCheckForUpdatesAutomatically)
	{
		[self.automaticCheckForUpdatesButton setState:NSControlStateValueOff];
	}
	else
	{
		[self.automaticCheckForUpdatesButton setState:NSControlStateValueOn];
	}

  BOOL singleAutoConnect = [[ACPreferences sharedPreferences] singleAutoConnect];
  if(singleAutoConnect)
  {
    [self.singleAutoConnectButton setState:NSControlStateValueOn];
  }
  else
  {
    [self.singleAutoConnectButton setState:NSControlStateValueOff];
  }

	NSMenu *theMenu = self.menuBarImagePopUpButton.menu;
	for(NSInteger menuItemIndex = 0 ; menuItemIndex < theMenu.numberOfItems ; menuItemIndex++)
	{
		NSMenuItem *menuItem = [theMenu itemAtIndex:menuItemIndex];
		[menuItem setImage:[ACPreferences menuBarImageForState:MenuBarImageState_On andType:menuItemIndex]];
	}

	NSInteger selectedMenuBarItem = [[ACPreferences sharedPreferences] menuBarImageType];
	[self.menuBarImagePopUpButton selectItemAtIndex:selectedMenuBarItem];
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

- (IBAction)doSingleAutoConnect:(id)sender
{
  NSButton *checkbox = (NSButton *)sender;
  [[ACPreferences sharedPreferences] setSingleAutoConnect:(checkbox.state != NSControlStateValueOff)];
}

- (IBAction)doChangeMenuBarImage:(id)sender
{
	NSInteger menuBarImageType = [sender indexOfSelectedItem];
	[[ACPreferences sharedPreferences] setMenuBarImageType:menuBarImageType];
}

@end
