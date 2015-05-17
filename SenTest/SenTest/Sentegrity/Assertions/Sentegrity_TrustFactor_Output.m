//
//  Sentegrity_Assertion.m
//  SenTest
//
//  Created by Kramer on 2/24/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Output.h"
#import "Sentegrity_Constants.h"

// Pod for hashing
#import "NSString+Hashes.h"

@implementation Sentegrity_TrustFactor_Output

-(void)generateAssertionsFromOutput
{

    
    // Create the assertions by iterating through trustfactor output
    for (NSString *trustFactorOutput in self.output) {
        // Create the hashed assertion for the output
        NSString *assertionValue = [[NSString stringWithFormat:@"%@%@%@", [self.trustFactor.identification stringValue],kUniqueDeviceID, trustFactorOutput] sha1]; // TODO: Add in device.id
                                    
        // Add the assertion value to the dictionary with hit count of 0
        [self.assertions setValue:0 forKey:assertionValue];

    }
}

-(void)generateBaselineAssertion
{
    NSMutableDictionary *assertionsDict = [[NSMutableDictionary alloc] init];
    NSString *baseline = self.trustFactor.baseline;
    
    //Create the baseline assertion instead of the trustfactor output
    NSString *assertionValue = [[NSString stringWithFormat:@"%@%@%@", [self.trustFactor.identification stringValue],kUniqueDeviceID,baseline] sha1];
        
    // Add the assertion value to the dictionary with hit count of 0
    [assertionsDict setValue:0 forKey:assertionValue];
    self.assertions = assertionsDict;
}

@end
