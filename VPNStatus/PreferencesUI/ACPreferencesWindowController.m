//
//  ACPreferencesWindowController.m
//
//  Created by Alexandre Colucci on 06.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.

#import "ACPreferencesWindowController.h"

#import "ACPreferencesGeneralViewController.h"
#import "ACPreferencesAboutViewController.h"
#import "ACPreferencesIgnoredViewController.h"

@interface ACPreferencesWindowController () <NSToolbarDelegate>

@property (weak) IBOutlet NSToolbar *toolbar;

@property (strong) ACPreferencesGeneralViewController *generalViewController;
@property (strong) ACPreferencesAboutViewController *aboutViewController;
@property (strong) ACPreferencesIgnoredViewController *ignoredViewController;

@end


@implementation ACPreferencesWindowController

+ (ACPreferencesWindowController *)sharedWindowController
{
	static ACPreferencesWindowController *sharedWindowController = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedWindowController = [[self alloc] initPreferencesWindow];
	});

	return sharedWindowController;
}

-(instancetype)initPreferencesWindow
{
	self = [super initWithWindowNibName:@"ACPreferencesWindow"];
	if (self)
	{
		_generalViewController = [[ACPreferencesGeneralViewController alloc] initViewController];
		_aboutViewController = [[ACPreferencesAboutViewController alloc] initViewController];
		_ignoredViewController = [[ACPreferencesIgnoredViewController alloc] initViewController];
	}
	
	[self.window setReleasedWhenClosed:NO];
	
	return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	// Default
	[self changeToViewController:self.generalViewController animated:NO];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return @[	[self.generalViewController identifier],
				[self.ignoredViewController identifier],
				[self.aboutViewController identifier],
				@"NSToolbarFlexibleSpaceItem"
			];
}

-(void)resizeWindowForContentSize:(NSSize)size animated:(BOOL)animated completionHandler:(nullable void (^)(void))completionHandler
{
    NSWindow *window = self.window;
    
    // Calculate the new window frame
    NSRect contentFrame = [window contentRectForFrameRect:window.frame];
    NSRect newContentFrame = contentFrame;
	newContentFrame.size = size;
	newContentFrame.origin.y = NSMaxY(contentFrame) - size.height;
	NSRect newWindowFrame = [self.window frameRectForContentRect:newContentFrame];
    
    if(animated)
    {
		// Animate to the new window frame
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context)
		{
			[context setDuration: 0.2];
			[[window animator] setFrame:newWindowFrame display:YES];
		} completionHandler:^{
			if(completionHandler != nil)
			{
				completionHandler();
			}
		}];
	}
	else
	{
		[window setFrame:newWindowFrame display:YES];
		if(completionHandler != nil)
		{
			completionHandler();
		}
	}
}


-(void)changeToViewController:(NSViewController <ACPreferencesWindowControllerProtocol> *)inViewController animated:(BOOL)animated
{
	NSViewController *oldViewController = self.selectedViewController;
	if(oldViewController != inViewController)
	{
		[self.toolbar setSelectedItemIdentifier:[inViewController identifier]];
		
		NSViewController *newViewController = inViewController;
		
		[newViewController.view setFrameOrigin:NSMakePoint(0, 0)];
        (newViewController.view).autoresizingMask = NSViewMaxXMargin|NSViewMaxYMargin|NSViewMinXMargin|NSViewMinYMargin;
		
		[self.window setTitle:[inViewController title]];
		
		if (oldViewController != nil)
		{
			[oldViewController.view setAlphaValue:0.0];
			[newViewController.view setAlphaValue:0.0];
            [[self.window.contentView animator] replaceSubview:oldViewController.view with:newViewController.view];
        }
        else
        {
			[newViewController.view setAlphaValue:0.0];
            [[self.window.contentView animator] addSubview:newViewController.view];
        }
        
		[self resizeWindowForContentSize:newViewController.view.bounds.size animated:animated completionHandler:^{
			[newViewController.view setAlphaValue:1.0];
		}];
		
		self.selectedViewController = inViewController;
	}
}

-(IBAction)doGeneral:(id)sender
{
	[self changeToViewController:self.generalViewController animated:YES];
}

-(IBAction)doIgnored:(id)sender
{
	[self changeToViewController:self.ignoredViewController animated:YES];
}

-(IBAction)doAbout:(id)sender
{
	[self changeToViewController:self.aboutViewController animated:YES];
}

@end
