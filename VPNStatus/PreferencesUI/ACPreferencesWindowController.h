//
//  ACPreferencesWindowController.h
//
//  Created by Alexandre Colucci on 06.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ACPreferencesWindowControllerProtocol.h"

@interface ACPreferencesWindowController : NSWindowController

+ (ACPreferencesWindowController *)sharedWindowController;

@property (nonatomic, strong) NSArray<ACPreferencesWindowControllerProtocol> *viewControllers;
@property (weak, nonatomic) NSViewController <ACPreferencesWindowControllerProtocol> *selectedViewController;

-(instancetype)initPreferencesWindow;

@end

