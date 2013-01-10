//
//  BMPlayViewController.h
//  BodyMation
//
//  Created by Kevin Bell on 11/10/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface BMPlayViewController : NSViewController

@property NSWindowController *windowController;
@property (weak) IBOutlet QTMovieView *movieView;
@property QTMovie *movie;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *renderText;
@property (unsafe_unretained) IBOutlet NSButton *playButton;
@property (unsafe_unretained) IBOutlet NSButton *pauseButton;
@property (weak) IBOutlet NSView *controllerView;


- (void)updateVideo;
- (IBAction)playButtonWasPushed:(id)sender;
- (IBAction)pauseButtonWasPushed:(id)sender;
- (IBAction)firstButtonWasPushed:(id)sender;
- (IBAction)lastButtonWasPushed:(id)sender;

@end
