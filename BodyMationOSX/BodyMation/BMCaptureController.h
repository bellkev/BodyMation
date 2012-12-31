//
//  BMCaptureController.h
//  BodyMationOSX
//
//  Created by Kevin Bell on 12/30/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BMCaptureController : NSObject

@property AVCaptureSession *captureSession;
@property AVCaptureInput *videoInput;

- (void)setInputDevice:(AVCaptureDevice *)device;

@end
