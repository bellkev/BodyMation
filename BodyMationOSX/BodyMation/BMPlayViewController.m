//
//  BMPlayViewController.m
//  BodyMation
//
//  Created by Kevin Bell on 11/10/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMPlayViewController.h"
#import "BMImage.h"
#import <AVFoundation/AVFoundation.h>
#import "BMUtilities.h"

@interface BMPlayViewController ()
@property NSURL *tempDir;
@property NSURL *movieURL;
- (CVPixelBufferRef)bufferFromImageObject:(BMImage *)imageObject;
- (NSArray *)getAllImages;
- (NSOperation *)renderVideoOperation;
- (void)showVideo;
@end

@implementation BMPlayViewController

@synthesize windowController;
@synthesize movieData;
@synthesize movieView;
@synthesize movie;
@synthesize movieURL;
@synthesize tempDir;
@synthesize progressIndicator;
@synthesize movieNeedsRefresh;
@synthesize renderText;
@synthesize controllerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    // Initialize
    NSError *error = nil;
    // Get a temp file path
    // This works... but what the hell does "appropriateForURL" mean?
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *newTempDir = [[NSFileManager defaultManager] URLForDirectory:NSItemReplacementDirectory inDomain:NSUserDomainMask appropriateForURL:appSupportDir create:YES error:&error];
    //NSURL *newTempDir = [NSURL fileURLWithPath:@"/Users/Kevin"];
    if (error) {
        NSLog(@"ERROR creating Temp Directory: %@", error);
    }
    [self setTempDir:newTempDir];
    [self setMovieURL:[NSURL URLWithString:@"movie.mov" relativeToURL:[self tempDir]]];
    [self setMovieNeedsRefresh:YES];
    // Set background color to dark gray
    CALayer *backgroundLayer = [[CALayer alloc] init];
    [backgroundLayer setBackgroundColor:CGColorCreateGenericGray(0.2, 1.0)];
    [[self view] setLayer:backgroundLayer];
    [[self view] setWantsLayer:YES];
    // Hide play/pause buttons to start
    [[self controllerView] setHidden:YES];
    // Set up movie
    [self createVideo];
}

- (void)createVideo {
    NSLog(@"Creating video...");
    [[self movieView] setHidden:YES];
    [[self controllerView] setHidden:YES];
    [[self progressIndicator] startAnimation:nil];
    [[self renderText] setHidden:NO];
    NSOperation *renderOperation = [self renderVideoOperation];
    NSOperationQueue *renderQueue = [[NSOperationQueue alloc] init];
    [renderQueue setName:@"Rendering Queue"];
    [renderQueue addOperation:renderOperation];
    NSLog(@"Done with createVideo...");
}

- (void)showVideo {
    [[self movie] setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieLoopsAttribute];
    [[self movieView] setMovie:[self movie]];
    [[self progressIndicator] stopAnimation:nil];
    [[self renderText] setHidden:YES];
    [[self movieView] setHidden:NO];
    [[self controllerView] setHidden:NO];
    [[self playButton] setHidden:NO];
    [[self pauseButton] setHidden:YES];
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

- (void)renderVideo {
    NSLog(@"Starting rendering...");
    NSInteger frameRate = [self framesPerSecondForNumberOfFrames:10];
    NSError *error = nil;
    // Remove movie file if it exists
    if ([[self movieURL] checkResourceIsReachableAndReturnError:nil]) {
        [[NSFileManager defaultManager] removeItemAtURL:[self movieURL] error:&error];
    }
    if (error) {
        NSLog(@"%@",error);
    }
    // Wipe out the current movie
    [self setMovie:nil];
    
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
    
    // Get array of image objects
    NSArray *images = [self getAllImages];
    
    // Write each frame to video
    [writer startSessionAtSourceTime:kCMTimeZero];
    int frameCount = 0;
    for (BMImage *image in images) {
        CVPixelBufferRef pixelBuffer = [self bufferFromImageObject:image];
        while (![writerInput isReadyForMoreMediaData]) ;//NSLog(@"Not ready for data");
        [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:CMTimeMake(frameCount, (int)frameRate)];
        frameCount++;
    }
    [writerInput markAsFinished];
    //[videoWriter endSessionAtSourceTime:];
    
    // Finish
    [writer finishWriting];
    
    // Update movie data
    // weird behavior when loading directly from file: http://stackoverflow.com/questions/6263716/qtkit-a-file-or-directory-could-not-be-found/13335557#13335557
    [self setMovieData:[NSData dataWithContentsOfURL:[self movieURL]]];
    
    // And the movie itself
    [self setMovie:[QTMovie movieWithData:[self movieData] error:&error]];
    if (error) {
        NSLog(@"ERROR: %@", error);
    }
    //[[self movieView] setMovie:[self movie]];
    [self performSelectorOnMainThread:@selector(showVideo) withObject:nil waitUntilDone:YES];
    // Indicate that movie is up to date
    [self setMovieNeedsRefresh:NO];
    NSLog(@"Done rendering...");
}

- (IBAction)playButtonWasPushed:(id)sender {
    [[self movieView] play:nil];
    [[self playButton] setHidden:YES];
    [[self pauseButton] setHidden:NO];
}

- (IBAction)pauseButtonWasPushed:(id)sender {
    [[self movieView] pause:nil];
    [[self pauseButton] setHidden:YES];
    [[self playButton] setHidden:NO];
}

- (IBAction)firstButtonWasPushed:(id)sender {
    [[self movieView] gotoBeginning:nil];
}

- (IBAction)lastButtonWasPushed:(id)sender {
    [[self movieView] gotoEnd:nil];
}

- (CVPixelBufferRef)bufferFromImageObject:(BMImage *)imageObject {
    // Get resized NSImage from BMImage
    NSImage *imageOriginal = [[NSImage alloc] initWithData:[imageObject imageData]];
    NSImage *imageResized = [BMUtilities resizeImageForVideo:imageOriginal];
    // Get pixel buffer
    CVPixelBufferRef pixelBuffer = [BMUtilities fastImageFromNSImage:imageResized];
    return pixelBuffer;
}

//- (CVPixelBufferRef)bufferFromImageObject:(BMImage *)imageObject {
//    // Get CGImage from BMImage
//    NSImage *imageOriginal = [[NSImage alloc] initWithData:[imageObject imageData]];
//    NSImage *imageResized = [BMUtilities resizeImageForVideo:imageOriginal];
////    CFDataRef data = (CFDataRef)CFBridgingRetain([imageResized TIFFRepresentation]);
////    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
////    CGImageRef image = CGImageCreateWithJPEGDataProvider(dataProvider, nil, YES, kCGRenderingIntentDefault);
//    NSGraphicsContext *graphicsContext = [[NSGraphicsContext alloc] init];
//    NSRect imageRect = NSMakeRect(0.0f, 0.0f, 1080.0f, 1920.0f);
//    CGImageRef image = [imageResized CGImageForProposedRect:&imageRect context:graphicsContext hints:nil];
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
//                             nil];
//    CVPixelBufferRef pxbuffer = NULL;
//    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
//                                          CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (CFDictionaryRef) CFBridgingRetain(options),
//                                          &pxbuffer);
//    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
//    
//    CVPixelBufferLockBaseAddress(pxbuffer, 0);
//    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
//    NSParameterAssert(pxdata != NULL);
//    
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
//                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
//                                                 kCGImageAlphaNoneSkipFirst);
//    NSParameterAssert(context);
//    CGContextConcatCTM(context, CGAffineTransformIdentity);
//    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
//                                           CGImageGetHeight(image)), image);
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    
//    return pxbuffer;
//}

- (NSArray *)getAllImages {
    NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"dateTaken" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    NSError *error = nil;
    NSArray *fetchedArray = [context executeFetchRequest:request error:&error];
    if (fetchedArray == nil)
    {
        NSLog(@"Error while fetching\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
    }
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (BMImage* imageObject in fetchedArray) {
        [imageArray addObject:imageObject];
    }
    return imageArray;
}

- (void)dealloc {
    [[NSFileManager defaultManager] removeItemAtURL:[self tempDir] error:nil];
}

@end
