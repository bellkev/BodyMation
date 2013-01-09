//
//  BMAppDelegate.m
//  BodyMation
//
//  Created by Kevin Bell on 10/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMAppDelegate.h"
#import "BMWindowController.h"
#import "BMPreferenceWindowController.h"
#import "BMRegisterWindowController.h"
#import "BMKeyChecker.h"
#import "BMSeriesWindowController.h"
#import "BMTutorialWindowController.h"
#import "BMUtilities.h"
#import "CFobLicVerifier.h"
#import "BMSeries.h"
#import "BMCaptureController.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark String Constants
static NSString* const BMTutorialMessage1 = @"Alright! You took your first picture. "
                                            "Now the next time you take a picture "
                                            "you'll compare it with this one to make "
                                            "sure you're in exactly the same spot. Go "
                                            "ahead, try clicking \"Capture\" again now!";
static NSString* const BMTutorialMessage2 = @"Great! Now that you have more than one picture, "
                                            "you can press \"Play\" any time to watch "
                                            "a movie of your body changing!\n(It'll be "
                                            "kind of boring now, but keep taking pictures!)";
#pragma mark -

@interface BMAppDelegate ()
- (void)setActiveCameraMenuItem:(NSMenuItem *)item;
@end

@implementation BMAppDelegate

@synthesize windowController;
@synthesize preferenceWindowController;
@synthesize seriesWindowController;
@synthesize tutorialWindowController;
@synthesize licenseVerifier;
@synthesize captureController;
@synthesize videoDevices;
@synthesize currentVideoDevice;
@synthesize cameraMenu;
@synthesize isFullVersion;

// Generated
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Register user defaults
    [self setupPreferences];
    
    // Setup license verification
    [self setLicenseVerifier:[[CFobLicVerifier alloc]init]];
    NSError *error;
    NSString *publicKey = [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----\n"
                           "MIIBtjCCASsGByqGSM44BAEwggEeAoGBAJiFLSHcXoZdhjKmPB6Lronx/mlIurNz\n"
                           "S4M3A5AXhR6d9+e01XmtM4OeuIGlD6XgrcrKWlzppwcSm1FZUj5+Nzk3Hzt/ilx6\n"
                           "S6n9eeu4rh8WXme6kV4+lxUSH3yQ742hxOcj2FKLJb8CZ1z7uTMHxpKqgu/NbgPn\n"
                           "6mDBdWkgkYaFAhUAiDmGvK9+ddM3PKqylXLTuo8wVaECgYAFFI0X4uvpP9RxeLra\n"
                           "UPqQzHqHOsVzeTKsbAHXMD/BOCMmDb54fqTyMe3bztF/gjQ4xNMxEbWpqQ7rFniW\n"
                           "ts0ivVGv3NBa1FULuWWWih3BKHyHyS4i79IjDMJGBldaBuPSceYBg73B/bV/zrzQ\n"
                           "7iKxr3WbXSczqXjRBPQbgVGVLgOBhAACgYA3I0CvURVwMEHOUx+lQY2V1eELbNQ6\n"
                           "HcEfdWz8J2s3xNBR3sYLbYN3R5+a0UTQ4nRzLC745nhF+jzJRObtJoqyfUgG2pX5\n"
                           "mrNesuX9JkgcemqAF58TYxzFlOMt/GymzkfI4LPmU4wrfNHqGDe1WRQtCXEwtnTv\n"
                           "qb2eHV5JhC14/A==\n"
                           "-----END PUBLIC KEY-----"];
    if (error)
    {
        NSLog(@"%@", error);
    }
    [[self licenseVerifier] setPublicKey:publicKey error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    // Check stored license
    NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:@"email"];
    NSString *license = [[NSUserDefaults standardUserDefaults] valueForKey:@"license"];
    [self setIsFullVersion:[[self licenseVerifier] verifyRegCode:license forName:email error:&error]];
    if (error)
    {
        NSLog(@"%@", error);
    }
    
    // Setup capture controller
    [self setCaptureController:[[BMCaptureController alloc] init]];
    [self setCurrentVideoDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]];
    [[self captureController] setInputDevice:[self currentVideoDevice]];
    [self updateCameras:[NSNotification notificationWithName:@"note" object:nil]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCameras:) name:AVCaptureDeviceWasConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCameras:) name:AVCaptureDeviceWasDisconnectedNotification object:nil];
    
    // Launch main window
    windowController = [[BMWindowController alloc] initWithWindowNibName:@"BMWindowController"];
    [windowController showWindow:nil];
    
    // Observe core data notifications for displaying tutorial window
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTutorial:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

- (void)updateCameras:(NSNotification *)notification {
    [self setVideoDevices:[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]];
    if (![[self videoDevices] containsObject:[self currentVideoDevice]]) {
        [self setCurrentVideoDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]];
        [[self captureController] setInputDevice:[self currentVideoDevice]];
    }
    // TODO: Handle the case where there is no video device
    [[self cameraMenu] removeAllItems];
    for (AVCaptureDevice *device in [self videoDevices]) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[device localizedName] action:@selector(cameraMenuItemSelected:) keyEquivalent:@""];
        [item setRepresentedObject:device];
        if (device == [self currentVideoDevice] ) {
            [item setState:NSOnState];
        }
        [[self cameraMenu] addItem:item];
    }
}

- (void)checkTutorial:(NSNotification *)notification {
    // Don't display if an image was deleted
    if ([[notification userInfo] objectForKey:NSInsertedObjectsKey]) {
        NSInteger imageCount = [[[[self windowController] currentSeries] images] count];
        NSString *message = nil;
        switch (imageCount) {
            case 1:
                message = BMTutorialMessage1;
                break;
            case 2:
                message = BMTutorialMessage2;
                break;
            default:
                break;
        }
        if (message) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[BMAppDelegate instanceMethodSignatureForSelector:@selector(openTutorialWindowControllerWithMessage:)]];
            [invocation setTarget:self];
            [invocation setSelector:@selector(openTutorialWindowControllerWithMessage:)];
            [invocation setArgument:&message atIndex:2];
            [NSTimer scheduledTimerWithTimeInterval:2.0f invocation:invocation repeats:NO];
        }
    }
}

- (CGSize)currentResolution {
    CMVideoFormatDescriptionRef videoDescription = [[[self currentVideoDevice] activeFormat] formatDescription];
    // TODO: research what exactly "clean aperture" and "pixel aspect ration" parameters below mean
    return CMVideoFormatDescriptionGetPresentationDimensions(videoDescription, YES, YES);
}

- (void)cameraMenuItemSelected:(id)sender {
    NSMenuItem *item = sender;
    [self setActiveCameraMenuItem:item];
    AVCaptureDevice *device = [item representedObject];
    [self setCurrentVideoDevice:device];
    [[self captureController] setInputDevice:[self currentVideoDevice]];
}

- (void)setActiveCameraMenuItem:(NSMenuItem *)item {
    for (NSMenuItem *currentItem in [[self cameraMenu] itemArray]) {
        [currentItem setState:NSOffState];
    }
    [item setState:NSOnState];
}

// Preference window controller
- (void)openPreferenceWindowController {
    if (![self preferenceWindowController]) {
        [self setPreferenceWindowController:[[BMPreferenceWindowController alloc] initWithWindowNibName:@"BMPreferenceWindowController"]];
    }
    [[self preferenceWindowController] showWindow:nil];
}

- (IBAction)preferencesMenuItemSelected:(id)sender {
    [self openPreferenceWindowController];
}

// Register window controller
- (void)openRegisterWindowController {
    if (![self registerWindowController]) {
        [self setRegisterWindowController:[[BMRegisterWindowController alloc] initWithWindowNibName:@"BMRegisterWindowController"]];
    }
    [[self registerWindowController] showWindow:nil];
}

- (IBAction)registerMenuItemSelected:(id)sender {
    [self openRegisterWindowController];
}

// Series window controller
- (void)openSeriesWindowController {
    if (![self seriesWindowController]) {
        [self setSeriesWindowController:[[BMSeriesWindowController alloc] initWithWindowNibName:@"BMSeriesWindowController"]];
    }
    [[self seriesWindowController] showWindow:nil];
}

// Tutorial window controller
- (void)openTutorialWindowControllerWithMessage:(NSString *)message {
    if (![self tutorialWindowController]) {
        [self setTutorialWindowController:[[BMTutorialWindowController alloc] initWithWindowNibName:@"BMTutorialWindowController"]];
    }
    NSLog(@"Label: %@", tutorialWindowController.instructionLabel);
    [[self tutorialWindowController] setInstructionText:message];
    // Position tutorial window in upper left
    NSRect mainWindowRect = [[[self windowController] window] frame];
    NSRect contentViewRect = [[[[self windowController] window] contentView] frame];
    NSPoint mainWindowOrigin = mainWindowRect.origin;
    NSRect tutorialRect = [[[self tutorialWindowController] window] frame];
    NSPoint tutorialOrigin;
    tutorialOrigin.x = mainWindowOrigin.x + contentViewRect.size.width - tutorialRect.size.width;
    tutorialOrigin.y = mainWindowOrigin.y + contentViewRect.size.height - tutorialRect.size.height;
    [[[self tutorialWindowController] window] setFrameOrigin:tutorialOrigin];
    [[self tutorialWindowController] showWindow:nil];
}
- (void)setupPreferences {
    NSMutableDictionary* defaultSettings = [[NSMutableDictionary alloc] init];
    // (Add everything as top level objects so they can be bound to
    // from preference window controller
    // Capture settings
    [defaultSettings setObject:[NSNumber numberWithInt:60] forKey:@"CountDownLength"];
    [defaultSettings setObject:[NSNumber numberWithInt:20] forKey:@"CountDownLengthInitial"];
    [defaultSettings setObject:[NSNumber numberWithFloat:1.0] forKey:@"ComparePeriod"];
    [defaultSettings setObject:[NSNumber numberWithFloat:0.3] forKey:@"CompareTime"];
    [defaultSettings setObject:[NSNumber numberWithInt:0] forKey:@"CameraRotationIndex"];
    // Playback settings
    [defaultSettings setObject:[NSNumber numberWithInt:10] forKey:@"FrameRate"];
    [defaultSettings setObject:[NSNumber numberWithBool:NO]forKey:@"ManualFrameRate"];
    // Other settings
    [defaultSettings setObject:@"" forKey:@"DefaultSeriesName"];
    [defaultSettings setObject:@"" forKey:@"email"];
    [defaultSettings setObject:@"" forKey:@"license"];
    // Register
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultSettings];
    // RESET FOR TEST PURPOSES:
    //[[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:defaultSettings];
}


// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "onzots.com.BodyMation" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.onzots.BodyMation"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BodyMation" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"BodyMation.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    // Make persistentStoreCoordinator perform automatic upgrades
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:options error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

- (IBAction)buyMenuItemSelected:(id)sender {
    [BMUtilities buyNow];
}

- (IBAction)buyNowMenuItemSelected:(id)sender {
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save default series
    NSLog(@"Current series at quit: %@", [[[self windowController] currentSeries] name]);
    [[NSUserDefaults standardUserDefaults] setValue:[[[self windowController] currentSeries] name] forKey:@"DefaultSeriesName"];
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
