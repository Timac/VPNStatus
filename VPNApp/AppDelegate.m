//
//  AppDelegate.m
//  VPNApp
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

#import "AppDelegate.h"

#import "ACDefines.h"
#import "ACNEService.h"
#import "ACNEServicesManager.h"
#import "ACPreferences.h"

#import "ACConnectionManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *servicesPopupButton;
@property (weak) IBOutlet NSBox *containerBox;
@property (weak) IBOutlet NSButton *toggleConnectionButton;
@property (weak) IBOutlet NSButton *alwaysAutoConnectButton;

@property (weak) IBOutlet NSTextField *stateField;
@property (weak) IBOutlet NSTextField *protocolField;
@property (weak) IBOutlet NSTextField *serverAddressField;

@property (weak) IBOutlet NSTextField *noVPNAvailableTextField;

@end

@implementation AppDelegate

// Quit the application when the window is closed
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Create the ACConnectionManager singleton
	[ACConnectionManager sharedManager];
	
	// Register for notifications to refresh the UI
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:kSessionStateChangedNotification object:nil];
 
	// Make sure that the ACNEServicesManager singleton is created and load the configurations
	[[ACNEServicesManager sharedNEServicesManager] loadConfigurationsWithHandler:^(NSError * error)
	{
		if(error != nil)
		{
			NSLog(@"Failed to load the configurations - %@", error);
		}
		
		[[ACConnectionManager sharedManager] connectAllAutoConnectedServices];
		
		// Update UI
		[self.servicesPopupButton removeAllItems];
	
		NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
		for(ACNEService *neService in neServices)
		{
			[self.servicesPopupButton addItemWithTitle:neService.name];
		}
		
		[self.noVPNAvailableTextField setHidden:([neServices count] > 0)];
		[self.containerBox setHidden:([neServices count] <= 0)];
		[self.servicesPopupButton setHidden:([neServices count] <= 0)];
	}];
}

-(void)refreshUI
{
	// Get all services
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	
	// Find the currently selected service
	NSInteger selectedItemIndex = [self.servicesPopupButton indexOfSelectedItem];
	if(selectedItemIndex >= 0 && selectedItemIndex < [neServices count])
	{
		ACNEService *neService = neServices[selectedItemIndex];
		
		// Update the state
		SCNetworkConnectionStatus serviceState = kSCNetworkConnectionInvalid;
		if(neService != nil)
		{
			serviceState = [neService state];
		}
		
		// Update the information
		self.serverAddressField.stringValue = [neService serverAddress];
		self.protocolField.stringValue = [neService protocol];
		
		NSArray<NSString *>*alwaysConnectedServices = [[ACPreferences sharedPreferences] alwaysConnectedServicesIdentifiers];
		if([alwaysConnectedServices containsObject:[neService.configuration.identifier UUIDString]])
		{
			[self.alwaysAutoConnectButton setState:NSControlStateValueOn];
		}
		else
		{
			[self.alwaysAutoConnectButton setState:NSControlStateValueOff];
		}
		
		// Update the controls based on the state
		switch(serviceState)
		{
			case kSCNetworkConnectionDisconnected:
			{
				self.stateField.stringValue = @"Disconnected";
				self.toggleConnectionButton.title = @"Connect";
				self.toggleConnectionButton.enabled = YES;
			}
			break;
			
			case kSCNetworkConnectionConnected:
			{
				self.stateField.stringValue = @"Connected";
				self.toggleConnectionButton.title = @"Disconnect";
				self.toggleConnectionButton.enabled = YES;
			}
			break;
			
			case kSCNetworkConnectionConnecting:
			{
				self.stateField.stringValue = @"Connecting";
				self.toggleConnectionButton.title = @"Connect";
				self.toggleConnectionButton.enabled = NO;
			}
			break;
			
			case kSCNetworkConnectionDisconnecting:
			{
				self.stateField.stringValue = @"Disconnecting";
				self.toggleConnectionButton.title = @"Disconnect";
				self.toggleConnectionButton.enabled = NO;
			}
			break;
			
			case kSCNetworkConnectionInvalid:
			default:
			{
				self.stateField.stringValue = @"Invalid";
				self.toggleConnectionButton.title = @"Connect";
				self.toggleConnectionButton.enabled = NO;
			}
			break;
		}
	}
}

-(IBAction)toggleConnection:(id)sender
{
	// Get all services
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	
	// Find the currently selected service
	NSInteger selectedItemIndex = [self.servicesPopupButton indexOfSelectedItem];
	if(selectedItemIndex >= 0 && selectedItemIndex < [neServices count])
	{
		ACNEService *neService = neServices[selectedItemIndex];
		[[ACConnectionManager sharedManager] toggleConnectionForService:neService];
	}
}

-(IBAction)alwaysAutoConnect:(id)sender
{
	NSInteger selectedItemIndex = [self.servicesPopupButton indexOfSelectedItem];
	BOOL isAlwaysConnected = ([self.alwaysAutoConnectButton state] == NSControlStateValueOn);
	
	// Get all services
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	if(selectedItemIndex >= 0 && selectedItemIndex < [neServices count])
	{
		ACNEService *neService = neServices[selectedItemIndex];
		[[ACConnectionManager sharedManager] setAlwaysAutoConnect:isAlwaysConnected forACNEService:neService];
	}
}

-(IBAction)popupButtonSelectionChange:(id)sender
{
	// Make sure to refresh the UI
	[self refreshUI];
}

-(IBAction)openWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://blog.timac.org"]];
}

@end
