//
//  BMRegisterWindowController.h
//  BodyMation
//
//  Created by Kevin Bell on 12/18/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BMRegisterWindowController : NSWindowController
@property /*(weak)*/ IBOutlet NSTextField *emailField;
@property /*(weak)*/ IBOutlet NSTextField *keyField;
@property /*(weak)*/ IBOutlet NSView *licensedView;
@property /*(weak)*/ IBOutlet NSView *trialView;
- (IBAction)buyButtonPushed:(id)sender;

- (IBAction)cancelButtonPushed:(id)sender;
- (IBAction)registerButtonPushed:(id)sender;
- (IBAction)enterKeyPressedInKeyField:(id)sender;

- (void)registerApplication;

@end
