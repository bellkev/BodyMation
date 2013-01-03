//
//  BMCaptureController.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import "BMUtilities.h"
#import "BMImage.h"
#import "BMSeries.h"
#import "BMAppDelegate.h"
#import "BMWindowController.h"

@interface BMCaptureController ()
- (void)showBeforeImage:(NSTimer *)timer;
- (void)hideBeforeImage:(NSTimer *)timer;
@end

@implementation BMCaptureController

// Capture
@synthesize captureSession;
@synthesize videoInput;
@synthesize videoOutput;
@synthesize imageOutput;

// Timing
@synthesize countDown;
@synthesize countDownTimer;
@synthesize comparePeriod;
@synthesize compareTime;

// View control
@synthesize beforeImageViewShouldBeHidden;
@synthesize isCapturingFrames;
@synthesize flashViewShouldBeHidden;

- (id)init {
    self = [super init];
    if (self) {
        [self setBeforeImageViewShouldBeHidden:YES];
        [self setIsCapturingFrames:NO];
        [self setFlashViewShouldBeHidden:YES];
        [self createCaptureSession];
    }
    return self;
}

- (void)createCaptureSession {
    // Create capture session
    [self setCaptureSession:[[AVCaptureSession alloc] init]];
    // Add image output
    [self setImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [[self imageOutput] setOutputSettings:outputSettings];
    if ([[self captureSession] canAddOutput:[self imageOutput]]) {
        [[self captureSession] addOutput:[self imageOutput]];
    }
    else {
        NSLog(@"ERROR: Unable to add image output to AVCaptureSession");
    }
    // This slows shit down! Don't do it!
//    // Add video output to watch frames
//    [self setVideoOutput:[[AVCaptureVideoDataOutput alloc] init]];
//    [[self videoOutput] setAlwaysDiscardsLateVideoFrames:YES];
//    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
//    [videoOutput setSampleBufferDelegate:self queue:queue];
//    if ([[self captureSession] canAddOutput:[self videoOutput]]) {
//        [[self captureSession] addOutput:[self videoOutput]];
//    }
//    else {
//        NSLog(@"ERROR: Unable to add image output to AVCaptureSession");
//    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // Indicate that frames are being captured
    [self setIsCapturingFrames:YES];
    // Update video resolution
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    [self setVideoResolution:CGSizeMake(CVPixelBufferGetWidth(imageBuffer),
//                                        CVPixelBufferGetHeight(imageBuffer))];
}

- (void)setInputDevice:(AVCaptureDevice *)device {
    // Remove current input if present
    if ([[[self captureSession] inputs] count]) {
        NSLog(@"Remove");
        [[self captureSession] removeInput:[self videoInput]];
    }
    //[[self captureSession] removeInput:[self videoInput]];
    // Setup new input
    NSError *error;
    [self setVideoInput:[AVCaptureDeviceInput deviceInputWithDevice:device
                                                              error:&error]];
    if (![self videoInput]) {
        NSLog(@"%@", error);
    }
    // And add to session
    if ([[self captureSession] canAddInput:[self videoInput]]) {
        [[self captureSession] addInput:[self videoInput]];
    }
    else {
        NSLog(@"ERROR: Unable to add video input to AVCaptureSession");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BodyMationInputDeviceChanged" object:self];
}

- (void)startCapture {
    // Apply capture settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setCountDown:[defaults integerForKey:@"CountDownLength"]];
    [self setComparePeriod:[defaults objectForKey:@"ComparePeriod"]];
    [self setCompareTime:[defaults objectForKey:@"CompareTime"]];
    // Setup timers
    [self setCountDownTimer:[NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(countDown:) userInfo:nil repeats:YES]];
    [self setCompareTimer:[NSTimer timerWithTimeInterval:[[self comparePeriod] floatValue] target:self selector:@selector(showBeforeImage:) userInfo:nil repeats:YES]];
    // Start timers
    [[NSRunLoop currentRunLoop] addTimer:[self countDownTimer] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:[self compareTimer] forMode:NSDefaultRunLoopMode];
    // Start capture
    [captureSession startRunning];
}

- (void) stopCapture {
    [[self countDownTimer] invalidate];
    [[self compareTimer] invalidate];
    [self setIsCapturingFrames:NO];
    [[self captureSession] stopRunning];
}

- (void) countDown:(NSTimer *)timer {
    // Capture image
    if ([self countDown] == 0) {
        [self captureStillImage];
    }
    else {
        self.countDown--; // Don't go negative
    }
}

- (void)showBeforeImage:(NSTimer *)timer {
    //if (isCapturingFrames) {
    [self setBeforeImageViewShouldBeHidden:NO];
    [NSTimer scheduledTimerWithTimeInterval:[[self compareTime] floatValue] target:self selector:@selector(hideBeforeImage:) userInfo:nil repeats:NO];
    //}
}

- (void)hideBeforeImage:(NSTimer *)timer {
    [self setBeforeImageViewShouldBeHidden:YES];
}

- (void)flashOff:(NSTimer *)timer{
    [self setFlashViewShouldBeHidden:YES];
}

- (void) captureStillImage
{
    AVCaptureConnection *stillImageConnection = [BMUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[imageOutput connections]];
    
    [imageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         NSImage *image = [[NSImage alloc] initWithData:imageData];
         NSInteger cameraRotationIndex = [[[NSUserDefaults standardUserDefaults] valueForKey:@"CameraRotationIndex"] integerValue];
         NSImage *imageFinal;
         switch (cameraRotationIndex) {
             case 1:
                 imageFinal = [BMUtilities rotateImage:image byDegrees:-90.0];
                 break;
             case 2:
                 imageFinal = [BMUtilities rotateImage:image byDegrees:90.0];
             default:
                 imageFinal = image;
                 break;
         }
         NSData *imageDataFinal = [imageFinal TIFFRepresentation];
         NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageDataFinal];
         NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
         imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
         
         // Save core data object
         BMImage *newImage = [BMImage imageInDefaultContext];
         [newImage setDateTaken:[NSDate date]];
         [newImage setImageData:imageData];
         [newImage setSeries:[[[NSApp delegate] windowController] currentSeries]];
         
         // Hang onto the image for display
         //[self setCapturedImage:imageFinal];
         [self performSelectorOnMainThread:@selector(imageWasCaptured) withObject:nil waitUntilDone:NO];
     }];
}

- (void)imageWasCaptured {
    // Flash on
    [self setFlashViewShouldBeHidden:NO];
    // Stop timers
    [[self countDownTimer] invalidate];
    [[self compareTimer] invalidate];
    // Schedule flash off and closing capture view
    [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(flashOff:) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.7f target:[[[NSApp delegate] windowController] captureViewController] selector:@selector(closeCapture:) userInfo:nil repeats:NO];
    // Indicate that movie is out of date
    [[[[NSApp delegate] windowController] currentSeries] setMovieIsCurrent:NO];
    // Force notification about core data updates so browser view is updated
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    [context processPendingChanges];
    // Should scroll to latest image
    [[[NSApp delegate] windowController] setShouldScrollToNewestImage:YES];
}


@end
