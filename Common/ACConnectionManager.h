//
//  ACConnectionManager.h
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//
//	This class contains the logic to auto connect to a service
//

#import <Cocoa/Cocoa.h>

@class ACNEService;

@interface ACConnectionManager : NSObject


/**
 Get the singleton
 */
+ (ACConnectionManager *)sharedManager;


/**
 Connect or disconnect the VPN service based on its current state
 */
-(void)toggleConnectionForService:(ACNEService *)inService;

/**
 Save the preferences for the ACNEService and start the timer for auto connecting
 */
-(void)setAlwaysAutoConnect:(BOOL)inAlwaysAutoConnect forACNEService:(ACNEService *)inNEService;

/**
 Pause the auto connect feature for inDuration seconds
 */
-(void)pauseAutoConnect:(NSInteger)inDuration;

/**
 Resume auto connect
 */
-(void)resumeAutoConnect;

/**
 Has the auto connect feature been paused by the user?
 */
-(BOOL)isAutoConnectPaused;

/**
 If auto connect is paused, returns the duration set by the user
 */
-(NSInteger)currentPauseDuration;

/**
 Return YES if at least one VPN service has been set to auto connect
 */
-(BOOL)isAtLeastOneServiceSetToAutoConnect;


/**
 Disconnect all the services marked as always auto connect
 */
-(void)disconnectAllAutoConnectedServices;

/**
 Connect all the services marked as always auto connect
 */
-(void)connectAllAutoConnectedServices;

@end

