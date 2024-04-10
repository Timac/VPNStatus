#import "ACCheckForUpdateWindow.h"
#import "ACPreferences.h"

@interface ACCheckForUpdateWindow ()

@property (weak) IBOutlet NSTextField *versionsLabel;

@property (strong) NSString *currentVersion;
@property (strong) NSString *updateVersion;

@end

@implementation ACCheckForUpdateWindow

+ (ACCheckForUpdateWindow *)sharedWindowController
{
	static ACCheckForUpdateWindow *sharedWindowController = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedWindowController = [[self alloc] initCheckForUpdateWindow];
	});

	return sharedWindowController;
}

-(instancetype)initCheckForUpdateWindow
{
	self = [super initWithWindowNibName:@"ACCheckForUpdateWindow"];
	if (self)
	{
	}

	return self;
}

- (IBAction)showWindow:(id)sender
{
	[super showWindow:sender];

	[self.versionsLabel setStringValue:[NSString stringWithFormat:@"VPNStatus %@ is now available, you have %@.", self.updateVersion, self.currentVersion]];
}

-(void)showUpdateAvailable:(NSString *)oldVersion newVersion:(NSString*)newVersion
{
	self.currentVersion = oldVersion;
	self.updateVersion = newVersion;
	[self showWindow:self];
}

-(IBAction)doRemindMeLater:(id)sender
{
	[self close];
}

-(IBAction)doSkipThisVersion:(id)sender
{
	[[ACPreferences sharedPreferences] setCheckForUpdateSkipVersion:self.updateVersion];
	[self close];
}

-(IBAction)doInstallUpdate:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/Timac/VPNStatus/releases"]];
	[self close];
}

@end
