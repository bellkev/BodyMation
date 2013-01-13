//
//  BodyMationAppTests.m
//  BodyMationAppTests
//
//  Created by Kevin Bell on 1/12/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import "BodyMationAppTests.h"
#import "BMAppDelegate.h"
#import "BMWindowController.h"
#import "BMSeries.h"
#import "BMImage.h"

@implementation BodyMationAppTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    // Some parameters
    NSString *sourcePath = @"/Users/Kevin/Test Images";
    NSInteger repeats = 10;
    
    NSError *error;
    // Create a new series
    BMSeries *series = [BMSeries seriesInDefaultContext];
    [series setName:@"Test Series"];
    
    // Get list of files
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *imagePaths = [fileManager contentsOfDirectoryAtPath:sourcePath error:&error];
    if (error) {
        NSLog(@"ERROR: %@", error);
    }
    
    // Add images
    while (repeats > 0) {
        for (NSString *imagePath in imagePaths) {
            if ([imagePath hasSuffix:@".jpg"]) {
                BMImage *image = [BMImage imageInDefaultContext];
                NSString *fullPath = [sourcePath stringByAppendingPathComponent:imagePath];
                NSData *imageData = [NSData dataWithContentsOfFile:fullPath];
                [image setImageData:imageData];
                NSDate *date = [NSDate date];
                [image setDateTaken:date];
                [series addImagesObject:image];
                NSLog(@"Added image with path: %@", fullPath);
            }
        }
        repeats --;
    }
    // Save
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    [context save:&error];
    if (error) {
        NSLog(@"ERROR: %@", error);
    }
}

@end
