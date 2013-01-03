//
//  BMCaptureViewController.h
//  BodyMation
//
//  Created by Kevin Bell on 10/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@class BMBeforeImageView;
@class BMVideoView;
@class BMWindowController;
@class BMCaptureController;

@interface BMCaptureViewController : NSViewController

@property BMWindowController *windowController;
@property BMCaptureController *captureController;

// View-related properties
@property BMBeforeImageView *beforeImageView;
@property BMVideoView *videoView;
@property (weak) IBOutlet NSView *overlayView;
@property (weak) IBOutlet NSTextField *countDownLabel;
@property NSView *flashView;

@end
