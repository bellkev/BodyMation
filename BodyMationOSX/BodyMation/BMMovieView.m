//
//  BMMovieView.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 1/10/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import "BMMovieView.h"

@implementation BMMovieView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)dragImage:(NSImage *)anImage at:(NSPoint)viewLocation offset:(NSSize)initialOffset event:(NSEvent *)event pasteboard:(NSPasteboard *)pboard source:(id)sourceObj slideBack:(BOOL)slideFlag {
    ;
}
@end
