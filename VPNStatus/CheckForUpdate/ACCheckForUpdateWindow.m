#import "ACCheckForUpdateWindow.h"
#import "ACPreferences.h"

@interface ACCheckForUpdateWindow ()

@property (weak) IBOutlet NSTextField *versionsLabel;
@property (weak) IBOutlet NSTextField *releaseNotesLabel;

@property (strong) NSString *currentVersion;
@property (strong) NSString *updateVersion;
@property (strong) NSString *releaseNotes;

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

	if([self.releaseNotes length] > 0)
	{
		[self.releaseNotesLabel setStringValue:self.releaseNotes];
	}
	else
	{
		[self.releaseNotesLabel setStringValue:@""];
	}
}

-(void)showUpdateAvailable:(NSString *)oldVersion newVersion:(NSString*)newVersion releaseNotes:(NSString*)releaseNotes
{
	self.currentVersion = oldVersion;
	self.updateVersion = newVersion;
	self.releaseNotes = releaseNotes;
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
