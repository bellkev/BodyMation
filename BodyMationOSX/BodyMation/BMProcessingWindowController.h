//
//  BMProcessingWindowController.h
//  BodyMationOSX
//
//  Created by Kevin Bell on 1/10/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BMProcessingWindowController : NSWindowController
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property NSRect parentFrame;

- (id)initWithWindowNibName:(NSString *)windowNibName andParentFrame:(NSRect)frame;
@end
