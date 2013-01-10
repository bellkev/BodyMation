//
//  BMVideoProcessor.h
//  BodyMationOSX
//
//  Created by Kevin Bell on 1/9/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMVideoProcessor : NSObject

@property BOOL isRendering;

- (void)updateVideoWithCallbackTarget:(id)target selector:(SEL)selector object:(id)object;

@end
