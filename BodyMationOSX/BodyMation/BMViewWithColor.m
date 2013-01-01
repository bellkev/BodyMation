//
//  BMViewWithColor.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/31/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMViewWithColor.h"

@implementation BMViewWithColor

@synthesize fillColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)fillWithColor:(NSColor *)color {
    [self setFillColor:color];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[self fillColor] setFill];
    NSRectFill(dirtyRect);
}

@end
