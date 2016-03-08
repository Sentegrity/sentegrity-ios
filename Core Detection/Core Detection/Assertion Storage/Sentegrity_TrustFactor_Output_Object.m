//
//  Sentegrity_Assertion.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_Constants.h"

// Pod for hashing
#import "NSString+Hashes.h"

@implementation Sentegrity_TrustFactor_Output_Object


// Set assertion objects from output
-(void)setAssertionObjectsFromOutput
{
    // Temporary mutable array to hold Sentegrity_Stored_Assertion objects
    NSMutableArray *assertionObjects = [[NSMutableArray alloc]init];
    
    // Create the assertions by iterating through trustfactor output
    for (NSString *trustFactorOutput in self.output) {
        
        // Create new object
        Sentegrity_Stored_Assertion *new = [[Sentegrity_Stored_Assertion alloc]init];
        
        // Create the hash
        NSString *hash = [[[NSString stringWithFormat:@"%@%@%@", [self.trustFactor.identification stringValue],kUniqueDeviceID, trustFactorOutput] sha1]stringByAppendingString:[NSString stringWithFormat:@"-%@",trustFactorOutput]];
        
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
    self.candidateAssertionObjects= assertionObjects;
    
}

// Override init to our defaults
- (id) init {
    if (self = [super init]) {
        
        // Set the DNE to OK
        [self setStatusCode:DNEStatus_ok];
        
        
    }
    return self;
}

@end
