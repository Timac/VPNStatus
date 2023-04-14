//
//  main.m
//  vpnutil
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ACDefines.h"
#import "ACNEService.h"
#import "ACNEServicesManager.h"

static void PrintUsage(void)
{
	fprintf(stderr, "Usage: vpnutil [start|stop] [VPN name]\n");
	fprintf(stderr, "Examples:\n");
	fprintf(stderr, "\t To start the VPN called 'MyVPN':\n");
	fprintf(stderr, "\t vpnutil start MyVPN\n");
	fprintf(stderr, "\n");
	fprintf(stderr, "\t To stop the VPN called 'MyVPN':\n");
	fprintf(stderr, "\t vpnutil stop MyVPN\n");
	fprintf(stderr, "\n");
    fprintf(stderr, "\t To list all available VPNs and their state:\n");
    fprintf(stderr, "\t vpnutil list\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "\t To get the status of the VPN called 'MyVPN':\n");
    fprintf(stderr, "\t vpnutil status MyVPN\n");
    fprintf(stderr, "\n");
	fprintf(stderr, "Copyright © 2018-2021 Alexandre Colucci\nblog.timac.org\n");
	fprintf(stderr, "\n");
	
	exit(1);
}


static NSString * GetDescriptionForSCNetworkConnectionStatus(SCNetworkConnectionStatus inStatus)
{
	switch(inStatus)
	{
		case kSCNetworkConnectionInvalid:
		{
			return @"Invalid";
		}
		break;
		
		case kSCNetworkConnectionDisconnected:
		{
			return @"Disconnected";
		}
		break;
		
		case kSCNetworkConnectionConnecting:
		{
			return @"Connecting";
		}
		break;
		
		case kSCNetworkConnectionConnected:
		{
			return @"Connected";
		}
		break;
		
		case kSCNetworkConnectionDisconnecting:
		{
			return @"Disconnecting";
		}
		break;
		
		default:
		{
			return @"Unknown";
		}
		break;
	}
	
	return @"Unknown";
};

int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		
		// Do we want to start or stop the service?
		BOOL shouldStartService = YES;
        BOOL statusService = NO;
        BOOL needServiceName = NO;
        BOOL listService = NO;
        int numArgs = 0;

        if (argc <= 1)
        {
            PrintUsage();
        }
        
        NSString *parameter1 = [NSString stringWithUTF8String:argv[1]];
		if ([parameter1 isEqualToString:@"start"])
		{
			shouldStartService = YES;
            needServiceName = YES;
            numArgs = 3;
		}
		else if ([parameter1 isEqualToString:@"stop"])
		{
			shouldStartService = NO;
            needServiceName = YES;
            numArgs = 3;
		}
        else if ([parameter1 isEqualToString:@"list"])
        {
            needServiceName = NO;
            shouldStartService = NO;
            listService = YES;
            numArgs = 2;
        }
        else if ([parameter1 isEqualToString:@"status"])
        {
            statusService = YES;
            needServiceName = YES;
            shouldStartService = NO;
            listService = NO;
            numArgs = 3;
        }
		else
		{
			PrintUsage();
		}
		
        if (argc != numArgs)
        {
            PrintUsage();
        }
        
		// Get the VPN name?
        __block NSString *vpnName;
        if (needServiceName)
        {
            vpnName = [NSString stringWithUTF8String:argv[2]];
            if ([vpnName length] <= 0)
            {
                PrintUsage();
            }
        }
		
		// Since this is a command line tool, we manually run an NSRunLoop
		__block ACNEService *foundNEService = NULL;
		__block BOOL keepRunning = YES;
        __block NSArray <ACNEService*> *neServices = NULL;
        
		// Make sure that the ACNEServicesManager singleton is created and load the configurations
		[[ACNEServicesManager sharedNEServicesManager] loadConfigurationsWithHandler:^(NSError * error)
		{
			if(error != nil)
			{
				NSLog(@"Failed to load the configurations - %@", error);
			}
			
			neServices = [[ACNEServicesManager sharedNEServicesManager] neServices];
			if([neServices count] <= 0)
			{
				NSLog(@"Could not find any VPN");
			}
		
            for(ACNEService *neService in neServices)
            {
                if([neService.name isEqualToString:vpnName])
                {
                    foundNEService = neService;
                    break;
                }
            }
		
			if(needServiceName && !foundNEService)
			{
				// Stop running the NSRunLoop
				keepRunning = NO;
			}
		}];
		
		CFAbsoluteTime startWaiting = CFAbsoluteTimeGetCurrent();
		
		//
		// Wait:
		//	- until we receive the list of NEServices
		//	- until we get the session status of the NEService
		//	- at least 1s to ensure that the session status is valid
		//
		// Stop waiting:
		//	- after a timeout of 10s
		//	- if the list of NEServices doesn't contain the expected service
		//
		NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    	while(keepRunning && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate])
    	{
			timeoutDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
			//NSLog(@"Waiting...");
			
			// Timeout after 10s
			if(startWaiting + 10.0 < CFAbsoluteTimeGetCurrent())
			{
				//NSLog(@"Timeout...");
				keepRunning = NO;
			}
			
			// Ensure we wait at least 1s
			if(startWaiting + 1.0 < CFAbsoluteTimeGetCurrent())
			{
                if (needServiceName)
                {
                    if(foundNEService != nil && (foundNEService.gotInitialSessionStatus))
                    {
                        //NSLog(@"Found NEService and session state");
                        keepRunning = NO;
                    }
                }
                else
                {
                    // go through all services and keep running if we don't have a state for each service
                    keepRunning = NO;
                    for(ACNEService *neService in neServices)
                    {
                        if (!neService.gotInitialSessionStatus)
                        {
                            keepRunning = YES;
                        }
                    }
                }
			}
			else
			{
				//NSLog(@"Need to wait more...");
			}
		}
		
        if (listService)
        {
            for(ACNEService *neService in neServices)
            {
                printf("%s %s\n", [neService.name UTF8String], [GetDescriptionForSCNetworkConnectionStatus(neService.state) UTF8String]);
            }
        }
        else if(foundNEService)
		{
			SCNetworkConnectionStatus currentState = foundNEService.state;
			//NSLog(@"Got status %@", GetDescriptionForSCNetworkConnectionStatus(currentState));
			if(statusService)
            {
                printf("%s %s\n", [foundNEService.name UTF8String], [GetDescriptionForSCNetworkConnectionStatus(foundNEService.state) UTF8String]);
            }
			else if(shouldStartService)
			{
				if(currentState == kSCNetworkConnectionDisconnected)
				{
					// Connect
					[foundNEService connect];
					NSLog(@"%@ has been started", vpnName);
				}
				else
				{
					NSLog(@"%@ was not started because it was in the state '%@'", vpnName, GetDescriptionForSCNetworkConnectionStatus(currentState));
				}
			}
			else
			{
				if(currentState == kSCNetworkConnectionConnected)
				{
					// Disconnect
					[foundNEService disconnect];
					NSLog(@"%@ has been stopped", vpnName);
				}
				else
				{
					NSLog(@"%@ was not stopped because it was in the state '%@'", vpnName, GetDescriptionForSCNetworkConnectionStatus(currentState));
				}
			}
		}
		else
		{
			NSLog(@"Could not find %@", vpnName);
		}
	}
	
	return 0;
}
