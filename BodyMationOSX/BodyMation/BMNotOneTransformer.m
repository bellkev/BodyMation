//
//  BMNotOneTransformer.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 1/1/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import "BMNotOneTransformer.h"

@implementation BMNotOneTransformer

+ (Class)transformedValueClass {
    return [NSNumber class];
}
+ (BOOL)allowsReverseTransformation {
    return NO;
}
- (id)transformedValue:(id)value {
    if ([value integerValue] == 1) {
        return [NSNumber numberWithInt:0];
    }
    else {
        return [NSNumber numberWithInt:1];
    }
}

@end
