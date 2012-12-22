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


- (void)createVideo;
- (void)renderVideo;

@end
