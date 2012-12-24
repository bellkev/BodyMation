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

@interface BMWindowController : NSWindowController


@property BMBrowserViewController *browserViewController;
@property BMCaptureViewController *captureViewController;
@property BMPlayViewController *playViewController;
@property NSViewController *currentViewController;
@property BOOL shouldScrollToNewestImage;
@property NSArray *seriesSortDescriptors;
@property NSString *currentSeriesName;
@property (unsafe_unretained) IBOutlet NSPopUpButton *seriesPopupButton;
@property (strong) IBOutlet NSArrayController *seriesArrayController;

- (void)openBrowserViewController;
- (void)openCaptureViewController;
- (void)openPlayViewController;

- (IBAction)browseButtonPressed:(id)sender;
- (IBAction)captureButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)preferencesButtonPressed:(id)sender;
- (IBAction)chooseSeriesSelected:(id)sender;
- (IBAction)newSeriesMenuItemSelected:(id)sender;
- (IBAction)seriesNameMenuItemSelected:(id)sender;
- (IBAction)manageSeriesMenuItemSelected:(id)sender;

@end
