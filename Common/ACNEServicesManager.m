//
//  ACNEServicesManager.m
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

#import "ACNEServicesManager.h"

#import "ACDefines.h"
#import "ACNEService.h"
#import "ACPreferences.h"

@implementation ACNEServicesManager

+ (ACNEServicesManager *)sharedNEServicesManager
{
	static ACNEServicesManager *sSharedNEServicesManager = nil;
	if(sSharedNEServicesManager == nil)
	{
		sSharedNEServicesManager = [[ACNEServicesManager alloc] init];
	}

	return sSharedNEServicesManager;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		// Create the dispatch queue
		_neServiceQueue = dispatch_queue_create("Network Extension service Queue", NULL);

		// Allocate the NEServices array
		_neServices = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) loadConfigurationsWithHandler:(void (^)(NSError * error))handler
{
	// Load the NEConfigurations
	[[NEConfigurationManager sharedManager] loadConfigurationsWithCompletionQueue:[self neServiceQueue] handler:^(NSArray<NEConfiguration *> * neConfigurations, NSError * error)
	{
		if(error != nil)
		{
			NSLog(@"ERROR loading configurations - %@", error);
			return;
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			// Process the configurations
			[self processConfigurations:neConfigurations];

			handler(error);
		});
	}];
}

- (void)processConfigurations:(NSArray <NEConfiguration*>*)inConfigurations
{
	// Fill the array
	[self.neServices removeAllObjects];

	NSArray<NSString *>* ignoredVPNs = [[ACPreferences sharedPreferences] ignoredVPNs];

	for(NEConfiguration *neConfiguration in inConfigurations)
	{
		if([ignoredVPNs containsObject:neConfiguration.name])
		{
			// Don't show the VPNs that should be ignored
			continue;
		}

		ACNEService *service = [[ACNEService alloc] initWithConfiguration:neConfiguration];
		[self.neServices addObject:service];
	}

	// Sort by name
	[self.neServices sortUsingComparator:^NSComparisonResult(ACNEService *obj1, ACNEService *obj2)
	{
		return [obj1.name compare:obj2.name];
	}];

	// Refresh the states
	for(ACNEService *neService in self.neServices)
	{
		[neService refreshSession];
	}
}

@end
