//
//  ACPreferencesAboutViewController.m
//
//  Created by Alexandre Colucci on 06.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.

#import "ACPreferencesAboutViewController.h"

@interface ACPreferencesAboutViewController ()

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
