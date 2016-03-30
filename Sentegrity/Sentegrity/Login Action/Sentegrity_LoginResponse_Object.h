//
//  Sentegrity_TrustFactor_Datasets.h
//  Sentegrity
//
//  Copyright (c) 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_LoginResponse_Object : NSObject

// Device Score
@property (nonatomic, assign) NSInteger authenticationResponseCode;

// Trust Score
@property (nonatomic, assign) NSData *decryptedMasterKey;

// Trust Score
@property (nonatomic, assign) NSString *responseLoginTitle;

// User Score
@property (nonatomic, assign) NSString *responseLoginDescription;

@end