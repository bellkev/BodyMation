//
//  BMProcessingWindowController.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 1/10/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import "BMProcessingWindowController.h"

@interface BMProcessingWindowController ()

@end

@implementation BMProcessingWindowController

@synthesize progressIndicator;
@synthesize parentFrame;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (id)initWithWindowNibName:(NSString *)windowNibName andParentFrame:(NSRect)frame {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        [self setParentFrame:frame];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSRect mainFrame = [self parentFrame];
    NSRect processingFrame = [[self window] frame];
    NSPoint processingOrigin;
    processingOrigin.x = mainFrame.origin.x + (mainFrame.size.width - processingFrame.size.width) / 2;
    processingOrigin.y = mainFrame.origin.y + (mainFrame.size.height - processingFrame.size.height) / 2;
    [[self window] setFrameOrigin:processingOrigin];
    [[self progressIndicator] startAnimation:nil];
}

@end
