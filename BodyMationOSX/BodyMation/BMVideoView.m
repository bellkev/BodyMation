//
//  BMVideoView.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/22/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMVideoView.h"
#import "BMBorderView.h"
//#import <math.h>

@interface BMVideoView ()
- (void)applyRotation;
@end

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
        [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspect];
        // Make video layer autoresize
        [[self previewLayer] setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
        // Flip the video so that it's mirror-like
        [self setCameraRotationIndex:[[NSUserDefaults standardUserDefaults] valueForKey:@"CameraRotationIndex"]];
        [self applyRotation];
        // Size to fill view
        [[self previewLayer] setFrame:[self bounds]];
        // Add the video layer
        [[self layer] addSublayer:[self previewLayer]];
        // Add border view
        [self setBorderColor:color];
        [self setBorderView:[[BMBorderView alloc] initWithFrame:[self bounds]]];
        [[self borderView] setBorderColor:[self borderColor]];
        [[self borderView] setBorderSize:CGSizeMake(640.0, 480.0)];
        [self addSubview:[self borderView]];
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(refreshLayout:) name:@"BodyMationInputDeviceChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRotation:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)refreshLayout:(NSNotification *)notification {
    [[self previewLayer] setNeedsLayout];
}

- (void)updateRotation:(NSNotification *)notification {
    NSNumber *currentRotation = [[NSUserDefaults standardUserDefaults] valueForKey:@"CameraRotationIndex"];
    if ([self cameraRotationIndex] != currentRotation) {
        [self setCameraRotationIndex:currentRotation];
        [self applyRotation];
    }
}

- (void)applyRotation {
    // Start by flipping accross the y-axis
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity, -1.0, 1.0, 1.0);
    // Then rotate to left or right
    NSLog(@"Index as NSNumber: %@", [self cameraRotationIndex]);
    NSLog(@"Index as int: %d", [[self cameraRotationIndex] integerValue]);
    switch ([[self cameraRotationIndex] integerValue]) {
        case 1:
            transform = CATransform3DRotate(transform, pi / 2, 0.0, 0.0, 1.0);
            NSLog(@"Case 1");
            break;
            
        case 2:
            transform = CATransform3DRotate(transform, - pi / 2, 0.0, 0.0, 1.0);
            NSLog(@"Case 2");
            break;
            
        default:
            NSLog(@"Default");
            break;
    }
    [[self previewLayer] setTransform:transform];
    [[self previewLayer] setFrame:[self bounds]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
