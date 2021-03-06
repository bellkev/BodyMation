//
//  BMBrowserViewController.h
//  BodyMation
//
//  Created by Kevin Bell on 11/7/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class BMWindowController;
@class BMViewWithColor;

@interface BMBrowserViewController : NSViewController

@property NSArray *imagesSortDescriptors;
@property (weak) IBOutlet IKImageBrowserView *imageBrowserView;
@property (weak) IBOutlet NSScrollView *scrollView;
@property BMWindowController *windowController;
@property (unsafe_unretained) IBOutlet NSButton *buyButton;
@property (strong) IBOutlet NSArrayController *imageArrayController;
@property (weak) IBOutlet BMViewWithColor *startView;
@property (strong) IBOutlet NSImageView *welcomeView;
@property (strong) IBOutlet NSImageView *firstPictureView;

- (void)scrollUpdate:(id)sender;
- (IBAction)buyButtonWasClicked:(id)sender;
- (IBAction)deleteButtonWasClicked:(id)sender;


@end
