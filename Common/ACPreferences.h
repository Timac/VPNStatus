//
//  ACPreferences.h
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//
//	This class is used to deal with the application preferences.

#import <Cocoa/Cocoa.h>

extern NSString * const kACConfigurationDidChange;
extern NSString * const kACMenuBarImageDidChange;

@interface ACPreferences : NSObject

/**
 Get the singleton object
 */
+ (ACPreferences *)sharedPreferences;


/**
 Return the list of VPN service identifiers that have been set to auto connect
 */
-(NSArray<NSString *>*)alwaysConnectedServicesIdentifiers;

/**
 Return the list of ignored SSIDs for the current service identifier
 */
-(NSArray<NSString *>*)ignoredSSIDs;
-(void)setIgnoredSSIDs:(NSArray<NSString *> *)ignoredSSIDs;


/**
 Return the list of VPN to ignore
 */
-(NSArray<NSString *>*)ignoredVPNs;
-(void)setIgnoredVPNs:(NSArray<NSString *> *)ignoredVPNs;


/**
 Enable or disable auto connect for the VPN service
 */
-(void)setAlwaysConnected:(BOOL)inAlwaysConnected forServicesIdentifier:(NSString *)inServiceIdentifier;


/**
 How often should we retry to connect to the VPN?
 Default is 120s
 */
-(NSInteger)alwaysConnectedRetryDelay;
-(void)setAlwaysConnectedRetryDelay:(NSInteger)retryDelay;


/**
 Disable the check for updates
 */
-(BOOL)disabledCheckForUpdatesAutomatically;
-(void)setDisabledCheckForUpdatesAutomatically:(BOOL)inValue;


/**
 Enable auto connecting to max one service.
 */
-(BOOL)singleAutoConnect;
-(void)setSingleAutoConnect:(BOOL)inValue;


/**
 Menu Bar Images
 */

typedef NS_ENUM(NSInteger, MenuBarImageType) {
	MenuBarImageType_Colors,
	MenuBarImageType_Cloud
};

typedef NS_ENUM(NSInteger, MenuBarImageState) {
	MenuBarImageState_Off,
	MenuBarImageState_On,
	MenuBarImageState_Pause
};

-(MenuBarImageType)menuBarImageType;
-(void)setMenuBarImageType:(MenuBarImageType)menuBarImageType;
+(NSImage *)menuBarImageForState:(MenuBarImageState)inState;
+(NSImage *)menuBarImageForState:(MenuBarImageState)inState andType:(MenuBarImageType)inType;

@end

