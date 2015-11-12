//
//  Sentegrity_Assertion_Store+Helper.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_Assertion_Store+Helper.h"

@implementation Sentegrity_Assertion_Store (Helper)

#pragma mark - Helper Methods (kind of)

// Create an assertion object from an assertion
- (Sentegrity_Stored_TrustFactor_Object *)createStoredTrustFactorObjectFromTrustFactorOutput:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    // Check that the passed trustFactorOutputObject is valid
    if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
        
        // Error out, no trustfactors set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Create Stored TrustFactor Object from TrustFactor Output Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactorOutputObject provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid Trust Factor Output Object", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SAAssertionStoreNoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log error
        NSLog(@"Create Stored TrustFactor Object from TrustFactor Output Failed: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Create a new storedTrustFactorObject object for the provided trustFactorOutputObject
    Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [[Sentegrity_Stored_TrustFactor_Object alloc] init];
    [storedTrustFactorObject setFactorID:trustFactorOutputObject.trustFactor.identification];
    [storedTrustFactorObject setRevision:trustFactorOutputObject.trustFactor.revision];
    [storedTrustFactorObject setDecayMetric:trustFactorOutputObject.trustFactor.decayMetric];
    [storedTrustFactorObject setLearned:NO]; // Beta2: don't set that it has learned
    [storedTrustFactorObject setFirstRun:[NSDate date]];
    [storedTrustFactorObject setRunCount:[NSNumber numberWithInt:0]]; // Beta2: Set the run count to 0 because we're incrementing on comparison
    
    // Return the assertion object
    return storedTrustFactorObject;
}

// Get the stored trust factor object by its factorID
- (Sentegrity_Stored_TrustFactor_Object *)getStoredTrustFactorObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error {
    
    // Check the factor id passed is valid
    if (!factorID || factorID == nil) {
        
        // Error out, no factorID set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Get Stored TrustFactorObject With FactorID Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No factorID provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid factorID", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SAAssertionStoreNoFactorIDReceived userInfo:errorDetails];
        
        // Log it
        NSLog(@"Get Stored TrustFactorObject With FactorID Failed: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Check if stored object is valid
    if (!self.storedTrustFactorObjects || self.storedTrustFactorObjects.count < 1) {
        // No assertions
        *exists = NO;
        return nil;
    }
    
    // Run through all the stored trustfactor objects and check for a matching factorID
    for (Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject in self.storedTrustFactorObjects) {
        // Look for the matching assertion with the same factorID
        if ([storedTrustFactorObject.factorID isEqualToNumber:factorID]) {
            *exists = YES;
            return storedTrustFactorObject;
        }
    }
    
    // No trustfactor found
    *exists = NO;
    return nil;
}

@end
