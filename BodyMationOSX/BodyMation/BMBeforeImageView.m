//
//  BMBeforeImageView.m
//  BodyMation
//
//  Created by Kevin Bell on 11/1/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMBeforeImageView.h"
#import "BMUtilities.h"
#import "BMImage.h"
#import "BMAppDelegate.h"
#import "BMWindowController.h"
#import "BMSeries.h"

@implementation BMBeforeImageView

@synthesize beforeImage;
@synthesize beforeImageLayer;
@synthesize borderColor;

- (id)initWithFrame:(NSRect)frame andBorderColor:(NSColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        // Make autoresize
        [self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        
        // Set before image to latest image
        [self updateBeforeImage];
        
        // Set border color
        [self setBorderColor:color];
  
        // Hide for now
        [self setHidden:YES];
    }
    
    return self;
}

- (void)updateBeforeImage {
    BMImage *latestImageObject = [[[[NSApp delegate] windowController] currentSeries] getMostRecentImage];
    if (latestImageObject) {
        [self setBeforeImage:[[NSImage alloc] initWithData:[latestImageObject imageData]]];
    }
    else {
        [self setBeforeImage:nil];
    }
    NSLog(@"Successfully set before image");
}

- (void)drawRect:(NSRect)dirtyRect
{
    if ([self beforeImage]) {
        // Drawing code here.
        NSRect destinationRect = [BMUtilities rectWithPreservedAspectRatioForSourceSize:[[self beforeImage] size] andBoundingRect:[self bounds]];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform scaleXBy:-1.0f yBy:1.0f];
        [transform translateXBy:-self.bounds.size.width yBy:0.0f];
        [transform concat];
        [[self beforeImage] drawInRect:destinationRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        [[self borderColor] setFill];
        NSFrameRectWithWidth(destinationRect, 15);
    }
}
@end
