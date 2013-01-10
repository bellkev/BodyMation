//
//  BMAppDelegate.h
//  BodyMation
//
//  Created by Kevin Bell on 10/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@class BMWindowController;
@class BMPreferenceWindowController;
@class BMRegisterWindowController;
@class BMSeriesWindowController;
@class BMTutorialWindowController;
@class CFobLicVerifier;
@class BMCaptureController;
@class BMVideoProcessor;

@interface BMAppDelegate : NSObject <NSApplicationDelegate>

@property BMWindowController *windowController;
@property BMPreferenceWindowController *preferenceWindowController;
@property BMRegisterWindowController *registerWindowController;
@property BMSeriesWindowController *seriesWindowController;
@property BMTutorialWindowController *tutorialWindowController;
@property CFobLicVerifier *licenseVerifier;
@property BMCaptureController *captureController;
@property BMVideoProcessor *videoProcessor;
@property NSArray *videoDevices;
@property AVCaptureDevice *currentVideoDevice;
@property (weak) IBOutlet NSMenu *cameraMenu;
@property BOOL isFullVersion;

// Provided by template
@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)buyMenuItemSelected:(id)sender;
- (IBAction)registerMenuItemSelected:(id)sender;
- (IBAction)buyNowMenuItemSelected:(id)sender;

- (IBAction)preferencesMenuItemSelected:(id)sender;
- (IBAction)saveAction:(id)sender;

// Window methods
- (void)openPreferenceWindowController;
- (void)openSeriesWindowController;
- (void)openRegisterWindowController;
- (void)openTutorialWindowControllerWithMessage:(NSString *)message;

// Notification selectors
- (void)updateCameras:(NSNotification *)notification;
- (void)checkTutorial:(NSNotification *)notification;

// Camera-related methods
- (void)cameraMenuItemSelected:(id)sender;
- (CGSize)currentResolution;

@end
