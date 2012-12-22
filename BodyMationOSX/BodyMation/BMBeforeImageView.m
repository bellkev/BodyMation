//
//  BMBeforeImageView.m
//  BodyMation
//
//  Created by Kevin Bell on 11/1/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMBeforeImageView.h"
#import "BMUtilities.h"

@implementation BMBeforeImageView

@synthesize beforeImage;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setHidden:YES];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    // Follow same scaling as previewLayer
    NSRect destinationRect = [BMUtilities rectWithPreservedAspectRatioForSourceSize:[[self beforeImage] size] andBoundingRect:[self bounds]];
    [[self beforeImage] drawInRect:destinationRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    
    [[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:0.5] setFill];
    NSFrameRectWithWidth(destinationRect, 10);
}

@end
