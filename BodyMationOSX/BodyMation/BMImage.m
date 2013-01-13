//
//  BMImage.m
//  BodyMation
//
//  Created by Kevin Bell on 11/7/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMImage.h"
#import "BMSeries.h"
#import <Quartz/Quartz.h>

@interface BMImage ()
- (void) generateUniqueID;
@end

@implementation BMImage

@dynamic dateTaken;
@dynamic imageData;
@dynamic series;
@dynamic uniqueID;

+ (id)imageInDefaultContext {
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    
    BMImage *newImage;
    newImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    
    return newImage;
}

- (NSString *)imageTitle {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateString = [formatter stringFromDate:[self dateTaken]];
    return dateString;
}

- (NSString *)imageTitleNoSlashes {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // TODO: Check that this isn't the buggy date format
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:[self dateTaken]];
    return dateString;
}

- (NSString *)imageRepresentationType {
    return IKImageBrowserNSDataRepresentationType;
}

- (NSString *)imageUID {
    // return uniqueID if it exists.
    NSString* uniqueID = [self uniqueID];
    if (uniqueID) {
        return uniqueID;
    }
    [self generateUniqueID];
    return [self uniqueID];
}

- (id)imageRepresentation {
    return [self imageData];
}

- (void) generateUniqueID {
    NSString* uniqueID = [self uniqueID];
    if (uniqueID != nil) {
        return;
    }
    [self setUniqueID:[[NSProcessInfo processInfo] globallyUniqueString]];
}

@end
