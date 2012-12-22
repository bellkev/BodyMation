//
//  BMPreferenceWindowController.h
//  BodyMation
//
//  Created by Kevin Bell on 11/11/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BMPreferenceWindowController : NSWindowController

@property /*(weak)*/ IBOutlet NSButton *beforeHighlight;

@property /*(weak)*/ IBOutlet NSColorWell *beforeColor;

@end
