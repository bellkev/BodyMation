//
//  BMSeries.m
//  BodyMation
//
//  Created by Kevin Bell on 11/7/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMSeries.h"
#import "BMImage.h"


@implementation BMSeries

@dynamic name;
@dynamic images;
@dynamic movieIsCurrent;
@dynamic movieData;

+ (id)seriesInDefaultContext {
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    
    BMSeries *newSeries;
    newSeries = [NSEntityDescription insertNewObjectForEntityForName:@"Series" inManagedObjectContext:context];
    
    return newSeries;
}

+ (BOOL)checkIfSeriesExistsWithName:(NSString *)name {
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Series"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedArray = [context executeFetchRequest:request error:&error];
    if (fetchedArray == nil)
    {
        NSLog(@"Error while fetching\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
    }
    NSLog(@"Found %ld series", [fetchedArray count]);
    return (BOOL)[fetchedArray count];
}

+ (BMSeries *)seriesForName:(NSString *)name {
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Series"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *fetchedArray = [context executeFetchRequest:request error:&error];
    if (fetchedArray == nil)
    {
        NSLog(@"Error while fetching\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        return nil;
    }
    else if ([fetchedArray count] == 0) {
        return nil;
    }
    BMSeries *series = [fetchedArray objectAtIndex:0];
    return series;
}

- (void)setName:(NSString *)newName {
    // Check for a duplicate
    if (![BMSeries checkIfSeriesExistsWithName:newName]) {
            [self willChangeValueForKey:@"name"];
            [self setPrimitiveValue:newName forKey:@"name"];
            [self didChangeValueForKey:@"name"];
        }
    // Post notification if there is a duplicate
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DuplicateSeriesNameNotification" object:[NSApp delegate]];
    }
}

- (BMImage *)getMostRecentImage {
    if (![[self images] count]) {
        return nil;
    }
    NSSet *imageSet = [self images];
    NSSortDescriptor* sort;
    sort = [NSSortDescriptor sortDescriptorWithKey:@"dateTaken" ascending:NO];
    NSArray *imageArray = [imageSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    return [imageArray objectAtIndex:0];
}

@end
