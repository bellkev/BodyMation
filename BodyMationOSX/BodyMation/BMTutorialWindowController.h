//
//  BMTutorialWindowController.h
//  BodyMationOSX
//
//  Created by Kevin Bell on 1/8/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BMTutorialWindowController : NSWindowController
@property (weak) IBOutlet NSTextField *instructionLabel;
@property NSString *instructionText;

- (IBAction)closeButtonWasPresssed:(id)sender;


@end
