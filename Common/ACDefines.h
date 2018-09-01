//
//  ACDefines.h
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

// For xpc_object_t
#import <xpc/xpc.h>

// For SCNetworkConnectionStatus
#import <SystemConfiguration/SystemConfiguration.h>

// For NEVPNProtocol
#import <NetworkExtension/NetworkExtension.h>


//
// Define ne_session_status_t and ne_session_t
//
typedef int ne_session_status_t;
typedef struct ne_session_t *ne_session_t;


//
// Name found in SCNetworkConnection.c:
// See https://opensource.apple.com/source/configd/configd-963/SystemConfiguration.fproj/SCNetworkConnection.c.auto.html
//
#define NESessionTypeVPN	1

//
// Expose the ne_session_* APIs
// See /usr/lib/system/libsystem_networkextension.dylib
//
extern ne_session_t ne_session_create(uuid_t serviceID, int sessionConfigType);
extern void ne_session_release(ne_session_t session);
extern void ne_session_start(ne_session_t session);
extern void ne_session_stop(ne_session_t session);
extern void ne_session_cancel(ne_session_t session);

//
// Expose the ne_session_set_event_handler API
// See /usr/lib/system/libsystem_networkextension.dylib
//
typedef void (^ne_session_set_event_handler_block)(xpc_object_t result);
extern void ne_session_set_event_handler(ne_session_t session, dispatch_queue_t queue, ne_session_set_event_handler_block block);


//
// Expose the ne_session_get_status API
// See /usr/lib/system/libsystem_networkextension.dylib
//
typedef void (^ne_session_get_status_block)(ne_session_status_t result);
extern void ne_session_get_status(ne_session_t session, dispatch_queue_t queue, ne_session_get_status_block block);


//
// Expose SCNetworkConnectionGetStatusFromNEStatus available in SystemConfiguration
// See https://opensource.apple.com/source/configd/configd-963/SystemConfiguration.fproj/SCNetworkConnection.c.auto.html
//
extern SCNetworkConnectionStatus SCNetworkConnectionGetStatusFromNEStatus(ne_session_status_t status);


//
// Notification name used to refresh the UI
//
#define kSessionStateChangedNotification @"kSessionStateChangedNotification"


//
// Expose NEVPN in order to get information (server address, protocol)
// /System/Library/Frameworks/NetworkExtension.framework
//

@interface NEVPN : NSObject

@property (copy) NEVPNProtocol * protocol;

@end


//
// Expose NEConfiguration
// /System/Library/Frameworks/NetworkExtension.framework
//

@interface NEConfiguration : NSObject

@property (readonly) NSUUID * identifier;
@property (copy) NSString * name;
@property (copy) NEVPN * VPN;

@end


//
// Expose NEConfigurationManager
// /System/Library/Frameworks/NetworkExtension.framework
//

@interface NEConfigurationManager : NSObject

+ (id)sharedManager;
- (void)loadConfigurationsWithCompletionQueue:(dispatch_queue_t)completionQueue handler:(void (^)(NSArray<NEConfiguration *> * _Nullable configurations, NSError * _Nullable error))handler;

@end

