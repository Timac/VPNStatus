//
//  NSBundle+ACAppInfo.m
//
//  Created by Alexandre Colucci on 06.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.

#import "NSBundle+ACAppInfo.h"
#import <Foundation/Foundation.h>

@implementation NSBundle (ACAppInfo)

+(nonnull NSString *)acBundleIdentifier
{
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	if([bundleIdentifier length] > 0)
	{
		return bundleIdentifier;
	}
	
	return @"";
}

+(nonnull NSString *)acAppName
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *appName = infoDictionary[(NSString *)kCFBundleNameKey];
	if([appName length] > 0)
	{
		return appName;
	}
	
	return @"";
}

+(nonnull NSString *)acAppShortVersion
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *appShortVersion = infoDictionary[@"CFBundleShortVersionString"];
	if([appShortVersion length] > 0)
	{
		return appShortVersion;
	}
	
	return @"";
}

+(nonnull NSString *)acAppVersion
{
	NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
	NSString *appVersion = infoDictionary[(NSString *)kCFBundleVersionKey];
	if([appVersion length] > 0)
	{
		return appVersion;
	}
	
	return @"";
}

+(nonnull NSString *)acAppDisplayVersion
{
	NSString *appShortVersion = [NSBundle acAppShortVersion];
	NSString *appVersion = [NSBundle acAppVersion];
	if (([appShortVersion length] > 0) && ([appVersion length] > 0))
	{
		return [NSString stringWithFormat:@"%1$@ (%2$@)", appShortVersion, appVersion];
	}
	else if ([appShortVersion length] > 0)
	{
		return appShortVersion;
	}
	if ([appVersion length] > 0)
	{
		return appVersion;
	}
	
	return @"";
}

+(nonnull NSString *)acAppNameAndDisplayVersion
{
	NSString *appName = [NSBundle acAppName];
	NSString *appDisplayVersion = [NSBundle acAppDisplayVersion];
	if (([appName length] > 0) && ([appDisplayVersion length] > 0))
	{
		return [NSString stringWithFormat:@"%1$@ %2$@", appName, appDisplayVersion];
	}
	else if ([appName length] > 0)
	{
		return appName;
	}
	if ([appDisplayVersion length] > 0)
	{
		return appDisplayVersion;
	}
	
	return @"";
}

@end
