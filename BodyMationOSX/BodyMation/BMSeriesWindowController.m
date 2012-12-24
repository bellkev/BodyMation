//
//  BMSeriesWindowController.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/22/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMSeriesWindowController.h"
#import "BMWindowController.h"
#import "BMSeries.h"

@interface BMSeriesWindowController ()
- (void)duplicateWasEntered:(NSNotification *)note;
@end

@implementation BMSeriesWindowController

@synthesize seriesSortDescriptors;
@synthesize seriesArrayController;
@synthesize seriesTableView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Set sort type for series array controller
        NSSortDescriptor *sort;
        sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [self setSeriesSortDescriptors:[NSArray arrayWithObject:sort]];
        // Listen to duplicate series name notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duplicateWasEntered:) name:@"DuplicateSeriesNameNotification" object:[NSApp delegate]];
        // Set window delegate to handle closing
        [[self window] setDelegate:self];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // TODO: Select series that is the current series
}

- (void)duplicateWasEntered:(NSNotification *)note {
    NSAlert *duplicateAlert = [NSAlert alertWithMessageText:@"Series Name Already Exists" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You cannot give a picture series the same name as another series."];
    [duplicateAlert runModal];
}

- (void)windowWillClose:(NSNotification *)notification {
    // Force notification about core data updates so popup button is updated
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    [context processPendingChanges];
    BMWindowController *controller = [[NSApp delegate] windowController];
    // Get selected series
    NSArray *selectedSeries = [[self seriesArrayController] selectedObjects];
    // Get all series
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Series"];
    NSError *error = nil;
    NSArray *fetchedArray = [context executeFetchRequest:request error:&error];
    if (fetchedArray == nil)
    {
        NSLog(@"Error while fetching\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
    }
    // Don't do anything if nothing was selected on close
    if ([selectedSeries count]) {
        BMSeries *selected = [selectedSeries objectAtIndex:0];
        [controller setCurrentSeriesName:[selected name]];
        [[controller seriesPopupButton] selectItemWithTitle:[controller currentSeriesName]];
    }
    // Handle the case of no series left
    else if (![fetchedArray count]) {
        [controller setCurrentSeriesName:@""];
    }
}

- (IBAction)doneButtonWasClicked:(id)sender {
    [self close];
}

- (IBAction)plusButtonWasClicked:(id)sender {
    //[[self seriesTableView] setDelegate:self];
    BMSeries *newSeries = [BMSeries seriesInDefaultContext];
    // Get a unique new name
    NSString *newNameBase = @"New Series";
    NSString *newName = [NSString stringWithString:newNameBase];
    NSUInteger repeatNumber = 2;
    while ([BMSeries checkIfSeriesExistsWithName:newName]) {
        newName = [NSString stringWithFormat:@"%@ %ld", newNameBase, repeatNumber];
        repeatNumber ++;
    }
    [newSeries setName:newName];
    // Force notification about core data updates so popup button is updated
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    [context processPendingChanges];
    NSUInteger newIndex = [[[self seriesArrayController] arrangedObjects] indexOfObjectPassingTest:^(id element, NSUInteger idx, BOOL * stop){
        BMSeries *series = (BMSeries *)element;
        *stop = (series.name == newName);
        return *stop;}];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:newIndex];
    NSUInteger seriesNameColumn = [[self seriesTableView] columnWithIdentifier:@"SeriesName"];
    [[self seriesTableView] selectRowIndexes:indexes byExtendingSelection:NO];
    [[self seriesTableView] editColumn:seriesNameColumn row:newIndex withEvent:nil select:YES];
}


- (IBAction)minusButtonWasClicked:(id)sender {
    NSAlert *deleteAlert = [NSAlert alertWithMessageText:@"Delete Series Confirmation" defaultButton:@"Delete" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Are you really sure you want to delete this series? This cannot be undone."];
    NSInteger button = [deleteAlert runModal];
    if (button == NSAlertDefaultReturn) {
        [[self seriesArrayController] removeObjectsAtArrangedObjectIndexes:[[self seriesArrayController] selectionIndexes]];
    }
}

@end
