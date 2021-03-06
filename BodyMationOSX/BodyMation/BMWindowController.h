//
//  BMWindowController.h
//  BodyMation
//
//  Created by Kevin Bell on 10/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BMBrowserViewController;
@class BMCaptureViewController;
@class BMPlayViewController;
@class BMSeries;
@class BMProcessingWindowController;

@interface BMWindowController : NSWindowController <NSWindowDelegate>


@property BMBrowserViewController *browserViewController;
@property BMCaptureViewController *captureViewController;
@property BMPlayViewController *playViewController;
@property NSViewController *currentViewController;
@property BOOL shouldScrollToNewestImage;
@property NSArray *seriesSortDescriptors;
@property BMSeries *currentSeries;
@property NSInteger currentFramerate;
@property BOOL currentManualFramerate;
@property (unsafe_unretained) IBOutlet NSPopUpButton *seriesPopupButton;
@property (strong) IBOutlet NSArrayController *seriesArrayController;
@property (weak) IBOutlet NSButton *browseButton;
@property (weak) IBOutlet NSButton *captureButton;
@property (weak) IBOutlet NSButton *playButton;
@property NSArray *buttons;
@property BMProcessingWindowController *processingWindowController;

// View controller methods
- (void)openBrowserViewController;
- (void)openCaptureViewController;
- (void)openPlayViewController;

// Toolbar button actions
- (IBAction)browseButtonPressed:(id)sender;
- (IBAction)captureButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)preferencesButtonPressed:(id)sender;
- (IBAction)chooseSeriesSelected:(id)sender;
- (IBAction)newSeriesMenuItemSelected:(id)sender;
- (IBAction)seriesNameMenuItemSelected:(id)sender;
- (IBAction)manageSeriesMenuItemSelected:(id)sender;
- (IBAction)exportButtonPressed:(id)sender;

// Other
- (void)setActiveButton:(NSButton *)activeButton;
@end
