//
//  BMVideoView.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/22/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMVideoView.h"
#import "BMBorderView.h"
#import "BMUtilities.h"
#import "BMAppDelegate.h"
#import "BMCaptureController.h"
//#import <math.h>

@interface BMVideoView ()
@property NSView *previewView;
- (void)applyRotation;
@end

@implementation BMVideoView

@synthesize previewLayer;
@synthesize previewView;
@synthesize borderView;
@synthesize borderColor;
@synthesize size;

- (id)initWithFrame:(NSRect)frame andCaptureController:(BMCaptureController *)controller andBorderColor:(NSColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        // Host layer
        [self setLayer:[CALayer layer]];
        [self setWantsLayer:YES];
        // Make autoresize
        [self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        // Create video layer
        [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[controller captureSession]]];
        [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspect];
        [[self previewLayer] setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
        // Apply size/rotation settings
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
        [[self borderView] setBorderSize:CGSizeMake(640.0f, 480.0f)];
        // Bind border to video size
        [[self borderView] bind:@"borderSize" toObject:controller withKeyPath:@"videoResolution" options:nil];
        [self addSubview:[self borderView]];
//        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(updateVideoSize:) name:@"BodyMationInputDeviceChanged" object:nil];
//        //[[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(updateVideoSize:) name:nil object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRotation:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    
    return self;
}

//- (void)updateVideoSize:(NSNotification *)notification {
//    CGSize videoSize = [[NSApp delegate] currentResolution];
//    NSLog(@"Video Size: W: %f H: %f", videoSize.width, videoSize.height);
//    NSLog(@"%@", notification);
//    CGSize videoViewSize;
//    if ([self cameraRotationIndex] == 0) {
//        videoViewSize = videoSize;
//    }
//    else {
//        videoViewSize.width = videoSize.height;
//        videoViewSize.height = videoSize.width;
//    }
//    [self setSize:videoViewSize];
//    [self setNeedsDisplay:YES];
//}

//- (void)updateRotation:(NSNotification *)notification {
//    NSNumber *currentRotation = [[NSUserDefaults standardUserDefaults] valueForKey:@"CameraRotationIndex"];
//    if ([self cameraRotationIndex] != currentRotation) {
//        [self setCameraRotationIndex:currentRotation];
//        [self applyRotation];
//        [self updateVideoSize:nil];
//    }
//}
//

- (void)applyRotation {
    // Start by flipping accross the y-axis
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity, -1.0, 1.0, 1.0);
    // Then rotate to left or right
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
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect destinationRect = [BMUtilities rectWithPreservedAspectRatioForSourceSize:CGSizeMake(640.0f, 480.0f) andBoundingRect:[self bounds]];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.0f]
                     forKey:kCATransactionAnimationDuration];
    [[self previewLayer] setFrame:destinationRect];
    [CATransaction commit];
    NSLog(@"W: %f H: %f", [self size].width, [self size].height);
}

@end
