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
@class BMCaptureController;

@interface BMVideoView : NSView

@property AVCaptureVideoPreviewLayer *previewLayer;
@property BMBorderView *borderView;
@property NSColor *borderColor;
@property NSNumber *cameraRotationIndex;
@property CGSize size;

- (id)initWithFrame:(NSRect)frame andCaptureController:(BMCaptureController *)controller andBorderColor:(NSColor *)color;
- (void)updateVideoSize:(NSNotification *)notification;
- (void)updateRotation:(NSNotification *)notification;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
