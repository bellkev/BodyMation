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

@implementation BMImage

@dynamic dateTaken;
@dynamic imageData;
@dynamic series;

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
    // Note: The image browser appears to only look at the beginning of the string
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterLongStyle];
    NSString *dateString = [formatter stringFromDate:[self dateTaken]];
    return dateString;
}

- (id)imageRepresentation {
    return [self imageData];
}

@end
