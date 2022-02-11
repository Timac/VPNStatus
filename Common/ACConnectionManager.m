//
//  ACConnectionManager.m
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

#import "ACConnectionManager.h"
#import "ACNEService.h"
#import "ACNEServicesManager.h"
#import "ACPreferences.h"

// To get the current WiFi SSID (CWInterface)
#import "CoreWLAN/CoreWLAN.h"

@interface ACConnectionManager ()

// Timer to try to reconnect services set to always auto connect
@property (strong) NSTimer *alwaysAutoConnectTimer;

// Time when the pause for auto connect was started
@property (assign) CFAbsoluteTime startPauseTime;

// Duration of the pause
@property (assign) NSInteger pauseDuration;

@end


@implementation ACConnectionManager

+ (ACConnectionManager *)sharedManager
{
	static ACConnectionManager *sSharedManager = nil;
	if(sSharedManager == nil)
	{
		sSharedManager = [[ACConnectionManager alloc] init];
	}
	
	return sSharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self startAlwaysAutoConnectTimer];
    }
    return self;
}

-(void)toggleConnectionForService:(ACNEService *)inService
{
	if(inService == nil)
		return;
	
	SCNetworkConnectionStatus serviceState = [inService state];
	
	switch(serviceState)
	{
		case kSCNetworkConnectionDisconnected:
		{
			// Connect
			[inService connect];
		}
		break;
		
		case kSCNetworkConnectionConnected:
		{
			// Disconnect
			[inService disconnect];
		}
		break;
		
		default:
		break;
	}
}

-(void)startConnectionForService:(NSString *)inServiceIdentifier
{
	if([inServiceIdentifier length] <= 0)
		return;
	
	// Get all services and find the correct NEService
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	
	ACNEService *foundNEService = nil;
	for(ACNEService *neService in neServices)
	{
		if([inServiceIdentifier isEqualToString:[neService.configuration.identifier UUIDString]])
		{
			foundNEService = neService;
			break;
		}
	}
	
	// Connect to the service if it is currently disconnected
	if(foundNEService != nil)
	{
		if([foundNEService state] == kSCNetworkConnectionDisconnected)
		{
			[foundNEService connect];
		}
	}
}

-(void)startAlwaysAutoConnectTimer
{
	// Recreate the timer
	if(self.alwaysAutoConnectTimer != nil)
	{
		[self.alwaysAutoConnectTimer invalidate];
		self.alwaysAutoConnectTimer = nil;
	}
	
	self.alwaysAutoConnectTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:[[ACPreferences sharedPreferences] alwaysConnectedRetryDelay] repeats:YES block:^(NSTimer * timer)
	{
		// Each time the timer fires, execute this block
		if(![self isAutoConnectPaused])
		{
			NSArray<NSString *>*alwaysConnectedServicesIdentifiers = [[ACPreferences sharedPreferences] alwaysConnectedServicesIdentifiers];
			for(NSString *serviceIdentifier in alwaysConnectedServicesIdentifiers)
			{
				[self startConnectionForService:serviceIdentifier];
			}
		}
	}];
	
	// Add the timer to the RunLoop
	[[NSRunLoop currentRunLoop] addTimer:self.alwaysAutoConnectTimer forMode:NSDefaultRunLoopMode];
}

-(void)setAlwaysAutoConnect:(BOOL)inAlwaysAutoConnect forACNEService:(ACNEService *)inNEService
{
	if(inNEService == nil)
		return;
	
	// Save the preferences
	[[ACPreferences sharedPreferences] setAlwaysConnected:inAlwaysAutoConnect forServicesIdentifier:[inNEService.configuration.identifier UUIDString]];
	
	// Start the Timer
	[self startAlwaysAutoConnectTimer];
}

-(void)pauseAutoConnect:(NSInteger)inDuration
{
	self.startPauseTime = CFAbsoluteTimeGetCurrent();
	self.pauseDuration = inDuration;
}

-(void)resumeAutoConnect
{
	self.startPauseTime = 0;
	self.pauseDuration = 0;
}

-(BOOL)isAutoConnectPaused
{
	if(self.pauseDuration == NSIntegerMax)
	{
		return YES;
	}
	else if(self.startPauseTime + self.pauseDuration > CFAbsoluteTimeGetCurrent())
	{
		return YES;
	}
	
	return NO;
}

-(NSInteger)currentPauseDuration
{
	return self.pauseDuration;
}

-(BOOL)isAtLeastOneServiceSetToAutoConnect
{
	BOOL outCanEnableAutoConnect = NO;
	
	NSArray<NSString *>*alwaysConnectedServicesIdentifiers = [[ACPreferences sharedPreferences] alwaysConnectedServicesIdentifiers];
	if([alwaysConnectedServicesIdentifiers count] <= 0)
		return outCanEnableAutoConnect;
	
	// Check each service
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	for(ACNEService *neService in neServices)
	{
		if([alwaysConnectedServicesIdentifiers containsObject:[neService.configuration.identifier UUIDString]])
		{
			outCanEnableAutoConnect = YES;
			break;
		}
	}
	
	return outCanEnableAutoConnect;
}

-(void)disconnectAllAutoConnectedServices
{
	NSArray<NSString *>*alwaysConnectedServicesIdentifiers = [[ACPreferences sharedPreferences] alwaysConnectedServicesIdentifiers];
	if([alwaysConnectedServicesIdentifiers count] <= 0)
		return;
	
	// Disconnect each service marked as always auto connecting
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	for(ACNEService *neService in neServices)
	{
		if([alwaysConnectedServicesIdentifiers containsObject:[neService.configuration.identifier UUIDString]])
		{
			[neService disconnect];
		}
	}
}


/**
	Return YES if the current WiFi SSID is in the list of SSIDs to ignore
*/
-(BOOL)shouldPreventAutoConnectOnCurrentSSID
{
	// Assuming we have any Wi-Fi interfaces available...
	if([[CWWiFiClient interfaceNames] count] > 0)
	{
		CWInterface *wifi = [[CWWiFiClient sharedWiFiClient] interface];
		NSArray<NSString *>* ignoredSSIDs = [[ACPreferences sharedPreferences] ignoredSSIDs];

		// ...if the current SSID exists, and it's in the list of ignored SSIDs...
		if(wifi.ssid != nil && [ignoredSSIDs containsObject:wifi.ssid])
		{
			// ...do not connect.
			return YES;
		}
	}

	return NO;
}

-(void)connectAllAutoConnectedServices
{
	NSArray<NSString *>*alwaysConnectedServicesIdentifiers = [[ACPreferences sharedPreferences] alwaysConnectedServicesIdentifiers];
	if([alwaysConnectedServicesIdentifiers count] <= 0)
		return;
	
	// Connect each service marked as always auto connecting
	NSArray <ACNEService*>* neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
	for(ACNEService *neService in neServices)
	{
		if([alwaysConnectedServicesIdentifiers containsObject:[neService.configuration.identifier UUIDString]])
		{
            BOOL shouldConnect = YES;

            // If the current WiFi SSID is is the list of ignored SSID, we shouldn't auto connect
            if([self shouldPreventAutoConnectOnCurrentSSID])
            {
				shouldConnect = NO;
            }

            if(shouldConnect)
            {
				[neService connect];
            }
		}
	}
}

@end
