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
@class BMWindowController;

@interface BMCaptureViewController : NSViewController

// View-related properties
@property BMBeforeImageView *beforeImageView;
@property NSView *captureView;
@property NSImage *capturedImage;
@property /*(weak)*/ IBOutlet NSTextField *countDownLabel;
@property NSView *flashView;
@property /*(weak)*/ IBOutlet NSView *overlayView;
@property BMWindowController *windowController;

// Capture session properties
@property AVCaptureStillImageOutput *imageOutput;
@property AVCaptureVideoDataOutput *videoOutput;
@property AVCaptureSession *captureSession;

// Timing-related properties
@property float comparePeriod;
@property float compareTime;
@property (retain) NSTimer *compareTimer;
@property NSInteger countDownLength;
@property NSInteger countDownRemaining;
@property (retain) NSTimer *countDownTimer;

// Instance methods
- (void) startCapture;
- (void) stopCapture;
- (void) captureStillImage;

@end
