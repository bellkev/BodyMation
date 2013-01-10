//
//  BMVideoView.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/22/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMVideoView.h"
#import "BMUtilities.h"
#import "BMAppDelegate.h"
#import "BMCaptureController.h"

@interface BMVideoView ()
@property NSView *previewView;
- (void)applyRotation;
@end

@implementation BMVideoView

@synthesize previewLayer;
@synthesize previewView;
@synthesize size;
@synthesize captureController;

- (id)initWithFrame:(NSRect)frame andCaptureController:(BMCaptureController *)controller {
    self = [super initWithFrame:frame];
    if (self) {
        // Hang onto capture controller
        [self setCaptureController:controller];
        // Host layer
        [self setLayer:[CALayer layer]];
        [self setWantsLayer:YES];
        // Make autoresize
        [self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        // Get current camera rotation
        [self updateRotation:nil];
        // Setup preview layer
        // Create video layer
        [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureController] captureSession]]];
        [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspect];
        [[self previewLayer] setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
        // Size to fill view
        [[self previewLayer] setFrame:[self bounds]];
        // Add the video layer
        [[self layer] addSublayer:[self previewLayer]];
        // And force layout
        [self refreshPreviewLayer:nil];
        // Get current rotation setting and apply
        [self setCameraRotationIndex:[[NSUserDefaults standardUserDefaults] valueForKey:@"CameraRotationIndex"]];
        [self applyRotation];
        // Watch for changes to input device/capture session status
        // (necessary because preview layer doesn't automatically update size)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPreviewLayer:) name:AVCaptureSessionDidStartRunningNotification object:[[self captureController] captureSession]];
        [[NSNotificationCenter defaultCenter]  addObserver:self
                                                  selector:@selector(refreshPreviewLayer:)
                                                      name:@"BodyMationInputDeviceChanged"
                                                    object:nil];
        // Watch for changes to rotation option
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateRotation:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)refreshPreviewLayer:(NSNotification *)notification {
    // Re-add and re-layout to make video gravity refresh correctly
    [[self previewLayer] removeFromSuperlayer];
    [[self previewLayer] setFrame:[self bounds]];
    [[self layer] addSublayer:[self previewLayer]];
    [[self previewLayer] setNeedsLayout];
}

- (void)updateRotation:(NSNotification *)notification {
    NSNumber *currentRotation = [[NSUserDefaults standardUserDefaults] valueForKey:@"CameraRotationIndex"];
    if ([self cameraRotationIndex] != currentRotation) {
        [self setCameraRotationIndex:currentRotation];
        [self applyRotation];
        [self refreshPreviewLayer:nil];
    }
}


- (void)applyRotation {
    // Start by flipping accross the y-axis
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity, -1.0, 1.0, 1.0);
    // Then rotate to left or right
    switch ([[self cameraRotationIndex] integerValue]) {
        case 1:
            transform = CATransform3DRotate(transform, pi / 2, 0.0, 0.0, 1.0);
            break;
            
        case 2:
            transform = CATransform3DRotate(transform, - pi / 2, 0.0, 0.0, 1.0);
            break;
            
        default:
            break;
    }
    [[self previewLayer] setTransform:transform];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
