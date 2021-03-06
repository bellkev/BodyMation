//
//  BMSeries.h
//  BodyMation
//
//  Created by Kevin Bell on 11/7/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BMImage;

@interface BMSeries : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic) BOOL movieIsCurrent;
@property (nonatomic, retain) NSData * movieData;

@end

@interface BMSeries (CoreDataGeneratedAccessors)

+ (id)seriesInDefaultContext;
+ (BOOL)checkIfSeriesExistsWithName:(NSString *)name;
+ (BMSeries *)seriesForName:(NSString *)name;

- (void)addImagesObject:(BMImage *)value;
- (void)removeImagesObject:(BMImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;
- (BMImage *)getMostRecentImage;

@end
