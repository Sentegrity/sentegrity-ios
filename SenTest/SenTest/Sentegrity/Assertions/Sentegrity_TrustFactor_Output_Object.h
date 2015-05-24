//
//  Sentegrity_Assertion.h
//  SenTest
//
//  Created by Kramer on 2/24/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Stored_TrustFactor_Object.h"
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_Constants.h"


@interface Sentegrity_TrustFactor_Output_Object : NSObject

// attach the policy trustfactor data
@property (nonatomic,retain) Sentegrity_TrustFactor *trustFactor;

// attach the parsed storedTrustFactorObject data
@property (nonatomic,retain) Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject;

// Get the trustfactor output
@property (nonatomic,retain) NSMutableArray *output;

// Assertions to whitelist if protect mode is deactivated
@property (nonatomic,retain) NSMutableDictionary *assertionsToWhitelist;

// Stored assertions
@property (nonatomic,retain) NSMutableDictionary *assertions;

// Get the trustfactor output dne modifier (only if the check failed or didn't run)
@property (nonatomic) DNEStatusCode statusCode;

// Generates assertions from the output of trustfactor impleentation
- (void)generateAssertionsFromOutput;

// Generates default assertion for manual comparison on provisoning rules
-(NSMutableDictionary *)generateDefaultAssertion;

//custom init to set DNE=OK
- (id) init;

@end
