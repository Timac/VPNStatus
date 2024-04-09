//
//  ACPreferencesAboutViewController.m
//
//  Created by Alexandre Colucci on 06.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.

#import "ACPreferencesAboutViewController.h"
#import "NSBundle+ACAppInfo.h"

@interface ACPreferencesAboutViewController ()

@property (weak) IBOutlet NSTextField *versionLabel;
@property (weak) IBOutlet NSTextField *copyrightLabel;

@end


@implementation ACPreferencesAboutViewController

- (instancetype)initViewController
{
	self = [super initWithNibName:@"ACPreferencesAboutView" bundle:nil];
	if (self)
	{
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	NSString *appDisplayVersion = [NSBundle acAppDisplayVersion];
	if([appDisplayVersion length] > 0)
	{
		[self.versionLabel setStringValue:[NSString stringWithFormat:@"Version %@", appDisplayVersion]];
	}

	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
	NSInteger year = [components year];
	if(year > 0)
	{
		NSString *copyrightFormatString = @"Copyright © 2018-%d Alexandre Colucci\nhttps://blog.timac.org";
		[self.copyrightLabel setStringValue:[NSString stringWithFormat:copyrightFormatString, year]];
	}
}

-(NSString*)identifier
{
    return [[self title] lowercaseString];
}

-(NSString*)title
{
    return @"About";
}

-(IBAction)openGitHub:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Timac/VPNStatus"]];
}

-(IBAction)openBlog:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://blog.timac.org"]];
}

@end
