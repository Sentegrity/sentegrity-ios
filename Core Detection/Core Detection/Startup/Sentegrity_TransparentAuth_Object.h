//
//  Sentegrity_TrustFactor_Datasets.h
//  Sentegrity
//
//  Copyright (c) 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_TransparentAuth_Object : NSObject

// Transparent Key Hash
@property (nonatomic, assign) NSString* transparentKeyPBKDF2HashString;

// User Password Encrypted Master Key IV
@property (nonatomic, assign) NSString* transparentKeyEncryptedMasterKeyBlobString;

// User Password Encrypted Master Key Blob
@property (nonatomic, assign) NSString* transparentKeyEncryptedMasterKeySaltString;

// Hit Counter
@property (atomic,retain) NSNumber *hitCount;

// Date and Time of last hit
@property (atomic,retain) NSNumber *lastTime;

// Date and Time first created
@property (atomic,retain) NSNumber *created;

// How many time to learn from
@property (atomic) double decayMetric;


@end