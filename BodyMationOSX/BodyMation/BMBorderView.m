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
        // Make autoresize
        [self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect destinationRect = [BMUtilities rectWithPreservedAspectRatioForSourceSize:[self borderSize] andBoundingRect:[self bounds]];
    [[self borderColor] setFill];
    NSLog(@"%@", [self borderColor]);
    NSFrameRectWithWidth(destinationRect, 15);
    
}

@end
