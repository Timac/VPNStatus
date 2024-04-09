//
//  NSBundle+ACAppInfo.h
//
//  Created by Alexandre Colucci on 06.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBundle (ACAppInfo)

+(nonnull NSString *)acBundleIdentifier;
+(nonnull NSString *)acAppName;

+(nonnull NSString *)acAppShortVersion;
+(nonnull NSString *)acAppVersion;
+(nonnull NSString *)acAppDisplayVersion;

+(nonnull NSString *)acAppNameAndDisplayVersion;

@end

