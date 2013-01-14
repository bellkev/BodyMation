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
#import "BMUtilities.h"

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
            @autoreleasepool {
            if ([imagePath hasSuffix:@".jpg"]) {
                BMImage *image = [BMImage imageInDefaultContext];
                NSString *fullPath = [sourcePath stringByAppendingPathComponent:imagePath];
                NSData *imageData = [NSData dataWithContentsOfFile:fullPath];
                NSImage *imageOriginal = [[NSImage alloc] initWithData:imageData];
                NSImage *imageRotated = [BMUtilities rotateImage:imageOriginal byDegrees:90.0f];
                NSData *imageDataFinal = [imageRotated TIFFRepresentation];
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageDataFinal];
                NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
                imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
                [image setImageData:imageData];
                NSDate *date = [NSDate date];
                [image setDateTaken:date];
                [series addImagesObject:image];
                NSLog(@"Added image with path: %@", fullPath);
            }
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
