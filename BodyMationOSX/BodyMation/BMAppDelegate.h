//
//  BMAppDelegate.h
//  BodyMation
//
//  Created by Kevin Bell on 10/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BMWindowController;
@class BMPreferenceWindowController;
@class BMRegisterWindowController;

@interface BMAppDelegate : NSObject <NSApplicationDelegate>

@property BMWindowController *windowController;
@property BMPreferenceWindowController *preferenceWindowController;
@property BMRegisterWindowController *registerWindowController;

// Provided by template
@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)registerMenuItemSelected:(id)sender;
- (IBAction)buyNowMenuItemSelected:(id)sender;

- (IBAction)preferencesMenuItemSelected:(id)sender;
- (IBAction)saveAction:(id)sender;

- (void)openPreferenceWindowController;

@end
