//
//  BMUtilities.m
//  BodyMation
//
//  Created by Kevin Bell on 10/31/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMUtilities.h"
#import <AVFoundation/AVFoundation.h>
#import "BMImage.h"

@interface BMUtilities ()
+ (void)runEndBlock:(void (^)(void))completionBlock;
@end

@implementation BMUtilities

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
{
    [self animateWithDuration:duration animation:animationBlock completion:nil];
}
+ (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    animationBlock();
    [NSAnimationContext endGrouping];
    
    if(completionBlock)
    {
        id completionBlockCopy = [completionBlock copy];
        [self performSelector:@selector(runEndBlock:) withObject:completionBlockCopy afterDelay:duration];
    }
}

+ (void)runEndBlock:(void (^)(void))completionBlock
{
    completionBlock();
}

+ (NSRect)rectWithPreservedAspectRatioForSourceSize:(NSSize)source andBoundingRect:(NSRect)bounds {
    NSRect destinationRect;
    int padding;
    float scale;
    float sourceAspectRatio = source.width / source.height;
    float boundsAspectRatio = bounds.size.width / bounds.size.height;
    if (boundsAspectRatio < sourceAspectRatio) {
        // there will be padding on the top/bottom
        scale = bounds.size.width / source.width;
        padding = (bounds.size.height - scale * source.height) / 2;
        destinationRect.origin.x = 0;
        destinationRect.origin.y = padding;
        destinationRect.size.width = scale * source.width;
        destinationRect.size.height = scale * source.height;
    }
    else if (boundsAspectRatio > sourceAspectRatio) {
        // there will be padding on sides
        scale = bounds.size.height / source.height;
        padding = (bounds.size.width - scale * source.width) / 2;
        destinationRect.origin.x = padding;
        destinationRect.origin.y = 0;
        destinationRect.size.width = scale * source.width;
        destinationRect.size.height = scale * source.height;
    }
    else {
        // there will be no padding
        scale = bounds.size.width / source.width;
        destinationRect.origin.x = 0;
        destinationRect.origin.y = 0;
        destinationRect.size.width = scale * source.width;
        destinationRect.size.height = scale * source.height;
    }
    return destinationRect;
}

+ (void)buyNow {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.bodymation.com/buy-now/"]];
}

+ (NSURL *)getUniqueURLFromBaseURL:(NSURL *)url withManager:(NSFileManager *)manager keepSortable:(BOOL)sortable{
    NSURL *urlNoExtension = [url URLByDeletingPathExtension];
    NSString *extension = [url pathExtension];
    NSString *currentPath = [url path];
    NSInteger repeatNumber;
    if (sortable) {
        repeatNumber = 0;
        do {
            currentPath = [NSString stringWithFormat:@"%@-%02ld", [urlNoExtension path], repeatNumber];
            if (![extension isEqualToString:@""]) {
                currentPath = [currentPath stringByAppendingPathExtension:extension];
            }
            repeatNumber++;
            NSLog(@"Current Path: %@",currentPath);
        } while ([manager fileExistsAtPath:currentPath]);
    }
    else {
        repeatNumber = 1;
        while ([manager fileExistsAtPath:currentPath]) {
            currentPath = [NSString stringWithFormat:@"%@-%ld", [urlNoExtension path], repeatNumber];
            if (![extension isEqualToString:@""]) {
                currentPath = [currentPath stringByAppendingPathExtension:extension];
            }
            repeatNumber++;
        }
    }
    return [NSURL fileURLWithPath:currentPath];
}

+ (NSImage*)rotateImage:(NSImage *)image byDegrees:(CGFloat)degrees {
    NSSize rotatedSize = NSMakeSize([image size].height, [image size].width);
    NSImage* rotatedImage = [[NSImage alloc] initWithSize:rotatedSize] ;
    
    NSAffineTransform* transform = [NSAffineTransform transform] ;
    
    // In order to avoid clipping the image, translate
    // the coordinate system to its center
    [transform translateXBy:image.size.width/2 yBy:image.size.height/2] ;
    // then rotate
    [transform rotateByDegrees:degrees];
    // Then translate the origin system back to
    // the bottom left
    [transform translateXBy:-rotatedSize.width/2 yBy:-rotatedSize.height/2] ;
    [rotatedImage lockFocus] ;
    [transform invert]; // this makes working with the transform more intuitive in this case...
    [transform concat];
    [image drawAtPoint:NSMakePoint(0,0)
             fromRect:NSZeroRect
            operation:NSCompositeCopy
             fraction:1.0] ;
    [rotatedImage unlockFocus] ;
    return rotatedImage;
}

+ (CVPixelBufferRef)fastImageFromNSImage:(NSImage *)image
{
    CVPixelBufferRef buffer = NULL;
    
    
    // config
    size_t width = 1920.0f;
    size_t height = 1080.0f;
    size_t bitsPerComponent = 8; // *not* CGImageGetBitsPerComponent(image);
    CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGBitmapInfo bi = kCGImageAlphaNoneSkipFirst; // *not* CGImageGetBitmapInfo(image);
    NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey, [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    
    // create pixel buffer
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, k32ARGBPixelFormat, (__bridge CFDictionaryRef)d, &buffer);
    CVPixelBufferLockBaseAddress(buffer, 0);
    void *rasterData = CVPixelBufferGetBaseAddress(buffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    // context to draw in, set to pixel buffer's address
    CGContextRef ctxt = CGBitmapContextCreate(rasterData, width, height, bitsPerComponent, bytesPerRow, cs, bi);
    if(ctxt == NULL){
        NSLog(@"could not create context");
        CGColorSpaceRelease(cs);
        return NULL;
    }
    
    // draw
    NSGraphicsContext *nsctxt = [NSGraphicsContext graphicsContextWithGraphicsPort:ctxt flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:nsctxt];
    
    NSRect imageRect = NSMakeRect(0.0f, 0.0f, width, height);
    NSRect destinationRect = [BMUtilities rectWithPreservedAspectRatioForSourceSize:[image size] andBoundingRect:imageRect];
    [[NSColor blackColor] setFill];
    NSRectFill(imageRect);
    [image drawInRect:destinationRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0f];
    
    [NSGraphicsContext restoreGraphicsState];
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    // have to do this even though ARC?
    //CVPixelBufferRelease(buffer);
    CGColorSpaceRelease(cs);
    CFRelease(ctxt);
    return buffer;
}
@end