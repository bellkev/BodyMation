//
//  BMBrowserViewController.m
//  BodyMation
//
//  Created by Kevin Bell on 11/7/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMBrowserViewController.h"
#import "BMWindowController.h"
#import "BMUtilities.h"
#import "BMImage.h"
#import "BMViewWithColor.h"

@interface BMBrowserViewController ()
- (void)updateZoomValue:(NSNotification *)notification;
@end

@implementation BMBrowserViewController

@synthesize imagesSortDescriptors;
@synthesize arrayController;
@synthesize imageBrowserView;
@synthesize scrollView;
@synthesize windowController;
@synthesize imageArrayController;
@synthesize startView;
@synthesize welcomeView;
@synthesize firstPictureView;

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
    // Setup background
    CALayer* backgroundLayer = [CALayer layer];
    [backgroundLayer setBackgroundColor:CGColorCreateGenericGray(0.2, 1.0)];
    [[self view] setLayer:backgroundLayer];
    [[self view] setWantsLayer:YES];
    
    // Setup imageBrowser
    [imageBrowserView setContentResizingMask:NSViewWidthSizable];
    NSColor* background = [NSColor colorWithCalibratedWhite:0.2 alpha:1.0];
    [imageBrowserView setValue:background forKey:IKImageBrowserBackgroundColorKey];
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSColor colorWithCalibratedWhite:0.8 alpha:1.0], NSForegroundColorAttributeName,
                                     [NSNumber numberWithFloat:15.0], NSStrokeWidthAttributeName,
                                     [NSFont fontWithName:@"Lucida Grande" size:12], NSFontAttributeName,
                                     nil];
    [[self imageBrowserView] setValue:titleAttributes forKey:IKImageBrowserCellsTitleAttributesKey];
    [[self imageBrowserView] setZoomValue:0.92f];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateZoomValue:) name:NSWindowDidResizeNotification object:[self windowController]];
    
    // Set initial scroll position
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollUpdate:) name:@"IKImageBrowserDidStabilize" object:imageBrowserView];
    
    // Set tutorial display properties
    [startView fillWithColor:[NSColor colorWithCalibratedWhite:1.0f alpha:1.0f]];
    [[self startView] setFrame:[[self view] bounds]];
    [[self view] addSubview:[self startView]];
    [[self welcomeView] setFrame:NSMakeRect(50.0f, 100.0f, 590.0f, 380.0f)];
    [[self startView] addSubview:[self welcomeView]];
    [[self firstPictureView] setFrame:NSMakeRect(0.0f, 100.0f, 640.0f, 380.0f)];
    NSLog(@"View size: %f %f", self.view.bounds.size.width, self.view.bounds.size.height);
    [[self startView] addSubview:[self firstPictureView]];

    // Set images sort desciptors
    NSSortDescriptor* sort;
    sort = [NSSortDescriptor sortDescriptorWithKey:@"dateTaken" ascending:YES];
    [self setImagesSortDescriptors:[NSArray arrayWithObject:sort]];
}

- (void)scrollUpdate:(id)sender {
    if ([[self windowController] shouldScrollToNewestImage]) {
        NSUInteger lastIndex = [[self imageBrowserView] numberOfColumns] - 1;
        [[self imageBrowserView] scrollIndexToVisible:lastIndex];
        [[self windowController] setShouldScrollToNewestImage:NO];
        NSLog(@"Scroll to latest");
    }
}

- (IBAction)buyButtonWasClicked:(id)sender {
    [BMUtilities buyNow];
    NSLog(@"Clicked");
    [[self buyButton] setState:NSOffState];
}

- (IBAction)deleteButtonWasClicked:(id)sender {
    NSAlert *deleteAlert = [NSAlert alertWithMessageText:@"Delete Confirmation" defaultButton:@"Delete" alternateButton:@"Cancel" otherButton:@"" informativeTextWithFormat:@"Are you sure you want to delete the selected picture(s)? You can't undo this."];
    NSInteger button = [deleteAlert runModal];
    if (button == NSAlertDefaultReturn) {
        NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
        NSArray *toDelete = [[self imageArrayController] selectedObjects];
        for (BMImage *image in toDelete) {
            [context deleteObject:image];
        }
    }
}

- (void)updateZoomValue:(NSNotification *)notification {
    // Workaround to keep imageBrowserView zoom set to desired value
    if ([[self imageBrowserView] zoomValue] != 0.92f) {
        [[self imageBrowserView] setZoomValue:0.92f];
    }
}
@end
