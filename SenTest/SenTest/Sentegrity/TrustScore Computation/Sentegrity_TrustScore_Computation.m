//
//  Sentegrity_TrustScore_Computation.m
//  SenTest
//
//  Created by Kramer on 4/8/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustScore_Computation.h"
#import "Sentegrity_Constants.h"
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_Assertion_Storage.h"
#import "Sentegrity_Classification.h"
#import "Sentegrity_Subclassification.h"

// Categories
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"

@interface Sentegrity_TrustScore_Computation()

// Private Helper Methods

// Find an assertion object from the assertion object array that matches the trustfactor passed
+ (Sentegrity_Assertion_Stored_Assertion_Object *)getAssertionObjectForTrustFactor:(Sentegrity_TrustFactor *)trustFactor withAssertionObjects:(NSArray *)assertionObjects withError:(NSError **)error;

// Find an assertion from the assertion array that matches the trustfactor passed
+ (Sentegrity_TrustFactor_Output *)getAssertionForTrustFactor:(Sentegrity_TrustFactor *)trustFactor withAssertions:(NSArray *)assertions withError:(NSError **)error;

// Check if the output between the assertion and assertion object are the same (if not, return NO)
+ (BOOL)checkAssertionOutputValues:(NSArray *)assertionOutput withAssertionObjectOutputValues:(NSArray *)assertionObjectOutput withError:(NSError **)error;

@end

@implementation Sentegrity_TrustScore_Computation

@synthesize systemScore = _systemScore, userScore = _userScore, deviceScore = _deviceScore;

/* Steps:
 1.  Go through all the trustfactors
 2.  Sort into unique classifications
 3.  Sort into unique subclassifications
 4.  Go through each trustfactor of the same subclass
 5.  Summarize all penalties for trustfactors in the same subclass
 6.  Apply subclass object's weight to the penalties
 7.  Store the subclass weighted penalty
 8.  Summarize all subclass weighted totals
 9.  Apply the classification's weight to the summarized weighted totals per classification
 10. Generate the classification's trustscore
 11. Do this for all classifications/subclassifications
 12. Generate the System score by averaging the BREACH_INDICATOR and SYSTEM_SECURITY scores
 13. Generate the User score by averaging the POLICY_VIOLATION and USER_ANOMALLY scores
 14. Generate the Device score by averaging the user score and the system scores
 */

// Compute the systemScore and the UserScore from the policy
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutput:(NSArray *)trustFactorOutput andStoredAssertionObjects:(NSArray *)storedAssertionObjects withError:(NSError **)error {
    
    // Set the trustFactors
    NSArray *trustFactors = policy.trustFactors;
    
    // Create the triggered policies array
    NSMutableArray *triggeredPolicies = [NSMutableArray array];
    
    // Make sure we received a policy
    if (!trustFactors || trustFactors == nil || trustFactors.count < 1) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No TrustFactors provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorsSetToAnalyze userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Validate trustfactor output
    if (!trustFactorOutput || trustFactorOutput == nil || trustFactorOutput.count < 1) {
        // Error out, no assertion objects set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions found to compute" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Validate trustfactors in the policy
    if (!storedAssertionObjects || storedAssertionObjects == nil || storedAssertionObjects.count < 1) {
        // Error out, no assertion objects set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion objects found to compute" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidAssertionsProvided userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Validate the classifications
    if (!policy.classifications || policy.classifications.count < 1) {
        // Failed, no classifications found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No classifications found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoClassificationsFound userInfo:errorDetails];
        NSLog(@"You suck, no classifications found");
        // Don't return anything
        return nil;
    }
    
    // Validate the subclassifications
    if (!policy.subclassification || policy.subclassification.count < 1) {
        // Failed, no classifications found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No subclassifications found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoSubClassificationsFound userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // 1.  Go through all the trustfactors
    // 2.  Sort into unique classifications
    // 3.  Sort into unique subclassifications
    // 4.  Go through each trustfactor of the same subclass
    // 5.  Summarize all penalties for trustfactors in the same subclass
    // 6.  Apply subclass object's weight to the penalties
    // 7.  Store the subclass weighted penalty
    // 8.  Summarize all subclass weighted totals
    // 9.  Apply the classification's weight to the summarized weighted totals per classification
    // 10. Generate the classification's trustscore
    // 11. Do this for all classifications/subclassifications

    // Go through all the classifications in the policy
    for (Sentegrity_Classification *class in policy.classifications) {
        
        NSMutableArray *subClassesInClass = [NSMutableArray array];
        
        // Run through all the subclassifications that are in the policy
        for (Sentegrity_Subclassification *subClass in policy.subclassification) {
            
            // Match up all the subclassifications that belong to the classification
            if ([subClass.classID intValue] == [class.identification intValue]) {
                
                NSMutableArray *trustsInSubClass = [NSMutableArray array];
                
                // Sort all the trustfactors into their respective classifications/subclassifications
                for (Sentegrity_TrustFactor *trustClassifications in trustFactors) {
                    
                    // Check if the subclass belongs in the class and if the trustfactor class id and subclass id match the class and subclass
                    if ([[class identification] intValue] == [[subClass classID] intValue] && ([trustClassifications.classID intValue] == [[class identification] intValue] && [trustClassifications.subClassID intValue] == [[subClass identification] intValue])) {
                        
                        // Check if the trustfactor has passed, failed, or DNE, based on the assertion store information
                        
                        // Get the assertion
                        Sentegrity_TrustFactor_Output *trustFactorOutputObject = [Sentegrity_TrustScore_Computation getAssertionForTrustFactor:trustClassifications withAssertions:trustFactorOutput withError:error];
                        
                        // Get the assertion object
                        Sentegrity_Assertion_Stored_Assertion_Object *storedAssertionObject = [Sentegrity_TrustScore_Computation getAssertionObjectForTrustFactor:trustClassifications withAssertionObjects:storedAssertionObjects withError:error];
                        
                        // Check if the trustfactor was executed successfully
                        if (trustFactorOutputObject.statusCode == DNEStatus_ok) {
                            // TrustFactor ran successfully
                            
                            // Compare the output - Beta2: Updated to ensure only learned objects can penalize
                            if (![Sentegrity_TrustScore_Computation checkAssertionOutputValues:trustFactorOutputObject.output withAssertionObjectOutputValues:storedAssertionObject.stored.hashValue withError:error] && storedAssertionObject.learned) {
                                
                                // Failed
                                subClass.weightedPenalty = (subClass.weightedPenalty + trustClassifications.penalty.integerValue);
                                
                                // Beta2: Keep track of trustFactorObjects that trip for whitelisting
                                [triggeredPolicies addObject:trustFactorOutputObject];
                                
                            } else {
                                // Passed
                                //TODO: Is there any positive subtraction for passing a check?
                                //JS-Beta2 - Yes there is, mainly for user anomaly rules such as when a known bluetooth device is found. We will need to add a attribute to TrustFactors to indicate these types of rules and evaluate it here
                            }
                        } else {
                            // TrustFactor did not run successfully (DNE)
                            
                            // Create an int to hold the dnePenalty multiplied by the modifier
                            int penaltyMod = 0;
                            
                            // Find out which DNE exit code was set
                            switch (trustFactorOutputObject.statusCode) {
                                case DNEStatus_error:
                                    // Error
                                    penaltyMod = [policy.DNEModifiers.error doubleValue];
                                    break;
                                case DNEStatus_unauthorized:
                                    // Unauthorized
                                    penaltyMod = [policy.DNEModifiers.unauthorized doubleValue];
                                    break;
                                case DNEStatus_unsupported:
                                    // Unsupported
                                    penaltyMod = [policy.DNEModifiers.unsupported doubleValue];
                                    break;
                                case DNEStatus_disabled:
                                    // Disabled
                                    penaltyMod = [policy.DNEModifiers.disabled doubleValue];
                                    break;
                                case DNEStatus_expired:
                                    // Error
                                    penaltyMod = [policy.DNEModifiers.expired doubleValue];
                                    break;
                                default:
                                    // Error
                                    penaltyMod = [policy.DNEModifiers.error doubleValue];
                                    break;
                            }
                            
                            // DNE weighted penalty based on modifiers
                            subClass.weightedPenalty = (subClass.weightedPenalty + (trustClassifications.dnePenalty.integerValue * penaltyMod));
                        }
                        
                        // Add the trustfactor to the subclassifications trustfactor array
                        [trustsInSubClass addObject:trustClassifications];
                    }
                    
                }// End trustfactors loop
                
                // Set the trustfactors for the subclass
                [subClass setTrustFactors:trustsInSubClass];
                
                // Set the penalty weight for the subclass
                subClass.weightedPenalty = (subClass.weightedPenalty * subClass.weight.integerValue);
                // Set the penalty for the classification
                class.weightedPenalty = (class.weightedPenalty + subClass.weightedPenalty);
                
                // Add the subclass to the classifications subclass array
                [subClassesInClass addObject:subClass];
            }
            
        }// End subclassifications loop
        
        // Add the subclassifications for the classification name
        [class setSubClassifications:subClassesInClass];
        
        // Trust Factors that belong to the class being iterated through will be placed here
        NSMutableArray *trustFactorsInClass = [NSMutableArray array];
        
        // Add all the trustfactors that belong in the class
        for (Sentegrity_TrustFactor *trustFactor in trustFactors) {
            if ([trustFactor.classID intValue] == [class.identification intValue]) {
                // Add to the trustfactorsinclass array
                [trustFactorsInClass addObject:trustFactor];
            }
        }// End trustfactor loop
        
        // Add the trustfactors to the classification name appended by trustfactors
        [class setTrustFactors:trustFactorsInClass];
        
        // Set the penalty weight for the classification
        class.weightedPenalty = (class.weightedPenalty * class.weight.integerValue);
        
    }// End classifications loop
    
    // Create the computation to return
    Sentegrity_TrustScore_Computation *computation = [[Sentegrity_TrustScore_Computation alloc] init];
    
    // Interim variables
    int systemScoreValue, userScoreValue, deviceScoreValue;
    
    // 12. Generate the System score by averaging the BREACH_INDICATOR and SYSTEM_SECURITY scores
    NSInteger breachValue = [[Sentegrity_TrustScore_Computation getClassificationForName:kBreachIndicator fromArray:policy.classifications withError:error] weightedPenalty];
    NSInteger systemValue = [[Sentegrity_TrustScore_Computation getClassificationForName:kSystemSecurity fromArray:policy.classifications withError:error] weightedPenalty];
    systemScoreValue = (int)((breachValue + systemValue) / 2);
    
    // 13. Generate the User score by averaging the POLICY_VIOLATION and USER_ANOMALLY scores
    double policyValue = [[Sentegrity_TrustScore_Computation getClassificationForName:kPolicyViolation fromArray:policy.classifications withError:error] weightedPenalty];
    double userValue = [[Sentegrity_TrustScore_Computation getClassificationForName:kUserAnomally fromArray:policy.classifications withError:error] weightedPenalty];
    userScoreValue = (int)((policyValue + userValue) / 2);
    
    // 14. Generate the Device score by averaging the user score and the system scores
    deviceScoreValue = (int)((userScoreValue + systemScoreValue) / 2);
    
    // Set the values and return the computed score
    [computation setSystemScore:systemScoreValue];
    [computation setUserScore:userScoreValue];
    [computation setDeviceScore:deviceScoreValue];
    NSLog(@"System Score: %d UserScore: %d DeviceScore: %d", systemScoreValue, userScoreValue, deviceScoreValue);
    // Set the classification information
    computation.classificationInformation = policy.classifications;
    // Set the triggered policies
    computation.triggered = triggeredPolicies;
    
    // Return computation
    return computation;
}

#pragma mark - Private Helper Methods

// Get a classification from an array with the name provided
+ (Sentegrity_Classification *)getClassificationForName:(NSString *)name fromArray:(NSArray *)classArray withError:(NSError **)error {
    //TODO: Beta2 more error checking and fix comparison algorithm
    
    // Validate the classArray
    if (!classArray || classArray.count < 1) {
        // Failed, no classarray found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No classifications found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoClassificationsFound userInfo:errorDetails];
        NSLog(@"You suck again, no classifications found");
        // Don't return anything
        return nil;
    }
    
    // Run through the assertion objects
    for (Sentegrity_Classification *objects in classArray) {
        if ([objects.name isEqualToString:name]) {
            // Found it
            return objects;
        }
    }
    
    // Not found
    return nil;
}

// Find an assertion from the assertion array that matches the trustfactor passed
+ (Sentegrity_TrustFactor_Output *)getAssertionForTrustFactor:(Sentegrity_TrustFactor *)trustFactor withAssertions:(NSArray *)assertions withError:(NSError **)error {
    //TODO: Beta2 more error checking and fix comparison algorithm
    
    // Validate the assertions
    if (!assertions || assertions.count < 1) {
        // Failed, no classifications found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions received" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Run through the assertion objects
    for (Sentegrity_TrustFactor_Output *objects in assertions) {
        if ([objects.trustFactor.identification intValue] == [trustFactor.identification intValue]) {
            // Found it
            return objects;
        }
    }
    
    // Not found
    return nil;
}

// Find an assertion object from the assertion object array that matches the trustfactor passed
+ (Sentegrity_Assertion_Stored_Assertion_Object *)getAssertionObjectForTrustFactor:(Sentegrity_TrustFactor *)trustFactor withAssertionObjects:(NSArray *)assertionObjects withError:(NSError **)error {
    //TODO: Beta2 more error checking
    
    // Validate the assertion objects
    if (!assertionObjects || assertionObjects.count < 1) {
        // Failed, no classifications found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion objects received" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Run through the assertion objects
    for (Sentegrity_Assertion_Stored_Assertion_Object *objects in assertionObjects) {
        if ([objects.factorID intValue] == [trustFactor.identification intValue]) {
            // Found it
            return objects;
        }
    }
    
    // Not found
    return nil;
}

// Check if the output between the assertion and assertion object are the same (if not, return NO)
+ (BOOL)checkAssertionOutputValues:(NSArray *)assertionOutput withAssertionObjectOutputValues:(NSArray *)assertionObjectOutput withError:(NSError **)error {
    //TODO: Beta2 more error checking and verify if more than one output is different does it get penalized differently
    
    // Validate the classifications
    if (!assertionOutput || assertionOutput.count < 1) {
        // Failed, no classifications found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion output received" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Do they contain the same items
    BOOL same = YES;
    
    // Run through all the outputs
    for (id output in assertionOutput) {
        if (![assertionObjectOutput containsObject:output]) {
            // We have found an output that is not in the other array.
            same = NO;
            break;
        }
    }
    return same;
}

@end
