//
//  BMPlayViewController.m
//  BodyMation
//
//  Created by Kevin Bell on 11/10/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMPlayViewController.h"
#import "BMAppDelegate.h"
#import "BMVideoProcessor.h"
#import "BMImage.h"
#import "BMSeries.h"
#import "BMWindowController.h"
#import <AVFoundation/AVFoundation.h>
#import "BMUtilities.h"
#import "BMMovieView.h"

@interface BMPlayViewController ()
- (void)updateVideo;
- (void)showVideo;
@end

@implementation BMPlayViewController

@synthesize windowController;
@synthesize movieView;
@synthesize movie;

@synthesize progressIndicator;
@synthesize renderText;
@synthesize controllerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    // Initialize
    // Set background color to dark gray
    CALayer *backgroundLayer = [[CALayer alloc] init];
    [backgroundLayer setBackgroundColor:CGColorCreateGenericGray(0.2f, 1.0f)];
    [[self view] setLayer:backgroundLayer];
    [[self view] setWantsLayer:YES];
    // Hide play/pause buttons to start
    [[self controllerView] setHidden:YES];
    // Set up movie
    [self updateVideo];
    // Watch for future updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideo) name:@"MovieIsNotCurrent" object:nil];
}

- (void)updateVideo {
    BMVideoProcessor *videoProcessor = [[NSApp delegate] videoProcessor];
    if ([videoProcessor isRendering]) {
        return;
    }
    [[self movieView] setHidden:YES];
    [[self controllerView] setHidden:YES];
    [[[self view] layer] setBackgroundColor:CGColorCreateGenericGray(0.2f, 1.0f)];
    [[self progressIndicator] startAnimation:nil];
    [[self renderText] setHidden:NO];
    [videoProcessor updateVideoWithCallbackTarget:self selector:@selector(showVideo) object:nil];
}

- (void)showVideo {
    NSData* movieData = [[[[NSApp delegate] windowController] currentSeries] movieData];
    NSError *error;
    [self setMovie:[QTMovie movieWithData:movieData error:&error]];
    if (error) {
        NSLog(@"ERROR loading movie from data: %@", error);
    }
    [[self movie] setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieLoopsAttribute];
    [[self movieView] setMovie:[self movie]];
    [[self movieView] setWantsLayer:YES];
    [[self progressIndicator] stopAnimation:nil];
    [[self renderText] setHidden:YES];
    [[[self view] layer] setBackgroundColor:CGColorCreateGenericGray(0.0f, 1.0f)];
    [[self movieView] setHidden:NO];
    [[self controllerView] setHidden:NO];
    [[self playButton] setHidden:NO];
    [[self pauseButton] setHidden:YES];
}

- (IBAction)playButtonWasPushed:(id)sender {
    [[self movieView] play:nil];
    [[self playButton] setHidden:YES];
    [[self pauseButton] setHidden:NO];
}

- (IBAction)pauseButtonWasPushed:(id)sender {
    [[self movieView] pause:nil];
    [[self pauseButton] setHidden:YES];
    [[self playButton] setHidden:NO];
}

- (IBAction)firstButtonWasPushed:(id)sender {
    [[self movieView] gotoBeginning:nil];
}

- (IBAction)lastButtonWasPushed:(id)sender {
    [[self movieView] gotoEnd:nil];
}

@end
