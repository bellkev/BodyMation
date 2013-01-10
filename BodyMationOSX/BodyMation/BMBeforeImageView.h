//
//  BMBeforeImageView.h
//  BodyMation
//
//  Created by Kevin Bell on 11/1/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BMBeforeImageView : NSView

@property NSImage *beforeImage;
@property CALayer *beforeImageLayer;
@property NSColor *borderColor;

- (id)initWithFrame:(NSRect)frameRect andBorderColor:(NSColor *)color;
- (void)updateBeforeImage;

@end
