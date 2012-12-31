//
//  BMPreviewView.h
//  BodyMation
//
//  Created by Kevin Bell on 12/15/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface BMPreviewView : NSView <AVCaptureVideoDataOutputSampleBufferDelegate>

@property NSSize frameSize;
@property BOOL isCapturing;
@property CALayer *previewLayer;

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end
