//
//  BMKeyChecker.m
//  BodyMation
//
//  Created by Kevin Bell on 12/17/12.
//  Copyright (c) 2012 Kevin Bell. All rights reserved.
//

#import "BMKeyChecker.h"
#import <openssl/rsa.h>
#import <openssl/pem.h>
#import <openssl/sha.h>
#import <openssl/bio.h>
#import <openssl/evp.h>

#include <string.h>
#include <openssl/hmac.h>
#include <openssl/buffer.h>

@implementation BMKeyChecker


+ (BOOL)verifyKey:(NSString *)key andEmail:(NSString *)email {    
    uint8_t pub_key[] = {
        0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x42, 0x45, 0x47, 0x49, 0x4e, 0x20, 0x50, 0x55, 0x42, 0x4c, 0x49, 0x43, 0x20, 0x4b,
        0x45, 0x59, 0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x0a, 0x4d, 0x49, 0x47, 0x66, 0x4d, 0x41, 0x30, 0x47, 0x43, 0x53, 0x71,
        0x47, 0x53, 0x49, 0x62, 0x33, 0x44, 0x51, 0x45, 0x42, 0x41, 0x51, 0x55, 0x41, 0x41, 0x34, 0x47, 0x4e, 0x41, 0x44,
        0x43, 0x42, 0x69, 0x51, 0x4b, 0x42, 0x67, 0x51, 0x43, 0x6f, 0x31, 0x72, 0x62, 0x46, 0x35, 0x6c, 0x51, 0x37, 0x6e,
        0x4d, 0x6d, 0x49, 0x72, 0x77, 0x6f, 0x57, 0x56, 0x79, 0x5a, 0x4e, 0x4d, 0x64, 0x54, 0x5a, 0x0a, 0x66, 0x79, 0x7a,
        0x2b, 0x75, 0x65, 0x70, 0x34, 0x39, 0x36, 0x45, 0x46, 0x31, 0x31, 0x62, 0x72, 0x4e, 0x53, 0x37, 0x77, 0x62, 0x69,
        0x74, 0x77, 0x71, 0x54, 0x49, 0x79, 0x71, 0x67, 0x38, 0x45, 0x37, 0x66, 0x33, 0x64, 0x54, 0x44, 0x6c, 0x4b, 0x6f,
        0x76, 0x66, 0x6c, 0x70, 0x4d, 0x53, 0x4c, 0x78, 0x73, 0x69, 0x68, 0x72, 0x74, 0x63, 0x73, 0x63, 0x34, 0x67, 0x6f,
        0x63, 0x58, 0x50, 0x56, 0x0a, 0x57, 0x75, 0x71, 0x7a, 0x68, 0x64, 0x45, 0x76, 0x56, 0x2b, 0x47, 0x33, 0x5a, 0x32,
        0x38, 0x35, 0x4b, 0x4f, 0x56, 0x34, 0x6a, 0x39, 0x5a, 0x4f, 0x2f, 0x68, 0x4d, 0x62, 0x4e, 0x42, 0x63, 0x59, 0x30,
        0x30, 0x75, 0x42, 0x36, 0x63, 0x47, 0x50, 0x61, 0x68, 0x38, 0x5a, 0x53, 0x53, 0x42, 0x4b, 0x4e, 0x75, 0x35, 0x30,
        0x2b, 0x70, 0x43, 0x4b, 0x73, 0x6d, 0x4f, 0x4b, 0x69, 0x36, 0x58, 0x68, 0x0a, 0x73, 0x79, 0x73, 0x6e, 0x38, 0x37,
        0x76, 0x4d, 0x57, 0x44, 0x72, 0x65, 0x62, 0x71, 0x7a, 0x42, 0x55, 0x77, 0x49, 0x44, 0x41, 0x51, 0x41, 0x42, 0x0a,
        0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x45, 0x4e, 0x44, 0x20, 0x50, 0x55, 0x42, 0x4c, 0x49, 0x43, 0x20, 0x4b, 0x45, 0x59,
        0x2d, 0x2d, 0x2d, 0x2d, 0x2d, 0x0a
    };
    
    // Convert email into char array
    
    const char * data = [email UTF8String];
    
    // Convert base64 product key to  char array
    
    NSData *NSSerialNoData = [self decodeBase64WithString:key];
    
    char *serialNoData = (void *)[NSSerialNoData bytes];
    
    RSA *rsa_pkey = NULL;
    EVP_PKEY *pkey;
    EVP_MD_CTX ctx;
    size_t len = [email length]; // exclude terminating null character from length
    unsigned int siglen = (unsigned int)[NSSerialNoData length];
    bool success;
    
    BIO* bio = BIO_new_mem_buf(pub_key, sizeof(pub_key));
    success = PEM_read_bio_RSA_PUBKEY(bio, &rsa_pkey, NULL, NULL);
    if (!success) {
        NSLog(@"Error loading RSA public key from memory");
        return NO;
    }
    
        
    pkey = EVP_PKEY_new();
    
    success = EVP_PKEY_assign_RSA(pkey, rsa_pkey);
    if (!success) {
        NSLog(@"EVP_PKEY_assign_RSA: failed");
        return NO;
    }
    
    EVP_MD_CTX_init(&ctx);

    if (!EVP_VerifyInit(&ctx, EVP_sha1())) {
        NSLog(@"EVP_SignInit: failed");
        return NO;
    }
    
    if (!EVP_VerifyUpdate(&ctx, data, len)) {
        NSLog(@"EVP_SignUpdate: failed");
        return NO;
    }
    
    if (!EVP_VerifyFinal(&ctx, serialNoData, siglen, pkey)) {
        NSLog(@"EVP_VerifyFinal: failed");
        return NO;
    }
    
    return YES;
}

+ (NSData *)decodeBase64WithString:(NSString *)strBase64 {
    static const short _base64DecodingTable[256] = {
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
        -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
        -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
        -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
    };
    
    const char *objPointer = [strBase64 cStringUsingEncoding:NSASCIIStringEncoding];
    size_t intLength = strlen(objPointer);
    int intCurrent;
    int i = 0, j = 0, k;
    
    unsigned char *objResult = calloc(intLength, sizeof(unsigned char));
    
    // Run through the whole string, converting as we go
    while ( ((intCurrent = *objPointer++) != '\0') && (intLength-- > 0) ) {
        if (intCurrent == '=') {
            if (*objPointer != '=' && ((i % 4) == 1)) {// || (intLength > 0)) {
                // the padding character is invalid at this point -- so this entire string is invalid
                free(objResult);
                return nil;
            }
            continue;
        }
        
        intCurrent = _base64DecodingTable[intCurrent];
        if (intCurrent == -1) {
            // we're at a whitespace -- simply skip over
            continue;
        } else if (intCurrent == -2) {
            // we're at an invalid character
            free(objResult);
            return nil;
        }
        
        switch (i % 4) {
            case 0:
                objResult[j] = intCurrent << 2;
                break;
                
            case 1:
                objResult[j++] |= intCurrent >> 4;
                objResult[j] = (intCurrent & 0x0f) << 4;
                break;
                
            case 2:
                objResult[j++] |= intCurrent >>2;
                objResult[j] = (intCurrent & 0x03) << 6;
                break;
                
            case 3:
                objResult[j++] |= intCurrent;
                break;
        }
        i++;
    }
    
    // mop things up if we ended on a boundary
    k = j;
    if (intCurrent == '=') {
        switch (i % 4) {
            case 1:
                // Invalid state
                free(objResult);
                return nil;
                
            case 2:
                k++;
                // flow through
            case 3:
                objResult[k] = 0;
        }
    }
    
    // Cleanup and setup the return NSData
    NSData * objData = [[NSData alloc] initWithBytes:objResult length:j];
    free(objResult);
    return objData;
}

@end
