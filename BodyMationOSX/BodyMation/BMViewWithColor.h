//
//  BMViewWithColor.h
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/31/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BMViewWithColor : NSView

@property NSColor *fillColor;

- (void)fillWithColor:(NSColor *)color;

@end
