//
//  Sentegrity_Assertion.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_Constants.h"
#import "Sentegrity_Startup_Store.h"

// Pod for hashing
#import "NSString+Hashes.h"

@implementation Sentegrity_TrustFactor_Output_Object


// Set assertion objects from output
- (void)setAssertionObjectsFromOutputWithError: (NSError **) error {
    
    // Temporary mutable array to hold Sentegrity_Stored_Assertion objects
    NSMutableArray *assertionObjects = [[NSMutableArray alloc]init];
    
    //get startup file to
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:error];
    if (*error != nil) {
        //found error in reading startup file, stop it
        return;
    }

    // Create the assertions by iterating through trustfactor output
    for (NSString *trustFactorOutput in self.output) {
        
        // Create new object
        Sentegrity_Stored_Assertion *new = [[Sentegrity_Stored_Assertion alloc]init];
        
        
        // Create the hash
        // For Debug purposes
        
        NSError *error;
        Sentegrity_Policy *policy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
        
        NSString *hash;
        
        if (policy.debugEnabled.intValue==1) {
            
            // Do not hash
            hash = [NSString stringWithFormat:@"%@_%@_%@", [self.trustFactor.identification stringValue], startup.deviceSaltString, trustFactorOutput];
        }
        else{
            // For Prod
            hash = [[NSString stringWithFormat:@"%@_%@_%@", [self.trustFactor.identification stringValue], startup.deviceSaltString, trustFactorOutput] sha1];
        }


        
        // Get EPOCH
        NSDate *now = [NSDate date];
        NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
        
        // Set object properties
        [new setAssertionHash:hash];
        [new setLastTime:[NSNumber numberWithInteger:nowEpochSeconds]];
        [new setHitCount:[NSNumber numberWithInt:1]];
        [new setCreated:[NSNumber numberWithInteger:nowEpochSeconds]];
        [new setDecayMetric:1.0];
        
        // Add object to the array
        [assertionObjects addObject:new];
    }
    
    // Set property
    self.candidateAssertionObjects = assertionObjects;
    
}

// Override init to our defaults
- (id)init {
    if (self = [super init]) {
        // Set the DNE to OK
        _statusCode = DNEStatus_ok;
    }
    return self;
}

@end
