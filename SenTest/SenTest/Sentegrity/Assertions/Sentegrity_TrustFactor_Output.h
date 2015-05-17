//
//  Sentegrity_Assertion.h
//  SenTest
//
//  Created by Kramer on 2/24/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_Constants.h"

@interface Sentegrity_TrustFactor_Output : NSObject

// Get the trustfactor
@property (nonatomic,retain) Sentegrity_TrustFactor *trustFactor;

// Get the trustfactor output
@property (nonatomic,retain) NSArray *output;

// Assertions to whitelist that found no match in the storedTrustFactorObject
@property (nonatomic,retain) NSArray *assertionsTriggered;

// Stored assertions
@property (nonatomic,retain) NSMutableDictionary *assertions;

// Did the trustfactor run
@property BOOL executed;

// Get the trustfactor output dne modifier (only if the check failed or didn't run)
@property (nonatomic) DNEStatusCode statusCode;


- (void)generateAssertionsFromOutput;
- (void)generateBaselineAssertion;

@end
