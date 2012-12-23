//
//  BMVideoView.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/22/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMVideoView.h"
#import "BMBorderView.h"

@implementation BMVideoView

@synthesize previewLayer;
@synthesize borderView;
@synthesize borderColor;

- (id)initWithFrame:(NSRect)frame andSession:(AVCaptureSession *)session andBorderColor:(NSColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        // Make this view layer-hosting and add a root layer
        [self setWantsLayer:YES];
        [self setLayer:[CALayer layer]];
        // Make autoresize
        [self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        // Create video layer
        [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:session]];
        // Make video layer autoresize
        [[self previewLayer] setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
        // Flip the video so that it's mirror-like
        CATransform3D flipTransform = CATransform3DScale(CATransform3DIdentity, -1.0, 1.0, 1.0);
        [[self previewLayer] setTransform:flipTransform];
        [[self previewLayer] setFrame:[self bounds]];
        // Add the video layer
        [[self layer] addSublayer:[self previewLayer]];
        // Add border view
        [self setBorderColor:color];
        [self setBorderView:[[BMBorderView alloc] initWithFrame:[self bounds]]];
        [[self borderView] setBorderColor:[self borderColor]];
        [[self borderView] setBorderSize:CGSizeMake(640.0, 480.0)];
        [self addSubview:[self borderView]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
