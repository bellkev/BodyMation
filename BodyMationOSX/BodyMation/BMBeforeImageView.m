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
        // Set before image to most recent image
        
        // Make autoresize
        [self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        // Host layer
        [self setLayer:[CALayer layer]];
        [self setWantsLayer:YES];
        [self setBeforeImageLayer:[CALayer layer]];
        [[self beforeImageLayer] setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
        [[self beforeImageLayer] setContentsGravity:kCAGravityResizeAspect];
        [[self beforeImageLayer] setFrame:[self bounds]];
        
        // Flip to match the preview video
        CATransform3D flipTransform = CATransform3DScale(CATransform3DIdentity, -1.0, 1.0, 1.0);
        [[self beforeImageLayer] setTransform:flipTransform];
        [[self layer] addSublayer:[self beforeImageLayer]];
        
        // Set layer content to before image
        [self updateBeforeImage];
        [[self beforeImageLayer] setContents:[BMUtilities CGImageFromNSImage:[self beforeImage]]];
        
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
        return;
    }
    BMImage *latestImageObject = [fetchedArray objectAtIndex:0];
    [self setBeforeImage:[[NSImage alloc] initWithData:[latestImageObject imageData]]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
