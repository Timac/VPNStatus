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

NSString * const kSkipVersionPrefKey = @"SkipVersion";


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
			break;
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
    return [ignoredSSIDsString componentsSeparatedByString:@","];
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

-(NSString *)checkForUpdateSkipVersion
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:kSkipVersionPrefKey];
}

-(void)setCheckForUpdateSkipVersion:(NSString *)version
{
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:kSkipVersionPrefKey];
}

@end
