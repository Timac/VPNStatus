//
//  ACNEService.m
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

#import "ACNEService.h"
#import "ACNEServicesManager.h"

@implementation ACNEService

- (instancetype)initWithConfiguration:(NEConfiguration *)inConfiguration
{
    self = [super init];
    if (self)
    {
        _configuration = inConfiguration;
		_gotInitialSessionStatus = NO;
		
        // Get the configuration identifier to initialize the ne_session_t
        NSUUID *uuid = [inConfiguration identifier];
		uuid_t uuidBytes;
		[uuid getUUIDBytes:uuidBytes];
		
        // Create the ne_session
        _session = ne_session_create(uuidBytes, NESessionTypeVPN);
		
		// Setup the callbacks
        [self setupEventCallback];
        [self refreshSession];
    }
    
    return self;
}

- (void)dealloc
{
	ne_session_set_event_handler(_session, [[ACNEServicesManager sharedNEServicesManager] neServiceQueue], ^(xpc_object_t result)
	{
		// Nothing
	});
	
	// Cancel and release the session
	ne_session_cancel(_session);
	ne_session_release(_session);
}

-(NSString *)name
{
	return _configuration.name;
}

-(NSString *)serverAddress
{
	return _configuration.VPN.protocol.serverAddress;
}

-(NSString *)protocol
{
	NEVPNProtocol *protocol = _configuration.VPN.protocol;
	if([protocol isKindOfClass:[NEVPNProtocolIKEv2 class]])
	{
		return @"IKEv2";
	}
	else if([protocol isKindOfClass:[NEVPNProtocolIPSec class]])
	{
		return @"IPSec";
	}
	else if([[protocol className] isEqualToString:@"NEVPNProtocolL2TP"])
	{
		// The NEVPNProtocolL2TP is a private class of the public NetworkExtension.framework
		return @"L2TP";
	}
	
	// Fallback to catch future protocols?
	NSString *className = [protocol className];
	if([className hasPrefix:@"NEVPNProtocol"])
	{
		return [className substringFromIndex:[@"NEVPNProtocol" length]];
	}
	
	
	return @"Unknown";
}

-(SCNetworkConnectionStatus)state
{
	if(self.gotInitialSessionStatus)
	{
		return SCNetworkConnectionGetStatusFromNEStatus(self.sessionStatus);
	}
	else
	{
		return kSCNetworkConnectionInvalid;
	}
}

-(void)setupEventCallback
{
	ne_session_set_event_handler(_session, [[ACNEServicesManager sharedNEServicesManager] neServiceQueue], ^(xpc_object_t result)
	{
		[self refreshSession];
	});
}

-(void)refreshSession
{
	ne_session_get_status(_session, [[ACNEServicesManager sharedNEServicesManager] neServiceQueue], ^(ne_session_status_t status)
	{
		dispatch_async(dispatch_get_main_queue(), ^
		{
			self.sessionStatus = status;
			self.gotInitialSessionStatus = YES;
			
			// Post a notification to refresh the UI
			[[NSNotificationCenter defaultCenter] postNotificationName:kSessionStateChangedNotification object:nil];
		});
	});
}

-(void)connect
{
	ne_session_start(_session);
}

-(void)disconnect
{
	ne_session_stop(_session);
}

@end

