//
//  AppDelegate.m
//  VPNStatus
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

#import "AppDelegate.h"

#import "ACDefines.h"
#import "ACNEService.h"
#import "ACNEServicesManager.h"
#import "ACPreferences.h"
#import "ACPreferencesWindowController.h"
#import "ACConnectionManager.h"
#import "ACLocationManager.h"

#import "VPNStatus-Swift.h"

@interface AppDelegate ()

@property (strong) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)reloadConfigurations
{
	// Make sure that the ACNEServicesManager singleton is created and load the configurations
	[[ACNEServicesManager sharedNEServicesManager] loadConfigurationsWithHandler:^(NSError * error)
	 {
		if(error != nil)
		{
			NSLog(@"Failed to load the configurations - %@", error);
		}

		// Connect all services that are marked as always auto connect
		[[ACConnectionManager sharedManager] connectAllAutoConnectedServices];

		// Refresh the menu
		[self refreshMenu];
	}];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Create the ACConnectionManager singleton
	[ACConnectionManager sharedManager];

	// Create the NSStatusItem
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	[self updateStatusItemIcon];

	// Refresh the menu
	[self refreshMenu];

	// Register for notifications to refresh the UI
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMenu) name:kSessionStateChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMenu) name:kACLocationManagerAuthorizationDidChange object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadConfigurations) name:kACConfigurationDidChange object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMenu) name:kACMenuBarImageDidChange object:nil];

	// Make sure that the ACNEServicesManager singleton is created and load the configurations
	[self reloadConfigurations];

	if(![[ACPreferences sharedPreferences] disabledCheckForUpdatesAutomatically])
	{
		[[UpdateManager shared] checkForUpdateWithShowUpToDateAlert:NO];
	}
}

- (void)updateStatusItemIcon
{
	NSButton *statusItemButton = [self.statusItem button];
	if(statusItemButton != nil)
	{
		NSImage *image = [ACPreferences menuBarImageForState:MenuBarImageState_Off];

		BOOL oneServiceConnected = NO;
		NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
		for(ACNEService *service in neServices)
		{
			if([service state] == kSCNetworkConnectionConnected)
			{
				oneServiceConnected = YES;
			}
		}
		
		if(oneServiceConnected)
		{
			image = [ACPreferences menuBarImageForState:MenuBarImageState_On];
		}
		else if(([[ACConnectionManager sharedManager] currentPauseDuration] == NSIntegerMax))
		{
			image = [ACPreferences menuBarImageForState:MenuBarImageState_Off];
		}
		else if([[ACConnectionManager sharedManager] isAtLeastOneServiceSetToAutoConnect])
		{
			image = [ACPreferences menuBarImageForState:MenuBarImageState_Pause];
		}
		
		[statusItemButton setImage:image];
	}
}

-(NSMenuItem *)createPauseMenuItemWithTitle:(NSString *)inTitle andDuration:(NSInteger)inDuration
{
	NSMenuItem *outMenuItem = [[NSMenuItem alloc] initWithTitle:inTitle action:@selector(pauseAutoConnect:) keyEquivalent:@""];
	[outMenuItem setTag:inDuration];
	
	if([[ACConnectionManager sharedManager] isAutoConnectPaused])
	{
		NSInteger currentPauseDuration = [[ACConnectionManager sharedManager] currentPauseDuration];
		if(currentPauseDuration > 0 && (inDuration == currentPauseDuration))
		{
			[outMenuItem setState:NSControlStateValueOn];
		}
		else
		{
			[outMenuItem setState:NSControlStateValueOff];
		}
	}
	else
	{
		[outMenuItem setState:NSControlStateValueOff];
	}
	
	return outMenuItem;
}

-(void)refreshMenu
{
	NSMenu *menu = [[NSMenu alloc] init];
	
	if([[ACConnectionManager sharedManager] isAtLeastOneServiceSetToAutoConnect])
	{
		// If the auto connect is currently paused, display a Resume menu item
		if([[ACConnectionManager sharedManager] isAutoConnectPaused])
		{
			[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Resume Auto Connect" action:@selector(resumeAutoConnect:) keyEquivalent:@""]];
			[menu addItem:[NSMenuItem separatorItem]];
		}
		
		// The various pause durations
		[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Pause Auto Connect:" action:nil keyEquivalent:@""]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"5 Minutes" andDuration:5 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"15 Minutes" andDuration:15 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"30 Minutes" andDuration:30 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"1 Hour" andDuration:60 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"2 Hours" andDuration:2 * 60 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"4 Hours" andDuration:4 * 60 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"8 Hours" andDuration:8 * 60 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"12 Hours" andDuration:12 * 60 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"24 Hours" andDuration:24 * 60 * 60]];
		[menu addItem:[self createPauseMenuItemWithTitle:@"Indefinitively" andDuration:NSIntegerMax]];
		[menu addItem:[NSMenuItem separatorItem]];
	}
	
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	
	if([neServices count] == 0)
	{
		// Handle the case where there is no VPN service set up
		[menu addItem:[[NSMenuItem alloc] initWithTitle:@"No VPN available" action:nil keyEquivalent:@""]];
		[menu addItem:[NSMenuItem separatorItem]];
	}
	else
	{
		NSUInteger connectServiceIndex = 0;
		for(ACNEService *neService in neServices)
		{
			// Update the controls based on the state
			NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ is invalid", neService.name] action:nil keyEquivalent:@""];
			
			// Update the state
			switch([neService state])
			{
				case kSCNetworkConnectionDisconnected:
				{
					[menuItem setTitle:[NSString stringWithFormat:@"Connect %@", neService.name]];
					[menuItem setAction:@selector(connectService:)];
				}
				break;
				
				case kSCNetworkConnectionConnected:
				{
					[menuItem setTitle:[NSString stringWithFormat:@"Disconnect %@", neService.name]];
					[menuItem setAction:@selector(disconnectService:)];
				}
				break;
				
				case kSCNetworkConnectionConnecting:
				{
					[menuItem setTitle:[NSString stringWithFormat:@"Connecting %@...", neService.name]];
				}
				break;
				
				case kSCNetworkConnectionDisconnecting:
				{
					[menuItem setTitle:[NSString stringWithFormat:@"Disconnecting %@...", neService.name]];
				}
				break;
				
				case kSCNetworkConnectionInvalid:
				default:
				{
					[menuItem setTitle:[NSString stringWithFormat:@"%@ is invalid", neService.name]];
				}
				break;
			}
			
			[menuItem setTag:connectServiceIndex];
			[menu addItem:menuItem];
			connectServiceIndex++;
		}
		
		[menu addItem:[NSMenuItem separatorItem]];
		
		NSUInteger neServiceIndex = 0;
		for(ACNEService *neService in neServices)
		{
			if(neServiceIndex > 0)
			{
				[menu addItem:[NSMenuItem separatorItem]];
			}
			
			[menu addItem:[[NSMenuItem alloc] initWithTitle:neService.name action:nil keyEquivalent:@""]];
			
			// Update the information
			[menu addItem:[[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%@)", [neService serverAddress], [neService protocol]] action:nil keyEquivalent:@""]];
			
			NSMenuItem *alwaysAutoConnectMenuItem = [[NSMenuItem alloc] initWithTitle:@"Always auto connect" action:@selector(alwaysAutoConnect:) keyEquivalent:@""];
			[alwaysAutoConnectMenuItem setTag:neServiceIndex];
			NSArray<NSString *>*alwaysConnectedServices = [[ACPreferences sharedPreferences] alwaysConnectedServicesIdentifiers];
			if([alwaysConnectedServices containsObject:[neService.configuration.identifier UUIDString]])
			{
				[alwaysAutoConnectMenuItem setState: NSControlStateValueOn];
			}
			else
			{
				[alwaysAutoConnectMenuItem setState: NSControlStateValueOff];
			}
			
			[menu addItem:alwaysAutoConnectMenuItem];
			neServiceIndex++;
		}
		
		[menu addItem:[NSMenuItem separatorItem]];
	}

	// Tell the user that Location Services access is needed in order to read the current Wi-Fi SSID on macOS 14 Sonoma
	CLAuthorizationStatus authorizationStatus = [[ACLocationManager sharedLocationManager] authorizationStatus];
	switch (authorizationStatus) {
		case kCLAuthorizationStatusNotDetermined:
			[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Location Services access is needed to read the Wi-Fi SSID" action:nil keyEquivalent:@""]];
			[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Grant permission…" action:@selector(requestLocationAccess:) keyEquivalent:@""]];
			[menu addItem:[NSMenuItem separatorItem]];
			break;

		case kCLAuthorizationStatusRestricted:
		case kCLAuthorizationStatusDenied:
			[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Location Services access is needed to read the Wi-Fi SSID" action:nil keyEquivalent:@""]];
			[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Open Location Services preferences…" action:@selector(openLocationAccessSettings:) keyEquivalent:@""]];
			[menu addItem:[NSMenuItem separatorItem]];
			break;

		case kCLAuthorizationStatusAuthorizedAlways:
			break;
	}

	// Other menu items
	[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Settings…" action:@selector(openSettings:) keyEquivalent:@","]];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit VPNStatus" action:@selector(doQuit:) keyEquivalent:@"q"]];
	
	self.statusItem.menu = menu;
	[self updateStatusItemIcon];
}

-(IBAction)connectService:(id)sender
{
	// Get all services
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	
	// Find the currently selected service
	NSInteger selectedItemIndex = [(NSMenuItem *)sender tag];
	if(selectedItemIndex >= 0 && selectedItemIndex < [neServices count])
	{
		ACNEService *neService = neServices[selectedItemIndex];
		[neService connect];
	}
}

-(IBAction)disconnectService:(id)sender
{
	// Get all services
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	
	// Find the currently selected service
	NSInteger selectedItemIndex = [(NSMenuItem *)sender tag];
	if(selectedItemIndex >= 0 && selectedItemIndex < [neServices count])
	{
		ACNEService *neService = neServices[selectedItemIndex];
		[neService disconnect];
	}
}

-(IBAction)requestLocationAccess:(id)sender
{
	[[ACLocationManager sharedLocationManager] requestAlwaysAuthorizationIfNeeded];
}

-(IBAction)openLocationAccessSettings:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

-(IBAction)openSettings:(id)sender
{
	[[ACPreferencesWindowController sharedWindowController] showWindow:self];
}

-(IBAction)doQuit:(id)sender
{
	[NSApp terminate:self];
}

-(IBAction)alwaysAutoConnect:(id)sender
{
	NSInteger selectedItemIndex = [(NSMenuItem *)sender tag];
	
	// Get all services
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	ACNEService *neService = nil;
	
	// Find the currently selected service
	if(selectedItemIndex >= 0 && selectedItemIndex < [neServices count])
	{
		neService = neServices[selectedItemIndex];
	}
	
	if(neService != nil)
	{
		BOOL isAlwaysConnected = NO;
		NSArray<NSString *>*alwaysConnectedServices = [[ACPreferences sharedPreferences] alwaysConnectedServicesIdentifiers];
		if([alwaysConnectedServices containsObject:[neService.configuration.identifier UUIDString]])
		{
			isAlwaysConnected = YES;
		}
		else
		{
			isAlwaysConnected = NO;
		}
		
		[[ACConnectionManager sharedManager] setAlwaysAutoConnect:!isAlwaysConnected forACNEService:neService];
	}
	
	if(![[ACConnectionManager sharedManager] isAtLeastOneServiceSetToAutoConnect])
	{
		[[ACConnectionManager sharedManager] resumeAutoConnect];
	}
	
	[self refreshMenu];
}

-(IBAction)resumeAutoConnect:(id)sender
{
	[[ACConnectionManager sharedManager] resumeAutoConnect];
	
	[[ACConnectionManager sharedManager] connectAllAutoConnectedServices];
	
	[self refreshMenu];
}

-(IBAction)pauseAutoConnect:(id)sender
{
	NSInteger duration = [(NSMenuItem *)sender tag];
	[[ACConnectionManager sharedManager] pauseAutoConnect:duration];
	
	[[ACConnectionManager sharedManager] disconnectAllAutoConnectedServices];
	
	[self refreshMenu];
}

@end
