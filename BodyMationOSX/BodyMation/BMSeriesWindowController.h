//
//  BMSeriesWindowController.h
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/22/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BMSeriesWindowController : NSWindowController <NSWindowDelegate, NSTableViewDelegate>

@property NSArray *seriesSortDescriptors;
@property (strong) IBOutlet NSArrayController *seriesArrayController;
@property (unsafe_unretained) IBOutlet NSTableView *seriesTableView;

- (IBAction)doneButtonWasClicked:(id)sender;
- (IBAction)plusButtonWasClicked:(id)sender;
- (IBAction)minusButtonWasClicked:(id)sender;

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row;

@end
