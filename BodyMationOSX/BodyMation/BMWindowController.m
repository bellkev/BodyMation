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

@interface BMWindowController ()
- (void)openViewController:(NSViewController *)viewController;
@end

@implementation BMWindowController

@synthesize shouldScrollToNewestImage;

// View Controllers
@synthesize currentViewController;
@synthesize browserViewController;
@synthesize captureViewController;
@synthesize playViewController;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        [self setShouldScrollToNewestImage:YES];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // THIS WAS DUMB!!!://[[self window] setBackgroundColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0]];
    [self openBrowserViewController];
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

@end
