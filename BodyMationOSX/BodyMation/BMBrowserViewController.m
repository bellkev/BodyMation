//
//  BMBrowserViewController.m
//  BodyMation
//
//  Created by Kevin Bell on 11/7/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMBrowserViewController.h"
#import "BMWindowController.h"

@interface BMBrowserViewController ()
- (void)updateZoomValue:(NSNotification *)notification;
@end

@implementation BMBrowserViewController

@synthesize imagesSortDescriptors;
@synthesize arrayController;
@synthesize imageBrowserView;
@synthesize scrollView;
@synthesize windowController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.        
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    // Set imageBrowser display properties
    [imageBrowserView setContentResizingMask:NSViewWidthSizable];
    //[[self imageBrowserView] setCellSize:CGSizeMake(450.0, 300.0)];
    //[[self imageBrowserView] setCellsStyleMask:(IKCellsStyleTitled|IKCellsStyleShadowed)];
    NSColor* background = [NSColor colorWithCalibratedWhite:0.2 alpha:1.0];
    [imageBrowserView setValue:background forKey:IKImageBrowserBackgroundColorKey];
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSColor colorWithCalibratedWhite:0.8 alpha:1.0], NSForegroundColorAttributeName,
                                     [NSNumber numberWithFloat:15.0], NSStrokeWidthAttributeName,
                                     [NSFont fontWithName:@"Lucida Grande" size:12], NSFontAttributeName,
                                     nil];
    [[self imageBrowserView] setValue:titleAttributes forKey:IKImageBrowserCellsTitleAttributesKey];
    // Set images sort desciptors
    NSSortDescriptor* sort;
    sort = [NSSortDescriptor sortDescriptorWithKey:@"dateTaken" ascending:YES];
    [self setImagesSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // Set initial position
    //[[self imageBrowserView] scrollIndexToVisible:3];
    //[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scrollUpdate:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollUpdate:) name:@"IKImageBrowserDidStabilize" object:imageBrowserView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateZoomValue:) name:NSWindowDidResizeNotification object:[self windowController]];
    [[self imageBrowserView] setZoomValue:0.9f];
}

- (void)scrollUpdate:(id)sender {
    if ([[self windowController] shouldScrollToNewestImage]) {
        NSUInteger lastIndex = [[self imageBrowserView] numberOfColumns] - 1;
        [[self imageBrowserView] scrollIndexToVisible:lastIndex];
        [[self windowController] setShouldScrollToNewestImage:NO];
        NSLog(@"Scroll to latest");
    }
}

- (void)updateZoomValue:(NSNotification *)notification {
    // Workaround to keep imageBrowserView zoom set to desired value
    if ([[self imageBrowserView] zoomValue] != 0.95f) {
        [[self imageBrowserView] setZoomValue:0.95f];
    }
}
@end
