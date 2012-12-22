//
//  BMPreviewView.h
//  BodyMation
//
//  Created by Kevin Bell on 12/14/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface BMPreviewLayer : CALayer  <AVCaptureVideoDataOutputSampleBufferDelegate>

@property CGImageRef currentImage;
@property BOOL isCapturing;

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
@end
