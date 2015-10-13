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
        
        // Generate the default assertion objects
        [self generateDefaultAssertionObject];
        
    }
    return self;
}

#pragma mark - Helpers

// Check if the generated Assertion Object contains the default
- (BOOL)generatedAssertionObjectsContainsDefault {
    // Run through all the assertion objects
    for (Sentegrity_Stored_Assertion *candidateAssertionObject in self.assertionObjects) {
        // Check if the candidate hash contains the default assertion hash
        if ([[candidateAssertionObject assertionHash] isEqualToString:[[self defaultAssertionObject] assertionHash]]) {
            // Matches
            return YES;
        }
    }
    
    // Return NO
    return NO;
}

-(void)generateDefaultAssertionObject
{
    
    Sentegrity_Stored_Assertion *new = [[Sentegrity_Stored_Assertion alloc]init];
    
    NSString *defaultAssertionString = [[[NSString stringWithFormat:@"%@%@%@", [self.trustFactor.identification stringValue],kUniqueDeviceID, kDefaultTrustFactorOutput] sha1]stringByAppendingString:[NSString stringWithFormat:@"-%@",kDefaultTrustFactorOutput]];
    
    NSDate *now = [NSDate date];
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    
    [new setAssertionHash:defaultAssertionString];
    [new setLastTime:[NSNumber numberWithInteger:nowEpochSeconds]];
    [new setHitCount:[NSNumber numberWithInt:1]];
    [new setCreated:[NSNumber numberWithInteger:nowEpochSeconds]];
    [new setDecayMetric:10.0];
    
    // Set property
    self.defaultAssertionObject = new;
    
}

-(void)setAssertionObjectsToDefault
{
    // Generate and set the default assertion object
    
    // Set assertion objects array to just the default object
    self.assertionObjects = [[NSArray alloc] initWithObjects:[self defaultAssertionObject],nil];
    
}

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
    self.assertionObjects= assertionObjects;
    
}

@end
