//
//  BMUtilities.m
//  BodyMation
//
//  Created by Kevin Bell on 10/31/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMUtilities.h"
#import <AVFoundation/AVFoundation.h>

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

+ (CGImageRef)CGImageFromNSImage:(NSImage *)image {
        NSData * imageData = [image TIFFRepresentation];
        CGImageRef imageRef;
        if(!imageData) return nil;
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
        imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        return imageRef;
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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.google.com/"]];
}

+ (NSURL *)getUniqueURLFromBaseURL:(NSURL *)baseURL withManager:(NSFileManager *)manager {
    NSInteger repeatNumber = 1;
    NSString *currentPath = [baseURL path];
    while ([manager fileExistsAtPath:currentPath]) {
        currentPath = [NSString stringWithFormat:@"%@-%ld", [baseURL path], repeatNumber];
        repeatNumber++;
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

@end