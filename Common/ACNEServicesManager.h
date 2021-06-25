//
//  ACNEServicesManager.h
//  VPN
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//
//	The ACNEServicesManager class replicates the ANPNEServicesManager class from Network.prefPane
//

#import <Foundation/Foundation.h>

@class ACNEService;
@class NEConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface ACNEServicesManager : NSObject

@property (strong, nonnull) NSMutableArray <ACNEService*>* neServices;
@property (readonly, nonatomic, nonnull) dispatch_queue_t neServiceQueue;

/**
 Get the singleton object
 */
+ (nonnull ACNEServicesManager *)sharedNEServicesManager;


/**
 Load the NEConfigurations from NetworkExtension.framework
 */
-(void) loadConfigurationsWithHandler:(void (^)(NSError * _Nullable error))handler;

@end

NS_ASSUME_NONNULL_END
