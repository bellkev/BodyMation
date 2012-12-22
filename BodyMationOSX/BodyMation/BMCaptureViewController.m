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

//#import <ImageIO/ImageIO.h>

@interface BMCaptureViewController ()
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
- (void)closeCapture:(NSTimer *)timer;
- (void)countDown:(NSTimer *)timer;
- (void)flashOff:(NSTimer *)timer;
- (void)imageWasCaptured;
- (void)setupCapture;
- (void)toggleBeforeImage:(NSTimer *)timer;
@end

@implementation BMCaptureViewController

// View-related properties
@synthesize beforeImage;
@synthesize beforeImageView;
@synthesize captureView;
@synthesize capturedImage;
@synthesize countDownLabel;
@synthesize flashView;
@synthesize overlayView;
@synthesize windowController;

// Capture session properties
@synthesize previewLayer;
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
        [self setupCapture];
        [self startCapture];
    }
    
    return self;
}

- (void)setupCapture {
    // Setup capture session
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
    
    // Create capture view
    [self setCaptureView:[[NSView alloc] initWithFrame:[[self view] bounds]]];
    [[self captureView] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setBackgroundColor:CGColorCreateGenericGray(0.2, 1.0)];
    [[self captureView] setLayer:backgroundLayer];
    [[self captureView] setWantsLayer:YES];
    [self setPreviewLayer:[BMPreviewLayer layer]];
    [[self previewLayer] setFrame:[[self captureView] bounds]];
    [[[self captureView] layer] addSublayer:[self previewLayer]];


    //    // Setup video layer
    //    [self setCapturePreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession]];
    //    [self setCaptureView:[[NSView alloc] initWithFrame:[[self view] bounds]]];
    //    [[self captureView] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    //
    //    // Order of setLayer and setWantsLayer here is important
    //    [[self captureView] setLayer:capturePreviewLayer];
    //    [[self captureView] setWantsLayer:YES];
    [[self overlayView] setWantsLayer:YES];
    [[self view] addSubview:[self captureView] positioned:NSWindowBelow relativeTo:[self overlayView]];
    
    // Add capture border
    BMBorderView *borderView = [[BMBorderView alloc] initWithFrame:[[self captureView] bounds]];
    [borderView setBorderSize:CGSizeMake(640.0, 480.0)];
    [borderView setAutoresizingMask:18];
    [[self captureView] addSubview:borderView];
    
    // Setup before image view
    [self setBeforeImage:[[NSImage alloc] initWithContentsOfFile:@"/Users/Kevin/Desktop/file.jpg"]];
    [self setBeforeImageView:[[BMBeforeImageView alloc] initWithFrame:[[self view] bounds]]];
    [[self beforeImageView] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    [[self beforeImageView] setBeforeImage:[self beforeImage]];
    [[self captureView] addSubview:[self beforeImageView]];
    
    // Setup flash view
    [self setFlashView:[[NSView alloc] initWithFrame:[[self captureView] frame]]];
    [[self flashView] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    CALayer *whiteLayer = [[CALayer alloc] init];
    [whiteLayer setBackgroundColor:CGColorCreateGenericGray(1.0, 1.0)];
    [[self flashView] setLayer:whiteLayer];
    [[self flashView] setWantsLayer:YES];
    [[self flashView] setHidden:YES];
    [[self view] addSubview:flashView];
    
    // Add a video output for preview
    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
    [videoOutput setSampleBufferDelegate:[self previewLayer] queue:queue];
    
    // Create session and attach
    captureSession = [[AVCaptureSession alloc] init];
    
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
    if ([captureSession canAddOutput:videoOutput]) {
        [captureSession addOutput:videoOutput];
    }
    else {
        NSLog(@"ERROR: Unable to add image output to AVCaptureSession");
    }
}

- (void) startCapture {
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
    if ([[self beforeImageView] isHidden] && [[self previewLayer] isCapturing]) {
        // Turn on
        [[self beforeImageView] setHidden:NO];
        // Schedule to turn back off
        [NSTimer scheduledTimerWithTimeInterval:[self compareTime] target:self selector:@selector(toggleBeforeImage:) userInfo:nil repeats:NO];
    }
    else {
    [[self beforeImageView] setHidden:YES];
    }
}

//- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {;}

//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    [self setIsCapturing:YES];
//}

- (void) captureStillImage
{
    NSLog(@"Capturing Still Image");
    AVCaptureConnection *stillImageConnection = [BMUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[imageOutput connections]];

    [imageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         NSLog(@"Getting photo data");
         NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         NSLog(@"Saving image");
         //[imgData writeToFile: @"/Users/Kevin/Desktop/file.jpg" atomically: NO];
         // TODO: switch above to using imageWithRawBufferYpCbCr. Need to set
         // photo capture options correctly for this.
         
         // Save core data object
         BMImage *newImage = [BMImage imageInDefaultContext];
         [newImage setDateTaken:[NSDate date]];
         [newImage setImageData:imgData];
         
         // Hang onto the image for display
         [self setCapturedImage:[[NSImage alloc] initWithData:imgData]];
         //[[self beforeImageView] setBeforeImage:[self capturedImage]];
         //[[self beforeImageView] setHidden:NO];
         [self performSelectorOnMainThread:@selector(imageWasCaptured) withObject:nil waitUntilDone:NO];
     }];
    // Perform post-capture actions

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
