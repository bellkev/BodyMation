//
//  BMTutorialWindowController.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 1/8/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import "BMTutorialWindowController.h"

@interface BMTutorialWindowController ()

@end

@implementation BMTutorialWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [[self window] setBackgroundColor:[NSColor colorWithCalibratedWhite:0.15 alpha:0.5]];
    [[self window] setOpaque:NO];
}

@end
