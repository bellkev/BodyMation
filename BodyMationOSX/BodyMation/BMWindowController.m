//
//  BMWindowController.m
//  BodyMation
//
//  Created by Kevin Bell on 10/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMWindowController.h"
#import "BMAppDelegate.h"
#import "BMBrowserViewController.h"
#import "BMCaptureViewController.h"
#import "BMPlayViewController.h"
#import "BMPreferenceWindowController.h"
#import "BMSeries.h"
#import "BMImage.h"
#import "BMUtilities.h"
#import "BMCaptureController.h"
#import "BMVideoProcessor.h"
#import "BMProcessingWindowController.h"
#import "BMTutorialWindowController.h"

@interface BMWindowController ()
- (void)openViewController:(NSViewController *)viewController;
- (void)setDefaultSeries:(NSNotification *)note;
- (void)invalidateMovie:(NSNotification *)note;
- (void)updateSeries;
- (void)exportPicturesOrMovie;
- (void)exportPictures;
- (void)exportMovie;
- (void)writeMovieFileAtURL:(NSURL *)url;
@end

@implementation BMWindowController

@synthesize shouldScrollToNewestImage;

// View Controllers
@synthesize currentViewController;
@synthesize browserViewController;
@synthesize captureViewController;
@synthesize playViewController;

// Other ivars
@synthesize seriesSortDescriptors;
@synthesize currentSeries;
@synthesize currentFramerate;
@synthesize currentManualFramerate;
@synthesize seriesArrayController;
@synthesize processingWindowController;

// Buttons
@synthesize seriesPopupButton;
@synthesize browseButton;
@synthesize captureButton;
@synthesize playButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Set self as delegate
        [[self window] setDelegate:self];
        // Initialization code here.
        [self setShouldScrollToNewestImage:YES];
        // Set sort type for series array controller
        NSSortDescriptor *sort;
        sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [self setSeriesSortDescriptors:[NSArray arrayWithObject:sort]];
        
        // Get some user defaults
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        // Setup updates to series property TODO: Bind this instead
        NSString *seriesName = [standardDefaults valueForKey:@"DefaultSeriesName"];
        [self setCurrentSeries:[BMSeries seriesForName:seriesName]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDefaultSeries:) name:NSWindowDidBecomeMainNotification object:[self window]];
        
        // Watch for updates that affect movie content
        [self setCurrentFramerate:[standardDefaults integerForKey:@"FrameRate"]];
        [self setCurrentManualFramerate:[standardDefaults boolForKey:@"ManualFrameRate"]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateMovie:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(invalidateMovie:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        // FOR TESTING
        //[[self currentSeries] setMovieIsCurrent:NO];
    }
    
    return self;
}

# pragma mark Window Delegate Methods
- (NSApplicationPresentationOptions)window:(NSWindow *)window willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions {
    return proposedOptions | NSApplicationPresentationAutoHideToolbar;
}

// Make image buttons gray out when window in background
- (void)windowDidResignMain:(NSNotification *)notification {
    for (NSButton *button in [self buttons]) {
        [button setAlphaValue:0.5f];
    }
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    for (NSButton *button in [self buttons]) {
        [button setAlphaValue:1.0f];
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    // Do this so that one tutorial window, etc. won't keep the app running
    [NSApp terminate:self];
}

# pragma mark -

- (void)windowDidLoad {
    [super windowDidLoad];

    // THIS WAS DUMB!!!://[[self window] setBackgroundColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0]];
    [self setButtons:[NSArray arrayWithObjects:browseButton, captureButton, playButton, nil]];
    [self openBrowserViewController];
    
}

- (void)setDefaultSeries:(NSNotification *)note {
    //NSLog(@"Notification: %@", note);
    [[self seriesPopupButton] selectItemWithTitle:[[self currentSeries] name]];
}

- (void)invalidateMovie:(NSNotification *)note {
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];
    NSInteger newFrameRate = [standardDefaults integerForKey:@"FrameRate"];
    BOOL newManualFrameRate = [standardDefaults boolForKey:@"ManualFrameRate"];
    if (insertedObjects) {
        // New image (or series) was added
        [[self currentSeries] setMovieIsCurrent:NO];
    }
    if (newFrameRate != [self currentFramerate]) {
        [self setCurrentFramerate:newFrameRate];
        [[self currentSeries] setMovieIsCurrent:NO];
    }
    if (newManualFrameRate != [self currentManualFramerate]) {
        [self setCurrentManualFramerate:newManualFrameRate];
        [[self currentSeries] setMovieIsCurrent:NO];
    }
    if (![[self currentSeries] movieIsCurrent]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MovieIsNotCurrent" object:self];
    }
}

- (void)createNewSeriesAfterInvalidName:(NSString *)invalidName {
    // Creates new series OPTIONALLY with prompt asking to choose a unique name
    // Workaround to make "New series..." behave like menu item
    [[self seriesPopupButton] selectItemWithTitle:[[self currentSeries] name]];
    NSAlert *alert = [NSAlert alertWithMessageText: @"Create Series"
                                     defaultButton:@"Create"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"Please choose a name for the new series"];
    if (invalidName) {
        [alert setInformativeText:[NSString stringWithFormat:@"Sorry, but there is already picture series named %@. Please choose another name for the new series.", invalidName]];
    }
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        NSString *newName = [input stringValue];
        // Check that the series name doesn't already exist
        if (![BMSeries checkIfSeriesExistsWithName:newName]) {
            // Save core data object
            BMSeries *newSeries = [BMSeries seriesInDefaultContext];
            [newSeries setName:newName];
            // Force notification about core data updates so popup button is updated
            NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
            [context processPendingChanges];
            [[self seriesPopupButton] selectItemWithTitle:newName];
            [self updateSeries];
        }
        else {
            [self createNewSeriesAfterInvalidName:newName];
        }
    }
    else {
        [[self seriesPopupButton] selectItemWithTitle:[[self currentSeries] name]];
    }
}

- (void)updateSeries {
    // TODO: validate this
    [self setCurrentSeries:[BMSeries seriesForName:[[[self seriesPopupButton] selectedItem] title]]];
    [self openBrowserViewController];
}

// View controller methods
- (void)openBrowserViewController {
    [self setActiveButton:[self browseButton]];
    if (![[self currentViewController] isKindOfClass:[BMBrowserViewController class]]) {
        if (![self browserViewController]) {
            [self setBrowserViewController:[[BMBrowserViewController alloc] initWithNibName:@"BMBrowserViewController" bundle:nil]];
        }
        [self openViewController:[self browserViewController]];
    }
}

- (void)openCaptureViewController {
    [self setActiveButton:[self captureButton]];
    if (![[self currentViewController] isKindOfClass:[BMCaptureViewController class]]) {
        if (![self currentSeries]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Create a Picture Series" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please create a picture series before taking a new picture"];
            [alert runModal];
            return;
        }
        if (![self captureViewController]) {
            [self setCaptureViewController:[[BMCaptureViewController alloc] initWithNibName:@"BMCaptureViewController" bundle:nil]];
        }
        else {
            [[self captureViewController] updateBeforeImage];
            [[[NSApp delegate] captureController] startCapture];
        }
        [self openViewController:[self captureViewController]];
    }
}

- (void)openPlayViewController {
    [self setActiveButton:[self playButton]];
    if (![[self currentViewController] isKindOfClass:[BMPlayViewController class]]) {
        if (![[[self currentSeries] images] count]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Take Some Pictures" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please take some pictures before trying to play your movie."];
            [alert runModal];
            return;
        }
        if (![self playViewController]) {
            [self setPlayViewController:[[BMPlayViewController alloc] initWithNibName:@"BMPlayViewController" bundle:nil]];
        }
        else if (![[[[NSApp delegate] windowController] currentSeries] movieIsCurrent]) {
            [[self playViewController] updateVideo];
        }
        [self openViewController:[self playViewController]];
    }
}


- (void)openViewController:(NSViewController *)viewController {
    // Scale new subview to window size
    [[viewController view] setFrame:[[[self window] contentView] bounds]];
    // Handle any necessary cleanup of current view
    if ([[self currentViewController] isKindOfClass:[BMCaptureViewController class]]) {
        [[[NSApp delegate] captureController] stopCapture];
    }
    // Swap to new view
    [[[self currentViewController] view] removeFromSuperview];
    [self setCurrentViewController:viewController];
    [[self currentViewController] setValue:self forKey:@"windowController"];
    [[[self window] contentView] addSubview:[[self currentViewController] view]];
}

// Toolbar button actions
- (IBAction)browseButtonPressed:(id)sender {
    [self openBrowserViewController];
}

- (IBAction)captureButtonPressed:(id)sender {
    BMAppDelegate *delegate = [NSApp delegate];
    if ([delegate isFullVersion] || [[[self currentSeries] images] count] < 30) {
        [self openCaptureViewController];
    }
    else {
        [[self captureButton] setState:NSOffState];
        NSAlert *upgradeAlert = [NSAlert alertWithMessageText:@"Upgrade to Full Version" defaultButton:@"Upgrade" alternateButton:@"Cancel" otherButton:@"Register" informativeTextWithFormat:@"Sorry, but you have reached the limit of 30 pictures in this series. Click \"Upgrade\" to get the full version now, or click \"Register\" to use a license key you already have."];
        NSInteger button = [upgradeAlert runModal];
        if (button == NSAlertDefaultReturn) {
            [BMUtilities buyNow];
        }
        else if (button == NSAlertOtherReturn) {
            [delegate openRegisterWindowController];
        }
    }
}

- (IBAction)playButtonPressed:(id)sender {
    [self openPlayViewController];
}

- (IBAction)preferencesButtonPressed:(id)sender {
    BMAppDelegate *delegate = [NSApp delegate];
    [delegate openPreferenceWindowController];
}

- (IBAction)chooseSeriesSelected:(id)sender {
    NSLog(@"Selected: %@", [[[self seriesPopupButton] selectedItem] title]);
    [self updateSeries];
}

- (IBAction)seriesNameMenuItemSelected:(id)sender {
    NSLog(@"Selected: %@", [[[self seriesPopupButton] selectedItem] title]);
    [self updateSeries];
}

- (IBAction)manageSeriesMenuItemSelected:(id)sender {
    // Workaround to make "Manage series..." behave like menu item
    NSLog(@"CurrentSeriesName before manage: %@", [[self currentSeries] name]);
    [[self seriesPopupButton] selectItemWithTitle:[[self currentSeries] name]];
    [[NSApp delegate] openSeriesWindowController];
}

- (IBAction)exportButtonPressed:(id)sender {
    BMAppDelegate *delegate = [NSApp delegate];
    if ([delegate isFullVersion]) {
        [self exportPicturesOrMovie];
    }
    else {
        NSAlert *upgradeAlert = [NSAlert alertWithMessageText:@"Upgrade to Full Version" defaultButton:@"Upgrade" alternateButton:@"Cancel" otherButton:@"Register" informativeTextWithFormat:@"Sorry, but you need to upgrade to the full version to be able to export your pictures or movies. Click \"Upgrade\" to get the full version now, or click \"Register\" to use a license key you already have."];
        NSInteger button = [upgradeAlert runModal];
        if (button == NSAlertDefaultReturn) {
            [BMUtilities buyNow];
        }
        else if (button == NSAlertOtherReturn) {
            [delegate openRegisterWindowController];
        }
    }
}

- (IBAction)newSeriesMenuItemSelected:(id)sender {
    [self createNewSeriesAfterInvalidName:nil];
}

// Other
- (void)setActiveButton:(NSButton *)activeButton {
    for (NSButton *button in [self buttons]) {
        [button setState:NSOffState];
    }
    [activeButton setState:NSOnState];
}

- (void)exportPicturesOrMovie {
    NSAlert *exportAlert = [NSAlert alertWithMessageText:@"Export" defaultButton:@"Movie" alternateButton:@"Cancel" otherButton:@"Pictures" informativeTextWithFormat:@"Would you like to export the movie or image files for the series \"%@\"?", [[self currentSeries] name]];
    NSInteger button = [exportAlert runModal];
    if (button == NSAlertDefaultReturn) {
        [self exportMovie];
    }
    else if (button == NSAlertOtherReturn) {
        [self exportPictures];
    }
}

- (void)exportPictures {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setTitle:@"Export Pictures"];
    [openPanel setPrompt:@"Export"];
    NSTextField *prompt = [[NSTextField alloc] init];
    [prompt setEditable:NO];
    [prompt setStringValue:@"Choose a name for the folder of exported pictures:"];
    [prompt setBezeled:NO];
    [prompt setDrawsBackground:NO];
    NSTextField *input = [[NSTextField alloc] init];
    [input setStringValue:[[[self currentSeries] name] stringByAppendingString:@" Pictures"]];
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 520, 24)];
    [view addSubview:prompt];
    [view addSubview:input];
    [prompt setFrame:NSMakeRect(0, 0, 320, 24)];
    [input setFrame:NSMakeRect(320, 0, 200, 24)];
    [openPanel setAccessoryView:view];
    NSInteger button = [openPanel runModal];
    if (button == NSFileHandlingPanelOKButton) {
        NSString *exportName = [input stringValue];
        NSURL *exportURL = [[openPanel URL] URLByAppendingPathComponent:exportName];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        exportURL = [BMUtilities getUniqueURLFromBaseURL:exportURL withManager:fileManager keepSortable:NO];
        NSError *error;
        [fileManager createDirectoryAtURL:exportURL withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        for (BMImage *image in [[self currentSeries] images]) {
            NSURL *imageURL = [exportURL URLByAppendingPathComponent:[image imageTitleNoSlashes]];
            imageURL = [imageURL URLByAppendingPathExtension:@"jpg"];
            imageURL = [BMUtilities getUniqueURLFromBaseURL:imageURL withManager:fileManager keepSortable:YES];
            [[image imageData] writeToURL:imageURL atomically:NO];
        }
    }
}

- (void)exportMovie {
    NSSavePanel *savePanel = [[NSSavePanel alloc] init];
    [savePanel setTitle:@"Export Movie"];
    [savePanel setPrompt:@"Export"];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mov"]];
    [savePanel setNameFieldStringValue:[[[self currentSeries] name] stringByAppendingString:@" Movie"]];
    NSInteger button = [savePanel runModal];
    if (button == NSFileHandlingPanelOKButton) {
        NSURL *exportURL = [savePanel URL];
        // Don't do this because the NSSavePanel warns of overwrite
//        NSFileManager *fileManager = [[NSFileManager alloc] init];
//        exportURL = [BMUtilities getUniqueURLFromBaseURL:exportURL withManager:fileManager keepSortable:NO];
        if ([[self currentSeries] movieIsCurrent]) {
            [self writeMovieFileAtURL:exportURL];
        }
        else {
            [self openProcessingWindow];
            [[[NSApp delegate] videoProcessor] updateVideoWithCallbackTarget:self selector:@selector(writeMovieFileAtURL:) object:exportURL];
        }
    }
}

- (void)openProcessingWindow {
    if (![self processingWindowController]) {
        [self setProcessingWindowController:[[BMProcessingWindowController alloc] initWithWindowNibName:@"BMProcessingWindowController" andParentFrame:[[self window] frame]]];
    }
    [[self processingWindowController] showWindow:nil];
}

- (void)writeMovieFileAtURL:(NSURL *)url {
    [[[self currentSeries] movieData] writeToURL:url atomically:NO];
    [[self processingWindowController] close];
}

@end
