//
//  BMCaptureViewController.m
//  BodyMation
//
//  Created by Kevin Bell on 10/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMBeforeImageView.h"
#import "BMCaptureViewController.h"
#import "BMPlayViewController.h"
#import "BMImage.h"
#import "BMUtilities.h"
#import "BMPreviewLayer.h"
#import "BMWindowController.h"
#import "BMBrowserViewController.h"
#import "BMBorderView.h"
#import "BMVideoView.h"

//#import <ImageIO/ImageIO.h>

@interface BMCaptureViewController ()
- (void)closeCapture:(NSTimer *)timer;
- (void)countDown:(NSTimer *)timer;
- (void)createCaptureSession;
- (void)flashOff:(NSTimer *)timer;
- (void)imageWasCaptured;
- (void)createCaptureViews;
- (void)toggleBeforeImage:(NSTimer *)timer;
@end

@implementation BMCaptureViewController

@synthesize windowController;

// View-related properties
@synthesize beforeImageView;
@synthesize captureView;
@synthesize capturedImage;
@synthesize countDownLabel;
@synthesize flashView;
@synthesize overlayView;

// Capture session properties
@synthesize captureSession;
@synthesize imageOutput;
@synthesize videoOutput;

// Timing-related properties
@synthesize comparePeriod;
@synthesize compareTime;
@synthesize compareTimer;
@synthesize countDownLength;
@synthesize countDownRemaining;
@synthesize countDownTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self createCaptureSession];
        [self createCaptureViews];
        [self startCapture];
    }
    
    return self;
}

- (void)createCaptureSession {
    // Prepare inputs/outputs
    NSError *error;
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                                             error:&error];
    if (!videoInput) {
        NSLog(@"%@", error);
    }
    imageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [imageOutput setOutputSettings:outputSettings];
    
    // Create capture session
    [self setCaptureSession:[[AVCaptureSession alloc] init]];
    
    // Attach input/output to session
    if ([captureSession canAddInput:videoInput]) {
        [captureSession addInput:videoInput];
    }
    else {
        NSLog(@"ERROR: Unable to add video input to AVCaptureSession");
    }
    if ([captureSession canAddOutput:imageOutput]) {
        [captureSession addOutput:imageOutput];
    }
    else {
        NSLog(@"ERROR: Unable to add image output to AVCaptureSession");
    }
}

- (void)createCaptureViews {
    // Add background
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setBackgroundColor:CGColorCreateGenericGray(0.2, 1.0)];
    [[self view] setWantsLayer:YES];
    [[self view] setLayer:backgroundLayer];
    
    // Make an extra-wide frame rect so that video will always be as tall as possible with "aspect" video gravity
    float paddedWidth = 2000.0;
    CGRect boundsRect = [[self view] bounds];
    CGRect paddedRect = CGRectMake(-paddedWidth / 2 + boundsRect.size.width / 2.0,
                                   boundsRect.origin.y,
                                   paddedWidth,
                                   boundsRect.size.height);
    
    // Create video view and add under overlay view
    [self setCaptureView:[[BMVideoView alloc] initWithFrame:paddedRect andSession:[self captureSession] andBorderColor:[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5]]];
    [[self overlayView] setWantsLayer:YES];
    [[self view] addSubview:[self captureView] positioned:NSWindowBelow relativeTo:[self overlayView]];
    
    // Create before image view
    [self setBeforeImageView:[[BMBeforeImageView alloc] initWithFrame:paddedRect andBorderColor:[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.5]]];
    [[self beforeImageView] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [[self view] addSubview:[self beforeImageView] positioned:NSWindowBelow relativeTo:[self overlayView]];
    
    // Create flash view
    [self setFlashView:[[NSView alloc] initWithFrame:[[self captureView] frame]]];
    [[self flashView] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    CALayer *whiteLayer = [[CALayer alloc] init];
    [whiteLayer setBackgroundColor:CGColorCreateGenericGray(1.0, 1.0)];
    [[self flashView] setLayer:whiteLayer];
    [[self flashView] setWantsLayer:YES];
    [[self flashView] setHidden:YES];
    [[self view] addSubview:flashView];
}

- (void)startCapture {
    // Apply capture settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setCountDownLength:[defaults integerForKey:@"CountDownLength"]];
    [self setComparePeriod:[defaults floatForKey:@"ComparePeriod"]];
    [self setCompareTime:[defaults floatForKey:@"CompareTime"]];
    [self setCountDownRemaining:[self countDownLength]];
    [[self countDownLabel] setStringValue:[NSString stringWithFormat:@"%ld",[self countDownRemaining]]];
    [self setCountDownTimer:[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES]];
    [self setCompareTimer:[NSTimer timerWithTimeInterval:[self comparePeriod] target:self selector:@selector(toggleBeforeImage:) userInfo:nil repeats:YES]];
    // Start timers
    [[NSRunLoop currentRunLoop] addTimer:[self countDownTimer] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:[self compareTimer] forMode:NSDefaultRunLoopMode];
    // Start capture
    [captureSession startRunning];
}

- (void) stopCapture {
    [[self countDownTimer] invalidate];
    [[self compareTimer] invalidate];
    [[self captureSession] stopRunning];
}

- (void) countDown:(NSTimer *)timer {
    // For 0+ just update countdown label
    if ([self countDownRemaining] >= 0) {
        [[self countDownLabel] setStringValue:[NSString stringWithFormat:@"%ld",[self countDownRemaining]]];
    }
    // Capture image
    else if ([self countDownRemaining] == -1) {
        [self captureStillImage];
    }
    self.countDownRemaining -= 1;
}

- (void)toggleBeforeImage:(NSTimer *)timer {
    if ([[self beforeImageView] isHidden] /*&& [[self previewLayer] isCapturing*/) {
        // Turn on
        [[self beforeImageView] setHidden:NO];
        // Schedule to turn back off
        [NSTimer scheduledTimerWithTimeInterval:[self compareTime] target:self selector:@selector(toggleBeforeImage:) userInfo:nil repeats:NO];
    }
    else {
    [[self beforeImageView] setHidden:YES];
    }
}

- (void) captureStillImage
{
    AVCaptureConnection *stillImageConnection = [BMUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[imageOutput connections]];

    [imageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         
         // Save core data object
         BMImage *newImage = [BMImage imageInDefaultContext];
         [newImage setDateTaken:[NSDate date]];
         [newImage setImageData:imgData];
         
         // Hang onto the image for display
         [self setCapturedImage:[[NSImage alloc] initWithData:imgData]];
         [self performSelectorOnMainThread:@selector(imageWasCaptured) withObject:nil waitUntilDone:NO];
     }];
}

- (void)imageWasCaptured {
    // Flash on
    [[self flashView] setHidden:NO];
    // Stop timers
    [[self countDownTimer] invalidate];
    [[self compareTimer] invalidate];
    // Setup captured image for display after flash
    [[self beforeImageView] setBeforeImage:[self capturedImage]];
    [[self beforeImageView] setNeedsDisplay:YES];
    [[self beforeImageView] setHidden:NO];
    // Schedule flash off and closing capture view
    [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(flashOff:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.7f target:self selector:@selector(closeCapture:) userInfo:nil repeats:NO];
    // Indicate that movie is out of date
    [[[self windowController] playViewController] setMovieNeedsRefresh:YES];
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    // Force notification about core data updates so browser view is updated
    [context processPendingChanges];
    // Should scroll to latest image
    [[self windowController] setShouldScrollToNewestImage:YES];
}

- (void)flashOff:(NSTimer *)timer{
    [[self flashView] setHidden:YES];
}

- (void)closeCapture:(NSTimer *)timer{
    [[self windowController] openBrowserViewController];
}

@end
