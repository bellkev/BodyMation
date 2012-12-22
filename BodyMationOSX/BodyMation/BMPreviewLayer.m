//
//  BMPreviewView.m
//  BodyMation
//
//  Created by Kevin Bell on 12/14/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "BMPreviewLayer.h"
#import "BMUtilities.h"

@implementation BMPreviewLayer

@synthesize currentImage;
@synthesize isCapturing;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self setIsCapturing:NO];
        [self setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
        [self setContentsGravity:kCAGravityResizeAspect];
    }
    
    return self;
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
    
    [self performSelectorOnMainThread:@selector(setContents:) withObject: (__bridge id) imageFinal waitUntilDone:YES];
    //[self setContents:(__bridge id)(imageFinal)];
    // Unlock image buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    [self setIsCapturing:YES];
}

@end
