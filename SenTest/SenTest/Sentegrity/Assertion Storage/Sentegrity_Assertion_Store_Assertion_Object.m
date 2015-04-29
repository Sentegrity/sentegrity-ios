//
//  Sentegrity_Assertion_Store_Assertion_Object.m
//  SenTest
//
//  Created by Kramer on 3/1/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Assertion_Store_Assertion_Object.h"
#import "Sentegrity_Constants.h"

@implementation Sentegrity_Assertion_Store_Assertion_Object

// Compare the assertion object values
- (instancetype)compare:(Sentegrity_Assertion *)assertion withError:(NSError **)error {
    // Validate original assertion and replacement assertions
    if (!assertion || assertion == nil) {
        // Error out, no assertion objects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Missing provided assertion object" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Compare self values against the values in the passed assertion
    
    // Check if the revision number is different - if so, clean it out completely
    if (self.revision != assertion.revision) {
        // Create a new assertion object for the provided assertion
        Sentegrity_Assertion_Store_Assertion_Object *assertionObject = [[Sentegrity_Assertion_Store_Assertion_Object alloc] init];
        [assertionObject setFactorID:assertion.trustFactor.identification];
        [assertionObject setRevision:assertion.revision];
        [assertionObject setHistory:assertion.trustFactor.history];
        [assertionObject setLearned:assertion.trustFactor.learnMode];
        [assertionObject setFirstRun:[NSDate date]];
        [assertionObject setRunCount:[NSNumber numberWithInt:1]];
        // Create the stored value
        Sentegrity_Assertion_Store_Assertion_Object_Stored_Value *stored = [[Sentegrity_Assertion_Store_Assertion_Object_Stored_Value alloc] init];
        // TODO: BETA2 Fix assertion object creation hashing
        [stored setHashValue:assertion.output];
        [stored setHitCount:[NSNumber numberWithInt:1]];
        [assertionObject setStored:stored];
        
        // Return assertion object
        return assertionObject;
    }
    
    self.history = [assertion.trustFactor history];
    self.learned = [assertion.trustFactor learnMode];
    if (!self.firstRun || self.firstRun == nil) {
        // Set the first run date
        self.firstRun = [assertion runDate];
    }
    self.runCount = [NSNumber numberWithInt:(self.runCount.intValue + 1)];
    [self.stored setHitCount:[NSNumber numberWithInt:(self.stored.hitCount.intValue + 1)]];
    // TODO: BETA2 Fix assertion object creation hashing
    //[self.stored setHashValue:assertion.returnResult.stringValue];
    
    // Return self
    return self;
}

@end
