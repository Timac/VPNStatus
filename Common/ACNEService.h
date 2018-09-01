//
//  ACNEService.h
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//
//	The ACNEService class replicates the ANPNEService class from Network.prefPane
//	The initializer takes a NEConfiguration object from the NetworkExtension.framework.
//
//

#import <Foundation/Foundation.h>
#import "ACDefines.h"

@interface ACNEService : NSObject

@property (retain) NEConfiguration * configuration;
@property (assign) ne_session_t session;

// Use to ensure we got the session status
@property (assign) BOOL gotInitialSessionStatus;

@property (assign) ne_session_status_t sessionStatus;

// init
- (instancetype)initWithConfiguration:(NEConfiguration *)inConfiguration;

// Access information
-(NSString *)name;
-(NSString *)serverAddress;
-(NSString *)protocol;

// Refresh and get the state of the session
-(void)refreshSession;
-(SCNetworkConnectionStatus)state;

// Connect and disconnect
-(void)connect;
-(void)disconnect;

@end

