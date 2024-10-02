//
//  ACPreferences.m
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

#import "ACPreferences.h"

//
// Preferences keys
//
NSString * const kServicesPrefKey = @"Services";
NSString * const kServiceIdentifierKey = @"Identifier";
NSString * const kServiceAlwaysConnectedKey = @"AlwaysConnected";
NSString * const kServiceIgnoredSSIDsKey = @"IgnoredSSIDs";
NSString * const kServiceIgnoredVPNsKey = @"IgnoredVPNs";

NSString * const kAlwaysConnectedRetryDelayPrefKey = @"AlwaysConnectedRetryDelay";

NSString * const kDisabledCheckForUpdatesAutomaticallyPrefKey = @"DisabledCheckForUpdatesAutomatically";
NSString * const kSingleAutoConnectPrefKey = @"SingleAutoConnect";
NSString * const kMenuBarImageTypePrefKey = @"MenuBarImageType";

NSString * const kACConfigurationDidChange = @"kACConfigurationDidChange";
NSString * const kACMenuBarImageDidChange = @"kACMenuBarImageDidChange";


@implementation ACPreferences


+ (ACPreferences *)sharedPreferences
{
	static ACPreferences *SsharedPreferences = nil;
	if(SsharedPreferences == nil)
	{
		SsharedPreferences = [[ACPreferences alloc] init];
	}

	return SsharedPreferences;
}

-(NSArray<NSString *>*)alwaysConnectedServicesIdentifiers
{
	NSMutableArray<NSString *>* outAlwaysConnectedServicesIdentifiers = [[NSMutableArray alloc] init];

	// Get the list of services that should always been connected
	NSArray <NSDictionary *>*services = [[NSUserDefaults standardUserDefaults] arrayForKey:kServicesPrefKey];
	for(NSDictionary *service in services)
	{
		NSString *serviceIdentifier = service[kServiceIdentifierKey];
		BOOL isAlwaysConnected = [service[kServiceAlwaysConnectedKey] boolValue];
		if(isAlwaysConnected && [serviceIdentifier length] > 0)
		{
			[outAlwaysConnectedServicesIdentifiers addObject:serviceIdentifier];
		}
	}

	return outAlwaysConnectedServicesIdentifiers;
}

-(void)setAlwaysConnected:(BOOL)inAlwaysConnected forServicesIdentifier:(NSString *)inServiceIdentifier
{
	BOOL serviceFound = NO;
	NSMutableArray <NSDictionary *>*services = [[[NSUserDefaults standardUserDefaults] arrayForKey:kServicesPrefKey] mutableCopy];
	if(services == nil)
	{
		services = [[NSMutableArray alloc] init];
	}

	for(NSDictionary *service in services)
	{
		NSString *serviceIdentifier = service[kServiceIdentifierKey];
		if([serviceIdentifier isEqualToString:inServiceIdentifier])
		{
			NSMutableDictionary *updatedServiceDictionary = [service mutableCopy];
			updatedServiceDictionary[kServiceAlwaysConnectedKey] = [NSNumber numberWithBool:inAlwaysConnected];

			[services removeObject:service];
			[services addObject:updatedServiceDictionary];

			serviceFound = YES;
    } else if([self singleAutoConnect])
    {
      NSMutableDictionary *updatedServiceDictionary = [service mutableCopy];
      updatedServiceDictionary[kServiceAlwaysConnectedKey] = [NSNumber numberWithBool:false];

      [services removeObject:service];
      [services addObject:updatedServiceDictionary];
    }
	}

	if(!serviceFound)
	{
		NSMutableDictionary *serviceDictionary = [[NSMutableDictionary alloc] init];
		serviceDictionary[kServiceIdentifierKey] = inServiceIdentifier;
		serviceDictionary[kServiceAlwaysConnectedKey] = [NSNumber numberWithBool:inAlwaysConnected];
		[services addObject:serviceDictionary];
	}

	[[NSUserDefaults standardUserDefaults] setObject:services forKey:kServicesPrefKey];
}

/**
 Gets the list of SSIDs that should be ignored for the
 purposes of automatic connection. Note that this is input
 using:

 defaults write org.timac.VPNStatus IgnoredSSIDs "FirstSSD,Second,Third"

 Also note that the SSID is ignored irrespective of the VPN service.
 */
-(NSArray<NSString *> *)ignoredSSIDs
{
	NSString *ignoredSSIDsString = [[NSUserDefaults standardUserDefaults] stringForKey:kServiceIgnoredSSIDsKey];
	if([ignoredSSIDsString length] > 0)
	{
		return [ignoredSSIDsString componentsSeparatedByString:@","];
	}
	else
	{
		return @[];
	}
}

-(void)setIgnoredSSIDs:(NSArray<NSString *> *)ignoredSSIDs
{
	if([ignoredSSIDs count] <= 0)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kServiceIgnoredSSIDsKey];
	}
	else
	{
		NSString *value = [ignoredSSIDs componentsJoinedByString:@","];
		[[NSUserDefaults standardUserDefaults] setValue:value forKey:kServiceIgnoredSSIDsKey];
	}

	// Post a notification to reload the VPN configurations and refresh the UI
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kACConfigurationDidChange object:nil];
	});
}

/**
 Gets the list of VPNs that shouldn't be displayed in VPNStatus. Example:
 defaults write org.timac.VPNStatus IgnoredVPNs "Little Snitch,HiddenVPN,AnotherHiddenVPN"

 By default, the Little Snitch Content Filter Configuration is hidden
 */
-(NSArray<NSString *> *)ignoredVPNs
{
	NSString *ignoredVPNsString = [[NSUserDefaults standardUserDefaults] stringForKey:kServiceIgnoredVPNsKey];
	if(ignoredVPNsString == nil)
	{
		// Default preference
		// Don't display the Little Snitch Content Filter Configuration
		ignoredVPNsString = @"Little Snitch";
	}

	return [ignoredVPNsString componentsSeparatedByString:@","];
}

-(void)setIgnoredVPNs:(NSArray<NSString *> *)ignoredVPNs
{
	if([ignoredVPNs count] <= 0)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kServiceIgnoredVPNsKey];
	}
	else
	{
		NSString *value = [ignoredVPNs componentsJoinedByString:@","];
		[[NSUserDefaults standardUserDefaults] setValue:value forKey:kServiceIgnoredVPNsKey];
	}

	// Post a notification to reload the VPN configurations and refresh the UI
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kACConfigurationDidChange object:nil];
	});
}

-(NSInteger)alwaysConnectedRetryDelay
{
	NSInteger retryDelay = [[NSUserDefaults standardUserDefaults] integerForKey:kAlwaysConnectedRetryDelayPrefKey];
	if(retryDelay <= 0)
	{
		// Default is 120s
		retryDelay = 120;
	}

	return retryDelay;
}

-(void)setAlwaysConnectedRetryDelay:(NSInteger)retryDelay
{
	if (retryDelay > 0 && retryDelay <= 240)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:retryDelay forKey:kAlwaysConnectedRetryDelayPrefKey];
	}
}

-(BOOL)disabledCheckForUpdatesAutomatically
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kDisabledCheckForUpdatesAutomaticallyPrefKey];
}

-(void)setDisabledCheckForUpdatesAutomatically:(BOOL)inValue
{
	[[NSUserDefaults standardUserDefaults] setBool:inValue forKey:kDisabledCheckForUpdatesAutomaticallyPrefKey];
}

-(BOOL)singleAutoConnect
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:kSingleAutoConnectPrefKey];
}

-(void)setSingleAutoConnect:(BOOL)inValue
{
  [[NSUserDefaults standardUserDefaults] setBool:inValue forKey:kSingleAutoConnectPrefKey];
}

-(MenuBarImageType)menuBarImageType
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:kMenuBarImageTypePrefKey];
}

-(void)setMenuBarImageType:(MenuBarImageType)menuBarImageType
{
	[[NSUserDefaults standardUserDefaults] setInteger:menuBarImageType forKey:kMenuBarImageTypePrefKey];

	// Post a notification to reload the VPN configurations and refresh the UI
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:kACMenuBarImageDidChange object:nil];
	});
}

+(NSImage *)menuBarImageForState:(MenuBarImageState)inState
{
	MenuBarImageType menuBarImageType = [[ACPreferences sharedPreferences] menuBarImageType];
	return [ACPreferences menuBarImageForState:inState andType:menuBarImageType];
}

+(NSImage *)menuBarImageForState:(MenuBarImageState)inState andType:(MenuBarImageType)inType
{
	switch (inState)
	{
		case MenuBarImageState_Off:
			switch (inType)
			{
				case MenuBarImageType_Cloud:
					return [NSImage imageWithSystemSymbolName:@"xmark.icloud" accessibilityDescription:nil];
					break;

				default:
					return [NSImage imageNamed:@"VPNStatusItemOffImage"];
					break;
			}
			break;

		case MenuBarImageState_On:
			switch (inType)
			{
				case MenuBarImageType_Cloud:
					return [NSImage imageWithSystemSymbolName:@"checkmark.icloud.fill" accessibilityDescription:nil];
					break;

				default:
					return [NSImage imageNamed:@"VPNStatusItemOnImage"];
					break;
			}
			break;

		case MenuBarImageState_Pause:
			switch (inType)
			{
				case MenuBarImageType_Cloud:
					return [NSImage imageWithSystemSymbolName:@"arrow.triangle.2.circlepath.icloud" accessibilityDescription:nil];
					break;

				default:
					return [NSImage imageNamed:@"VPNStatusItemPauseImage"];
					break;
			}
			break;

		default:
			break;
	}
}

@end
