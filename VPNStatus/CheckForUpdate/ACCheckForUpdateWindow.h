#import <Cocoa/Cocoa.h>

@interface ACCheckForUpdateWindow : NSWindowController

+ (ACCheckForUpdateWindow *)sharedWindowController;
-(void)showUpdateAvailable:(NSString *)oldVersion newVersion:(NSString*)newVersion;

@end

