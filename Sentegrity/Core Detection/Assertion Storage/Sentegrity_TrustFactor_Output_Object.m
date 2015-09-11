//
//  Sentegrity_Assertion.m
//  SenTest
//
//  Created by Kramer on 2/24/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_Constants.h"

// Pod for hashing
#import "NSString+Hashes.h"


@implementation Sentegrity_TrustFactor_Output_Object


-(BOOL)generatedAssertionObjectsContainsDefault{
    for (Sentegrity_Stored_Assertion *candidateAssertionObject in self.assertionObjects){
        if([[candidateAssertionObject assertionHash] isEqualToString:[[self defaultAssertionObject] assertionHash]]){
            return YES;
        }
    }
    
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
        [new setDecayMetric:10.0];
        
        // Add object to the array
        [assertionObjects addObject:new];
        
    }
    
    // Set property
    self.assertionObjects= assertionObjects;
    
}

- (id) init {
    if (self = [super init]) {
        
        // Set the DNE to OK
        [self setStatusCode:DNEStatus_ok];
        
        [self generateDefaultAssertionObject];
        
    }
    return self;
}

@end
