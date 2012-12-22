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
    // Set up movie
    [self createVideo];
}

- (void)createVideo {
    NSLog(@"Creating video...");
    [[self movieView] setHidden:YES];
    [[self progressIndicator] startAnimation:nil];
    [[self renderText] setHidden:NO];
    NSOperation *renderOperation = [self renderVideoOperation];
    NSOperationQueue *renderQueue = [[NSOperationQueue alloc] init];
    [renderQueue setName:@"Rendering Queue"];
    [renderQueue addOperation:renderOperation];
    NSLog(@"Done with createVideo...");
}

- (void)showVideo {
    [[self movieView] setMovie:[self movie]];
    [[self progressIndicator] stopAnimation:nil];
    [[self renderText] setHidden:YES];
    [[self movieView] setHidden:NO];
}

- (NSOperation*)renderVideoOperation {
    NSLog(@"Render video operation...");
    NSInvocationOperation* renderOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(renderVideo) object:nil];
    NSLog(@"Operation: %@", renderOperation);
    return renderOperation;
}

- (void)renderVideo {
    NSLog(@"Starting rendering...");
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
                                   [NSNumber numberWithInt:640], AVVideoWidthKey,
                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
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
        //NSLog(@"Loop");
        CVPixelBufferRef pixelBuffer = [self bufferFromImageObject:image];
        while (![writerInput isReadyForMoreMediaData]) ;//NSLog(@"Not ready for data");
        [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:CMTimeMake(frameCount * 10, 100)];
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

- (CVPixelBufferRef)bufferFromImageObject:(BMImage *)imageObject {
    // Get CGImage from BMImage
    CFDataRef data = (CFDataRef)CFBridgingRetain([imageObject imageData]);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
    CGImageRef image = CGImageCreateWithJPEGDataProvider(dataProvider, nil, YES, kCGRenderingIntentDefault);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                                          CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (CFDictionaryRef) CFBridgingRetain(options),
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

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
