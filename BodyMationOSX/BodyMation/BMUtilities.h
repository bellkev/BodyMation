//
//  BMUtilities.h
//  BodyMation
//
//  Created by Kevin Bell on 10/31/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVCaptureConnection;

@interface BMUtilities : NSObject {
    
}

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

+ (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock;
+ (void)animateWithDuration:(NSTimeInterval)duration
                  animation:(void (^)(void))animationBlock
                 completion:(void (^)(void))completionBlock;
+ (NSRect)rectWithPreservedAspectRatioForSourceSize:(NSSize)source andBoundingRect:(NSRect)bounds;

+ (CGImageRef)CGImageFromNSImage:(NSImage *)image;

+ (void)buyNow;

+ (NSURL *)getUniqueURLFromBaseURL:(NSURL *)baseURL withManager:(NSFileManager *)manager;

@end