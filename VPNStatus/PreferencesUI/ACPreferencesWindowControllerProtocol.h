//
//  ACPreferencesWindowControllerProtocol.h
//
//  Created by Alexandre Colucci on 06.04.2024.
//  Copyright © 2024 Alexandre Colucci. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ACPreferencesWindowControllerProtocol <NSObject>

@required

@property (nonatomic, readonly, strong, nonnull) NSString *identifier;
@property (nonatomic, readonly, strong, nonnull) NSString *title;

@end
