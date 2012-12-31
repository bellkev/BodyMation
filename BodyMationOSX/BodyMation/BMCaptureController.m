//
//  BMCaptureController.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMCaptureController.h"

@implementation BMCaptureController

@synthesize captureSession;
@synthesize videoInput;

- (id)init {
    self = [super init];
    if (self) {
        [self createCaptureSession];
    }
    return self;
}

- (void)createCaptureSession {
    // Create capture session
    [self setCaptureSession:[[AVCaptureSession alloc] init]];
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

@end
