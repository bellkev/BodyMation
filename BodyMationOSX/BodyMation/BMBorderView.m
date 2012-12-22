//
//  BMBorderView.m
//  BodyMation
//
//  Created by Kevin Bell on 12/16/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMBorderView.h"
#import "BMUtilities.h"

@implementation BMBorderView

@synthesize borderSize;
@synthesize borderColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect destinationRect = [BMUtilities rectWithPreservedAspectRatioForSourceSize:[self borderSize] andBoundingRect:[self bounds]];
    [[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:0.5] setFill];
    NSFrameRectWithWidth(destinationRect, 10);
    
}

@end
