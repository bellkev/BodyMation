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

@interface BMPlayViewController ()
- (NSOperation *)renderVideoOperation;
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
    [backgroundLayer setBackgroundColor:CGColorCreateGenericGray(0.2, 1.0)];
    [[self view] setLayer:backgroundLayer];
    [[self view] setWantsLayer:YES];
    // Hide play/pause buttons to start
    [[self controllerView] setHidden:YES];
    // Set up movie
    [self createVideo];
}

- (void)createVideo {
    NSLog(@"Creating video...");
    [[self movieView] setHidden:YES];
    [[self controllerView] setHidden:YES];
    [[self progressIndicator] startAnimation:nil];
    [[self renderText] setHidden:NO];
    NSOperation *renderOperation = [self renderVideoOperation];
    NSOperationQueue *renderQueue = [[NSOperationQueue alloc] init];
    [renderQueue setName:@"Rendering Queue"];
    [renderQueue addOperation:renderOperation];
    NSLog(@"Done with createVideo...");
}

- (void)showVideo {
    [[self movie] setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieLoopsAttribute];
    [[self movieView] setMovie:[self movie]];
    [[self progressIndicator] stopAnimation:nil];
    [[self renderText] setHidden:YES];
    [[self movieView] setHidden:NO];
    [[self controllerView] setHidden:NO];
    [[self playButton] setHidden:NO];
    [[self pauseButton] setHidden:YES];
}

- (NSOperation*)renderVideoOperation {
    NSLog(@"Render video operation...");
    NSInvocationOperation* renderOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(renderVideo) object:nil];
    NSLog(@"Operation: %@", renderOperation);
    return renderOperation;
}

- (void)renderVideo {
    // Update movie
    NSData *newMovieData = [[[NSApp delegate] videoProcessor] getCurrentMovieData];
    NSError *error;
    [self setMovie:[QTMovie movieWithData:newMovieData error:&error]];
    if (error) {
        NSLog(@"ERROR: %@", error);
    }
    [self performSelectorOnMainThread:@selector(showVideo) withObject:nil waitUntilDone:YES];
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
