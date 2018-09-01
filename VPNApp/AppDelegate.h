//
//  AppDelegate.h
//  VPNApp
//
//  Created by Alexandre Colucci on 07.07.2018.
//  Copyright © 2018 Timac. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

// 'Connect' button clicked
-(IBAction)toggleConnection:(id)sender;

// 'Always Auto Connect' checkbox clicked
-(IBAction)alwaysAutoConnect:(id)sender;

// Popup selection changed
-(IBAction)popupButtonSelectionChange:(id)sender;

// Open the website
-(IBAction)openWebsite:(id)sender;

@end

