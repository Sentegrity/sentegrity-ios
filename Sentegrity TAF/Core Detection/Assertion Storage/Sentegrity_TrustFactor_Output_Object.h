//
//  Sentegrity_Assertion.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Stored_TrustFactor_Object.h"
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_Constants.h"
#import "Sentegrity_Stored_Assertion.h"


@interface Sentegrity_TrustFactor_Output_Object : NSObject

// Attach the policy trustfactor data
@property (nonatomic,retain) Sentegrity_TrustFactor *trustFactor;

// Attach the parsed storedTrustFactorObject data
@property (nonatomic,retain) Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject;

// Plaintext output from TrustFactor
@property (nonatomic,retain) NSArray *output;

// Sentegrity_Stored_Assertion objects to whitelist if protect mode is deactivated
@property (nonatomic,retain) NSArray *assertionObjectsToWhitelist;

// Sentegrity_Store_Assertion objects created from output
@property (nonatomic,retain) NSArray *assertionObjects;

// Default assertion string
@property (nonatomic,retain) Sentegrity_Stored_Assertion *defaultAssertionObject;

// DNE modifier
@property (nonatomic) DNEStatusCode statusCode;

// Trigger bool set during baseline analysis and checked during computation
@property (nonatomic) BOOL triggered;

// Trigger bool set during baseline analysis and checked during computation
@property (nonatomic) BOOL whitelist;

- (void)generateDefaultAssertionObject;

- (void)setAssertionObjectsFromOutput;

- (void)setAssertionObjectsToDefault;

// Custom init to set DNE = OK and defaultAssertionString
- (id) init;


@end