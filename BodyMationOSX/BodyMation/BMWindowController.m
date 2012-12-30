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

@interface BMWindowController ()
- (void)openViewController:(NSViewController *)viewController;
- (void)setDefaultSeries:(NSNotification *)note;
@end

@implementation BMWindowController

@synthesize shouldScrollToNewestImage;

// View Controllers
@synthesize currentViewController;
@synthesize browserViewController;
@synthesize captureViewController;
@synthesize playViewController;
@synthesize seriesSortDescriptors;
@synthesize seriesPopupButton;
@synthesize currentSeriesName;
@synthesize seriesArrayController;

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
        [self setCurrentSeriesName:seriesName];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setDefaultSeries:) name:NSWindowDidBecomeMainNotification object:[self window]];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // THIS WAS DUMB!!!://[[self window] setBackgroundColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0]];
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
            [self updateSeriesName];
        }
        else {
            [self createNewSeriesAfterInvalidName:newName];
        }
    }
    else {
        [[self seriesPopupButton] selectItemWithTitle:[self currentSeriesName]];
    }
}

- (void)updateSeriesName {
    // TODO: validate this
    [self setCurrentSeriesName:[[[self seriesPopupButton] selectedItem] title]];
}
// View controller methods

- (void)openBrowserViewController {
    if (![[self currentViewController] isKindOfClass:[BMBrowserViewController class]]) {
        if (![self browserViewController]) {
            [self setBrowserViewController:[[BMBrowserViewController alloc] initWithNibName:@"BMBrowserViewController" bundle:nil]];
        }
        [self openViewController:[self browserViewController]];
    }
}

- (void)openCaptureViewController {
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
    [self openCaptureViewController];
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
    [self updateSeriesName];
}

- (IBAction)seriesNameMenuItemSelected:(id)sender {
    NSLog(@"Selected: %@", [[[self seriesPopupButton] selectedItem] title]);
    [self updateSeriesName];
}

- (IBAction)manageSeriesMenuItemSelected:(id)sender {
    // Workaround to make "Manage series..." behave like menu item
    NSLog(@"CurrentSeriesName before manage: %@", [self currentSeriesName]);
    [[self seriesPopupButton] selectItemWithTitle:[self currentSeriesName]];
    [[NSApp delegate] openSeriesWindowController];
}

- (IBAction)newSeriesMenuItemSelected:(id)sender {
    [self createNewSeriesAfterInvalidName:nil];
}

@end
