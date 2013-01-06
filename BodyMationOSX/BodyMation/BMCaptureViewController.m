//
//  BMCaptureViewController.m
//  BodyMation
//
//  Created by Kevin Bell on 10/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMCaptureViewController.h"
#import "BMBeforeImageView.h"
#import "BMVideoView.h"
#import "BMImage.h"
#import "BMUtilities.h"
#import "BMWindowController.h"
#import "BMBrowserViewController.h"
#import "BMBorderView.h"
#import "BMAppDelegate.h"
#import "BMCaptureController.h"

//#import <ImageIO/ImageIO.h>

@interface BMCaptureViewController ()
- (void)closeCapture:(NSTimer *)timer;
- (void)createCaptureViews;
@end

@implementation BMCaptureViewController

@synthesize windowController;
@synthesize captureController;

// View-related properties
@synthesize beforeImageView;
@synthesize videoView;
@synthesize countDownLabel;
@synthesize flashView;
@synthesize overlayView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self setCaptureController:[[NSApp delegate] captureController]];
        [self createCaptureViews];
        [[self captureController] startCapture];
        
    }
    
    return self;
}

- (void)createCaptureViews {
    // Add background
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setBackgroundColor:CGColorCreateGenericGray(0.2, 1.0)];
    [[self view] setWantsLayer:YES];
    [[self view] setLayer:backgroundLayer];
    
    // Make an extra-wide frame rect so that video will always be as tall as possible with "aspect" video gravity
    float paddedWidth = 10000.0f;
    CGRect boundsRect = [[self view] bounds];
    CGRect paddedRect = CGRectMake(-paddedWidth / 2 + boundsRect.size.width / 2.0,
                                   boundsRect.origin.y,
                                   paddedWidth,
                                   boundsRect.size.height);
    
    // Create before image view and add under overlay view
    [self setBeforeImageView:[[BMBeforeImageView alloc] initWithFrame:paddedRect
                                                       andBorderColor:[NSColor colorWithCalibratedRed:0.0
                                                                                                green:1.0
                                                                                                 blue:0.0
                                                                                                alpha:0.5]]];
    [[self view] addSubview:[self beforeImageView]
                      positioned:NSWindowBelow
                      relativeTo:[self overlayView]];
    
    // Create video view and add under before image view
    [self setVideoView:[[BMVideoView alloc] initWithFrame:paddedRect
                                    andCaptureController:[self captureController]]];
    [[self overlayView] setWantsLayer:YES];
    [[self view] addSubview:[self videoView]
                 positioned:NSWindowBelow
                 relativeTo:[self beforeImageView]];
    
    // Create flash view and add on top
    [self setFlashView:[[NSView alloc] initWithFrame:[[self view] frame]]];
    [[self flashView] setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    CALayer *whiteLayer = [[CALayer alloc] init]; // CALayer is nice here because it animates by default
    [whiteLayer setBackgroundColor:CGColorCreateGenericGray(1.0, 1.0)];
    [[self flashView] setLayer:whiteLayer];
    [[self flashView] setWantsLayer:YES];
    [[self flashView] setHidden:YES];
    [[self view] addSubview:[self flashView] positioned:NSWindowAbove relativeTo:[self overlayView]];
    
    // Bind appropriate properties to capture controller
    
    [[self beforeImageView] bind:@"hidden"
                        toObject:[self captureController]
                     withKeyPath:@"beforeImageViewShouldBeHidden"
                         options:nil];
    
    [[self countDownLabel] bind:@"stringValue"
                       toObject:[self captureController]
                    withKeyPath:@"countDown"
                        options:nil];
    
    [[self flashView] bind:@"hidden"
                  toObject:[self captureController]
               withKeyPath:@"flashViewShouldBeHidden"
                   options:nil];
}



- (void)closeCapture:(NSTimer *)timer{
    [[self windowController] openBrowserViewController];
}

@end
