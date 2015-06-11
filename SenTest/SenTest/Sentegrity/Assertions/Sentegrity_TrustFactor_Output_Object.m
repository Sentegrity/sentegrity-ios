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

// called during baseline analysis
- (void)generateAssertionsFromOutput
{

   self.assertions = [[NSMutableDictionary alloc]init];
    
    //hit count starts at 0 since these are candidate assertions that may possibly be NEW and copied into the store after protect mode deactivation
    NSNumber *hitCount = [NSNumber numberWithInt:0];
    
    // Create the assertions by iterating through trustfactor output
    for (NSString *trustFactorOutput in self.output) {
        // Create the hashed assertion for the output
        NSString *assertionValue = [[NSString stringWithFormat:@"%@%@%@", [self.trustFactor.identification stringValue],kUniqueDeviceID, trustFactorOutput] sha1]; // TODO: Add in device.id
            
        // Add the assertion value to the dictionary with hit count of 0
        [self.assertions setValue:hitCount forKey:assertionValue];

    }
}

//called for provisoning rules
-(NSMutableDictionary *)generateDefaultAssertion
{

    NSString *assertionValue = [[NSString stringWithFormat:@"%@%@%@", [self.trustFactor.identification stringValue],kUniqueDeviceID, kDefaultTrustFactorOutput] sha1]; // TODO: Add in device.id
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setValue:[NSNumber numberWithInt:0] forKey:assertionValue];
    
    return dict;

}

- (id) init {
    if (self = [super init]) {
            [self setStatusCode:DNEStatus_ok];
    }
    return self;
}

@end
