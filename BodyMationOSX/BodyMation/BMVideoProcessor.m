//
//  BMVideoProcessor.m
//  BodyMationOSX
//
//  Created by Kevin Bell on 1/9/13.
//  Copyright (c) 2013 Kevin Bell. All rights reserved.
//

#import "BMVideoProcessor.h"
#import "BMImage.h"
#import "BMSeries.h"
#import "BMAppDelegate.h"
#import "BMWindowController.h"
#import "BMUtilities.h"

@interface BMVideoProcessor ()
@property NSURL *tempDir;
@property NSURL *movieURL;
@property id callbackTarget;
@property SEL callbackSelector;
@property id callbackObject;
- (NSOperation*)renderVideoOperation;
- (NSInteger)framesPerSecondForNumberOfFrames:(NSInteger)frames;
- (CVPixelBufferRef)bufferFromImageObject:(BMImage *)imageObject;
- (NSArray *)getAllImages;
- (void)renderVideo;
@end

@implementation BMVideoProcessor

@synthesize isRendering;
@synthesize tempDir;
@synthesize movieURL;
@synthesize callbackTarget;
@synthesize callbackSelector;
@synthesize callbackObject;

- (id)init {
    self = [super init];
    if (self) {
        NSError *error = nil;
        // Get a temp file path
        // This works... but what the hell does "appropriateForURL" mean?
        NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *newTempDir = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory inDomain:NSUserDomainMask appropriateForURL:appSupportDir create:YES error:&error];
        if (error) {
            NSLog(@"ERROR creating Temp Directory: %@", error);
        }
        [self setTempDir:newTempDir];
        [self setMovieURL:[NSURL URLWithString:@"movie.mov" relativeToURL:[self tempDir]]];
    }
    return self;
}

- (void)updateVideoWithCallbackTarget:(id)target selector:(SEL)selector object:(id)object {
    [self setIsRendering:YES];
    NSLog(@"Creating video...");
    [self setCallbackTarget:target];
    [self setCallbackSelector:selector];
    [self setCallbackObject:object];
    NSOperation *renderOperation = [self renderVideoOperation];
    NSOperationQueue *renderQueue = [[NSOperationQueue alloc] init];
    [renderQueue setName:@"Rendering Queue"];
    [renderQueue addOperation:renderOperation];
    NSLog(@"Done with updateVideo...");
}

- (NSOperation*)renderVideoOperation {
    NSLog(@"Render video operation...");
    NSInvocationOperation* renderOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(renderVideo) object:nil];
    NSLog(@"Operation: %@", renderOperation);
    return renderOperation;
}

- (NSInteger)framesPerSecondForNumberOfFrames:(NSInteger)frames {
    const int frameRateTable[] = {1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9};
    BOOL manualFrameRateDefault = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManualFrameRate"];
    NSInteger frameRate = [[NSUserDefaults standardUserDefaults] integerForKey:@"FrameRate"];
    if (manualFrameRateDefault) {
        NSLog(@"Manual frame rate");
        return frameRate;
    }
    else if (frames == 0) {
        return 0;
    }
    else if (frames > 18) {
        return 10;
    }
    else {
        return frameRateTable[frames - 1];
    }
}

- (NSArray *)getAllImages {
    NSSet *imageSet = [[[[NSApp delegate] windowController] currentSeries] images];
    NSSortDescriptor* sort;
    sort = [NSSortDescriptor sortDescriptorWithKey:@"dateTaken" ascending:YES];
    return [imageSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

- (CVPixelBufferRef)bufferFromImageObject:(BMImage *)imageObject {
    // Get resized NSImage from BMImage
    NSImage *imageOriginal = [[NSImage alloc] initWithData:[imageObject imageData]];
    [imageOriginal setCacheMode:NSImageCacheNever];
    //NSImage *imageResized = [BMUtilities resizeImageForVideo:imageOriginal];
    // Get pixel buffer
    CVPixelBufferRef pixelBuffer = [BMUtilities fastImageFromNSImage:imageOriginal];
    return pixelBuffer;
}

- (void)renderVideo {
    NSLog(@"Starting renderVideo...");
    // Check if movie already up to date
    BMSeries *currentSeries = [[[NSApp delegate] windowController] currentSeries];
    if (![currentSeries movieIsCurrent]) {
        // Get array of image objects
        NSArray *images = [self getAllImages];
        
        NSInteger frameRate = [self framesPerSecondForNumberOfFrames:[images count]];
        NSError *error = nil;
        // Remove movie file if it exists
        if ([[self movieURL] checkResourceIsReachableAndReturnError:nil]) {
            [[NSFileManager defaultManager] removeItemAtURL:[self movieURL] error:&error];
        }
        if (error) {
            NSLog(@"%@",error);
        }
        
        // Setup AVAssetWriter
        AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:[self movieURL] fileType:AVFileTypeQuickTimeMovie error:&error];
        if (error) {
            NSLog(@"ERROR creating AVAssetWriter: %@", error);
        }
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       AVVideoCodecH264, AVVideoCodecKey,
                                       [NSNumber numberWithInt:1920], AVVideoWidthKey,
                                       [NSNumber numberWithInt:1080], AVVideoHeightKey,
                                       nil];
        AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                           assetWriterInputWithMediaType:AVMediaTypeVideo
                                           outputSettings:videoSettings];
        
        NSParameterAssert(writerInput);
        NSParameterAssert([writer canAddInput:writerInput]);
        [writer addInput:writerInput];
        AVAssetWriterInputPixelBufferAdaptor * avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
        
        // Start
        [writer startWriting];
        
        // Write each frame to video
        [writer startSessionAtSourceTime:kCMTimeZero];
        int frameCount = 0;
        for (BMImage *image in images) {
            @autoreleasepool {
                CVPixelBufferRef pixelBuffer = [self bufferFromImageObject:image];
                while (![writerInput isReadyForMoreMediaData]) {
                    // Wait a minute to allow writing
                    [NSThread sleepForTimeInterval:0.1f];
                }
                [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:CMTimeMake(frameCount, (int)frameRate)];
                frameCount++;
                NSLog(@"Wrote frame %d", frameCount);
                // Added this while profiling
                CVPixelBufferRelease(pixelBuffer);
            }
        }
        
        [writerInput markAsFinished];
        //[videoWriter endSessionAtSourceTime:];
        
        // Finish
        [writer finishWriting];
        
        // Update movie data
        // weird behavior when loading directly from file: http://stackoverflow.com/questions/6263716/qtkit-a-file-or-directory-could-not-be-found/13335557#13335557
        //[self setMovieData:[NSData dataWithContentsOfURL:[self movieURL]]];
        [currentSeries setMovieData:[NSData dataWithContentsOfURL:[self movieURL]]];
        // Indicate that movie is up to date
        [currentSeries setMovieIsCurrent:YES];
    }
    else {
        NSLog(@"Returned early from renderVideo");
    }
    [[self callbackTarget] performSelectorOnMainThread:[self callbackSelector] withObject:[self callbackObject] waitUntilDone:YES];
    [self setIsRendering:NO];
    NSLog(@"Done with renderVideo");
    return;
}

- (void)dealloc {
    [[NSFileManager defaultManager] removeItemAtURL:[self tempDir] error:nil];
}

@end
