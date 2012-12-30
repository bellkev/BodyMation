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
@property NSData *movieData;
@property /*(weak)*/ IBOutlet QTMovieView *movieView;
@property QTMovie *movie;
@property BOOL movieNeedsRefresh;
@property /*(weak)*/ IBOutlet NSProgressIndicator *progressIndicator;
@property /*(weak)*/ IBOutlet NSTextField *renderText;
@property (unsafe_unretained) IBOutlet NSButton *playButton;
@property (unsafe_unretained) IBOutlet NSButton *pauseButton;


- (void)createVideo;
- (void)renderVideo;
- (IBAction)playButtonWasPushed:(id)sender;
- (IBAction)pauseButtonWasPushed:(id)sender;

@end
