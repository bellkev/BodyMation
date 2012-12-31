//
//  BMPreviewView.m
//  BodyMation
//
//  Created by Kevin Bell on 12/15/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMPreviewView.h"
#import "BMUtilities.h"

@implementation BMPreviewView

@synthesize frameSize;
@synthesize isCapturing;
@synthesize previewLayer;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        //[self setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
        [self setPreviewLayer:[[CALayer alloc] init]];
        [self setLayer:[self previewLayer]];
        [self setWantsLayer:YES];
        [self setNeedsDisplay:YES];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect destinationRect = [BMUtilities rectWithPreservedAspectRatioForSourceSize:frameSize andBoundingRect:[self bounds]];    
    [[NSColor redColor] setFill];
    NSFrameRectWithWidth(destinationRect, 10);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //Lock the imagebuffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    // Get information about the image
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    [self setFrameSize:CGSizeMake(width, height)];
    // Get exposure information from the exif data
    // TODO: Try using the exposure time in conjunction average intensity to give more accurate real-time brightness info
    //    NSDictionary* exifDict = (NSDictionary*)CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, NULL);
    //    float brightness = 1.0/[[exifDict objectForKey:@"ExposureTime"] floatValue]; // actually just the simple inverse of shutterspeed
    
    // Get CIImage
    CIImage *image = [CIImage imageWithCVImageBuffer:imageBuffer];
    CIImage *resultImage = image;
    CIFilter *flipFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [flipFilter setValue:resultImage forKey:@"inputImage"];
    
    NSAffineTransform* flipTransform = [NSAffineTransform transform];
    [flipTransform scaleXBy:-1.0 yBy:1.0]; //horizontal flip
    //[flipTransform translateXBy:width yBy:0];
    [flipFilter setValue:flipTransform forKey:@"inputTransform"];
    
    resultImage = [flipFilter valueForKey:@"outputImage"];
    
    // Convert to CGImage
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithCIImage:resultImage];
    CGImageRef imageFinal = [rep CGImage];
    
    [[self previewLayer] performSelectorOnMainThread:@selector(setContents:) withObject:(__bridge id)(imageFinal) waitUntilDone:YES];
//    [self setCurrentImage:imageFinal];
//    [self setNeedsDisplay:YES];
    
    // Unlock image buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    [self setIsCapturing:YES];
}

@end
