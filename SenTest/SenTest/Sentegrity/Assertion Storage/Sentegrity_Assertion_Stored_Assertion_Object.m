//
//  Sentegrity_Assertion_Store_Assertion_Object.m
//  SenTest
//
//  Created by Kramer on 3/1/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Assertion_Stored_Assertion_Object.h"
#import "Sentegrity_Constants.h"

@implementation Sentegrity_Assertion_Stored_Assertion_Object

// Compare the assertion object values
- (instancetype)compare:(Sentegrity_TrustFactor_Output *)trustFactorOutput withError:(NSError **)error {
    
    // Validate trustfactor object
    if (!trustFactorOutput || trustFactorOutput == nil) {
        // Error out, no assertion objects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Missing provided trustFactorOutput object" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Compare self values against the values in the passed assertion
    
    // Check if the revision number is different - if so, clean it out completely
    if (self.revision != trustFactorOutput.revision) {
        // Create a new assertion object for the provided trustFactorOutput
        Sentegrity_Assertion_Stored_Assertion_Object *newStoredAssertionObject = [[Sentegrity_Assertion_Stored_Assertion_Object alloc] init];
        [newStoredAssertionObject setFactorID:trustFactorOutput.trustFactor.identification];
        [newStoredAssertionObject setRevision:trustFactorOutput.revision];
        [newStoredAssertionObject setHistory:trustFactorOutput.trustFactor.history];
        [newStoredAssertionObject setLearned:trustFactorOutput.trustFactor.learnMode];
        [newStoredAssertionObject setFirstRun:[NSDate date]];
        [newStoredAssertionObject setRunCount:[NSNumber numberWithInt:1]];
        
        // Create the object that holds the stored assertion within the larger assertion object
        Sentegrity_Assertion_Store_Assertion_Object_Stored_Value *storedAssertion = [[Sentegrity_Assertion_Store_Assertion_Object_Stored_Value alloc] init];
        // TODO: BETA2 Fix assertion object creation hashing
        [storedAssertion setHashValue:trustFactorOutput.output];
        [storedAssertion setHitCount:[NSNumber numberWithInt:1]];
        [newStoredAssertionObject setStored:storedAssertion];
        
        // Return new assertion object
        return newStoredAssertionObject;
    }
    
    self.history = [trustFactorOutput.trustFactor history];
    self.learned = [trustFactorOutput.trustFactor learnMode];
    if (!self.firstRun || self.firstRun == nil) {
        // Set the first run date
        self.firstRun = [trustFactorOutput runDate];
    }
    self.runCount = [NSNumber numberWithInt:(self.runCount.intValue + 1)];
    [self.stored setHitCount:[NSNumber numberWithInt:(self.stored.hitCount.intValue + 1)]];
    // TODO: BETA2 Fix assertion object creation hashing
    //[self.stored setHashValue:assertion.returnResult.stringValue];
    
    // Return self
    return self;
}

@end
