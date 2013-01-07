//
//  BMBeforeImageView.m
//  BodyMation
//
//  Created by Kevin Bell on 11/1/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMBeforeImageView.h"
#import "BMUtilities.h"
#import "BMBorderView.h"
#import "BMImage.h"

@implementation BMBeforeImageView

@synthesize beforeImage;
@synthesize beforeImageLayer;
@synthesize borderView;
@synthesize borderColor;

- (id)initWithFrame:(NSRect)frame andBorderColor:(NSColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        // Make autoresize
        [self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        
        // Set before image to latest image
        [self updateBeforeImage];

        // Add border view
        [self setBorderColor:color];
        [self setBorderView:[[BMBorderView alloc] initWithFrame:[self bounds]]];
        [[self borderView] setBorderColor:[self borderColor]];
        [[self borderView] setBorderSize:[[self beforeImage] size]];
        [self addSubview:[self borderView]];
        
        // Hide for now
        [self setHidden:YES];
    }
    
    return self;
}

- (void)updateBeforeImage {
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"dateTaken" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *fetchedArray = [context executeFetchRequest:request error:&error];
    if (fetchedArray == nil)
    {
        NSLog(@"Error while fetching\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        return;
    }
    else if ([fetchedArray count] == 0) {
        [self setBeforeImage:nil];
        NSLog(@"No before image found");
        return;
    }
    BMImage *latestImageObject = [fetchedArray objectAtIndex:0];
    [self setBeforeImage:[[NSImage alloc] initWithData:[latestImageObject imageData]]];
    NSLog(@"Successfully set before image");
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect destinationRect = [BMUtilities rectWithPreservedAspectRatioForSourceSize:[[self beforeImage] size] andBoundingRect:[self bounds]];
    NSAffineTransform* transform = [NSAffineTransform transform];
    [transform scaleXBy:-1.0f yBy:1.0f];
    [transform translateXBy:-self.bounds.size.width yBy:0.0f];
    [transform concat];
    [[self beforeImage] drawInRect:destinationRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

@end
