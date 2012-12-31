//
//  BMImage.h
//  BodyMation
//
//  Created by Kevin Bell on 11/7/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BMSeries;

@interface BMImage : NSManagedObject

@property (nonatomic, retain) NSDate * dateTaken;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) BMSeries *series;

+ (id)imageInDefaultContext;
- (NSString *)imageTitle;
- (NSString *)imageTitleNoSlashes;

@end
