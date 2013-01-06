//
//  BMCaptureController.h
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BMCaptureController : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property AVCaptureSession *captureSession;
@property AVCaptureInput *videoInput;
@property AVCaptureVideoDataOutput *videoOutput;
@property AVCaptureStillImageOutput *imageOutput;
@property NSInteger countDown;
@property NSInteger countUp;
@property NSNumber *comparePeriod;
@property NSNumber *compareTime;
@property NSTimer *countDownTimer;
@property NSTimer *compareTimer;


// View-related properties
@property BOOL beforeImageViewShouldBeHidden;
@property BOOL flashViewShouldBeHidden;
@property CGSize videoResolution;

- (void)setInputDevice:(AVCaptureDevice *)device;
- (void)startCapture;
- (void)stopCapture;
- (void)updateSessionStatus:(NSNotification *)notification;

@end
