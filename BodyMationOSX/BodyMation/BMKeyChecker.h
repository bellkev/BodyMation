//
//  BMKeyChecker.h
//  BodyMation
//
//  Created by Kevin Bell on 12/17/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMKeyChecker : NSObject

+ (BOOL)verifyKey:(NSString *)key andEmail:(NSString *)email;

+ (NSData *)decodeBase64WithString:(NSString *)strBase64;

@end
