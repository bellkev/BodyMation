//
//  BMVideoView.h
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/22/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@class BMBorderView;

@interface BMVideoView : NSView

@property AVCaptureVideoPreviewLayer *previewLayer;
@property BMBorderView *borderView;
@property NSColor *borderColor;

- (id)initWithFrame:(NSRect)frame andSession:(AVCaptureSession *)session andBorderColor:(NSColor *)color;

@end
