//
//  BMRegisterWindowController.m
//  BodyMation
//
//  Created by Kevin Bell on 12/18/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMRegisterWindowController.h"
#import "BMKeyChecker.h"

@interface BMRegisterWindowController ()

@end

@implementation BMRegisterWindowController

@synthesize emailField;
@synthesize keyField;
@synthesize trialView;
@synthesize licensedView;

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

- (IBAction)cancelButtonPushed:(id)sender {
    [self close];
}

- (IBAction)registerButtonPushed:(id)sender {
    [self registerApplication];
}

- (IBAction)enterKeyPressedInKeyField:(id)sender {
    [self registerApplication];
}

- (void)registerApplication {
    NSString *email = [[self emailField] stringValue];
    NSString *key = [[self keyField] stringValue];
    // Just trim email (should also validate with regex)
    NSString *emailTrimmed = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Remove anything in key string but base64 characters
    NSMutableString *keyCleaned = [NSMutableString stringWithCapacity:[key length]];
    NSScanner *keyScanner = [NSScanner scannerWithString:key];
    NSCharacterSet *base64Set = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="];
    while (![keyScanner isAtEnd]) {
        NSString *newCharacters;
        if ([keyScanner scanCharactersFromSet:base64Set intoString:&newCharacters]) {
            [keyCleaned appendString:newCharacters];
        } else {
            [keyScanner setScanLocation:([keyScanner scanLocation] + 1)];
        }
    }
    
    // Verify key and email
    BOOL valid = [BMKeyChecker verifyKey:keyCleaned andEmail:emailTrimmed];
    NSString *alertMessage = @"Sorry, unable to verify key.";
    if (valid) {
        alertMessage = @"You have successfully registered BodyMation! Thank you!";
        [[self trialView] setHidden:YES];
        [[self licensedView] setHidden:NO];
    }
    NSAlert *keyAlert = [NSAlert alertWithMessageText:@"Registration Results" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", alertMessage];
    [keyAlert runModal];
}

@end
