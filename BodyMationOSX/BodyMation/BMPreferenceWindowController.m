//
//  BMPreferenceWindowController.m
//  BodyMation
//
//  Created by Kevin Bell on 11/11/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMPreferenceWindowController.h"

@interface BMPreferenceWindowController ()

@end

@implementation BMPreferenceWindowController

@synthesize beforeColor;
@synthesize beforeHighlight;

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
}

@end
