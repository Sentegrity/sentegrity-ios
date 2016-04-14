//
//  DAFUtils.h
//  DAFsupport
//
//  Created by Ian Harvey on 11/06/2014.
//  Copyright (c) 2014 Good Technology. All rights reserved.
//

/* \brief Objective-C utility functions for DAF applications
 *
 */

#import <Foundation/Foundation.h>

@interface DAFUtils : NSObject

+ (NSData *)hashSHA256:(NSData *)message;
/**< Computes the SHA-256 hash of the supplied message */

+ (NSData *)hashSHA512:(NSData *)message;
/**< Computes the SHA-512 hash of the supplied message */

+ (NSData *)generateRandom:(NSUInteger)byteCount;
/**< Generates a random data block of the requested length */

+ (NSData *)PBKDF2_SHA256:(NSString *)password withSalt:(NSData *)salt iterations:(uint32_t)count
             outputLength:(NSUInteger)length;
/**< Derives a key from a password string through repeated SHA256 hashing */

+ (NSData *)PBKDF2_SHA256:(NSString *)password withSalt:(NSData *)salt;
/**< Derives a key from a password string through repeated hashing, using a default iterations
     count and a standard (32-byte) output length. */

+ (NSData *)PBKDF2_SHA512:(NSString *)password withSalt:(NSData *)salt iterations:(uint32_t)count
             outputLength:(NSUInteger)length;
/**< Derives a key from a password string through repeated SHA512 hashing */

+ (NSData *)PBKDF2_SHA512:(NSString *)password withSalt:(NSData *)salt;
/**< Derives a key from a password string through repeated hashing, using a default iterations
 count and a standard (64-byte) output length. */

+ (NSString *)base64Encode:(NSData *)data;
/**< Encodes an arbitrary byte block into an ASCII text string */

+ (NSData *)base64Decode:(NSString *)message;
/**< Decodes a base64-encoded text string back a byte block.
     Caution! returns nil if the text cannot be decoded. */

@end
