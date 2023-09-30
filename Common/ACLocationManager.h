//
//  ACLocationManager.h
//  VPNApp
//
//  Created by Alexandre Colucci on 30.09.2023.
//  Copyright © 2023 Timac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const kACLocationManagerAuthorizationDidChange;

@interface ACLocationManager : NSObject

+ (ACLocationManager*) sharedLocationManager;

- (CLAuthorizationStatus)authorizationStatus;

- (void)requestAlwaysAuthorizationIfNeeded;

@end

