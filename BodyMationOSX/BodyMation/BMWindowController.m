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

@interface BMWindowController ()
- (void)openViewController:(NSViewController *)viewController;
- (void)setDefaultSeries:(NSNotification *)note;
- (void)updateSeries;
- (void)exportPicturesOrMovie;
- (void)exportPictures;
- (void)exportMovie;
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
@synthesize currentSeriesName;
@synthesize seriesArrayController;

// Buttons
@synthesize seriesPopupButton;
@synthesize browseButton;
@synthesize captureButton;
@synthesize playButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        [self setShouldScrollToNewestImage:YES];
        // Set sort type for series array controller
        NSSortDescriptor *sort;
        sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [self setSeriesSortDescriptors:[NSArray arrayWithObject:sort]];
        NSString *seriesName = [[NSUserDefaults standardUserDefaults] valueForKey:@"DefaultSeriesName"];
        [self setCurrentSeries:[BMSeries seriesForName:seriesName]];
        [self setCurrentSeriesName:seriesName];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDefaultSeries:) name:NSWindowDidBecomeMainNotification object:[self window]];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // THIS WAS DUMB!!!://[[self window] setBackgroundColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0]];
    [self setButtons:[NSArray arrayWithObjects:browseButton, captureButton, playButton, nil]];
    [self openBrowserViewController];
}

- (void)setDefaultSeries:(NSNotification *)note {
    //NSLog(@"Notification: %@", note);
    [[self seriesPopupButton] selectItemWithTitle:[self currentSeriesName]];
}

- (void)createNewSeriesAfterInvalidName:(NSString *)invalidName {
    // Creates new series OPTIONALLY with prompt asking to choose a unique name
    // Workaround to make "New series..." behave like menu item
    [[self seriesPopupButton] selectItemWithTitle:[self currentSeriesName]];
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
        [[self seriesPopupButton] selectItemWithTitle:[self currentSeriesName]];
    }
}

- (void)updateSeries {
    // TODO: validate this
    [self setCurrentSeries:[BMSeries seriesForName:[[[self seriesPopupButton] selectedItem] title]]];
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
        if (![self captureViewController]) {
            [self setCaptureViewController:[[BMCaptureViewController alloc] initWithNibName:@"BMCaptureViewController" bundle:nil]];
        }
        else {
            [[self captureViewController] startCapture];
        }
        [self openViewController:[self captureViewController]];
    }
}

- (void)openPlayViewController {
    [self setActiveButton:[self playButton]];
    if (![[self currentViewController] isKindOfClass:[BMPlayViewController class]]) {
        if (![self playViewController]) {
            [self setPlayViewController:[[BMPlayViewController alloc] initWithNibName:@"BMPlayViewController" bundle:nil]];
        }
        else if ([[self playViewController] movieNeedsRefresh]) {
            [[self playViewController] createVideo];
        }
        [self openViewController:[self playViewController]];
    }
}


- (void)openViewController:(NSViewController *)viewController {
    // Scale new subview to window size
    [[viewController view] setFrame:[[[self window] contentView] bounds]];
    // Handle any necessary cleanup of current view
    if ([[self currentViewController] isKindOfClass:[BMCaptureViewController class]]) {
        [(BMCaptureViewController *)[self currentViewController] stopCapture];
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
    NSLog(@"CurrentSeriesName before manage: %@", [self currentSeriesName]);
    [[self seriesPopupButton] selectItemWithTitle:[self currentSeriesName]];
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
        exportURL = [BMUtilities getUniqueURLFromBaseURL:exportURL withManager:fileManager];
        NSError *error;
        [fileManager createDirectoryAtURL:exportURL withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        for (BMImage *image in [[self currentSeries] images]) {
            NSURL *imageURL = [exportURL URLByAppendingPathComponent:[image imageTitleNoSlashes]];
            imageURL = [BMUtilities getUniqueURLFromBaseURL:imageURL withManager:fileManager];
            imageURL = [imageURL URLByAppendingPathExtension:@"jpg"];
            [[image imageData] writeToURL:imageURL atomically:NO];
        }
    }
}
@end
