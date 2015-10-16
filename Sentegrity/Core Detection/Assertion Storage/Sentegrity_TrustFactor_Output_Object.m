//
//  Sentegrity_Assertion.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Output_Object.h"

// Stored Assertion
#import "Sentegrity_Stored_Assertion.h"

// Pod for hashing
#import "NSString+Hashes.h"

@implementation Sentegrity_TrustFactor_Output_Object

#pragma mark - Init

// Custom init
- (id)init {
    if (self = [super init]) {
        
        // Set the DNE to OK
        _statusCode = DNEStatus_ok;
        
    }
    return self;
}

#pragma mark - Helpers

// Generate a default (read; Empty) Assertion Object
- (Sentegrity_Stored_Assertion *)defaultAssertionObject {
    
    // Create a new stored assertion object
    Sentegrity_Stored_Assertion *newStoredAssertion = [[Sentegrity_Stored_Assertion alloc] init];
    
    // Create default assertion string
    NSString *defaultAssertionString = [[[NSString stringWithFormat:@"%@%@%@",
                                        [self.trustFactor.identification stringValue],
                                        kUniqueDeviceID,
                                        kDefaultTrustFactorOutput]
                                        sha1]
                                        stringByAppendingString:[NSString stringWithFormat:@"-%@",
                                                                      kDefaultTrustFactorOutput]];
    // Current Date
    NSDate *now = [NSDate date];
    
    // Current epoch date in seconds
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    
    // Set the values of the assertion object
    [newStoredAssertion setAssertionHash:defaultAssertionString];
    [newStoredAssertion setLastTime:[NSNumber numberWithInteger:nowEpochSeconds]];
    [newStoredAssertion setHitCount:[NSNumber numberWithInt:1]];
    [newStoredAssertion setCreated:[NSNumber numberWithInteger:nowEpochSeconds]];
    [newStoredAssertion setDecayMetric:10.0];
    
    // Set property
    return newStoredAssertion;
    
}

// Set the assertion objects from
- (BOOL)setAssertionObjectsFromOutput:(NSArray *)output {
    
    // Validate the output
    if (!output || output == nil || output.count < 1) {
        // Invalid output array - Return No
        return NO;
    }
    
    // Temporary mutable array to hold Sentegrity_Stored_Assertion objects
    NSMutableArray *assertionObjects = [[NSMutableArray alloc]init];
    
    // Create the assertions by iterating through trustfactor output
    for (NSString *trustFactorOutput in self.output) {
        
        // Create new object
        Sentegrity_Stored_Assertion *new = [[Sentegrity_Stored_Assertion alloc] init];
        
        // Create the hash
        NSString *hash = [[[NSString stringWithFormat:@"%@%@%@",
                            [self.trustFactor.identification stringValue],
                            kUniqueDeviceID,
                            trustFactorOutput]
                           sha1]
                          stringByAppendingString:[NSString stringWithFormat:@"-%@",trustFactorOutput]];
        
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
    self.assertionObjects = assertionObjects;
    
    // Return value
    return YES;
    
}

@end
