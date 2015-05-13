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
    NSMutableArray *assertionsArray = [NSMutableArray arrayWithCapacity:self.output.count];
    
    // Create the assertions by iterating through trustfactor output
    for (NSString *trustFactorOutput in self.output) {
        // Create the hashed assertion for the output - might replace the output someday
        NSString *assertionValue = [[NSString stringWithFormat:@"%@%@%@", [self.trustFactor.identification stringValue],kUniqueDeviceID, trustFactorOutput] sha1]; // TODO: Add in device.id
                                    
        // Add the assertion value to the assertion array
        [assertionsArray addObject:assertionValue];
        self.assertions = assertionsArray;
    }
}

-(void)generateBaselineAssertion
{
    NSMutableArray *assertionsArray = [NSMutableArray arrayWithCapacity:self.output.count];
    NSString *baseline = self.trustFactor.baseline;
    
    //Create the baseline assertion instead of the trustfactor output
    NSString *assertionValue = [[NSString stringWithFormat:@"%@%@%@", [self.trustFactor.identification stringValue],kUniqueDeviceID,baseline] sha1];
        
    // Add the assertion value to the assertion array
    [assertionsArray addObject:assertionValue];
    self.assertions = assertionsArray;
}

@end
