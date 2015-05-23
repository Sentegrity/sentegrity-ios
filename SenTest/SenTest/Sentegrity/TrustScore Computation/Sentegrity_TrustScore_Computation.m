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
#import "Sentegrity_TrustFactor_Storage.h"
#import "Sentegrity_Classification.h"
#import "Sentegrity_Subclassification.h"

// Categories
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"

@interface Sentegrity_TrustScore_Computation()


@end

@implementation Sentegrity_TrustScore_Computation

NSMutableArray *triggeredTrustFactorOutputObjects;

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
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorOutputObjectsForComputation withError:(NSError **)error {

    
    // get the policy provided trustFactors objects
    NSArray *trustFactors = policy.trustFactors;
    
    // Make sure we got a policy
    if (!policy || policy == nil || policy.policyID < 0) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No policy provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoPolicyProvided userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Validate trustFactorOutputObjects
    if (!trustFactorOutputObjectsForComputation || trustFactorOutputObjectsForComputation == nil || trustFactorOutputObjectsForComputation.count < 1) {
        // Error out, no assertion objects set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions found to compute" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
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
                
                NSMutableArray *trustFactorsInSubClass = [NSMutableArray array];
                
                // Sort all the trustfactors into their respective classifications/subclassifications
                for (Sentegrity_TrustFactor *policyTrustFactors in trustFactors) {
                    
                    // Check if the subclass belongs in the class and if the trustfactor class id and subclass id match the class and subclass
                    if ([[class identification] intValue] == [[subClass classID] intValue] && ([policyTrustFactors.classID intValue] == [[class identification] intValue] && [policyTrustFactors.subClassID intValue] == [[subClass identification] intValue])) {
                        
                        
                        // JS - TODO: Could probably get better performance by using the existing trustFactorOutputObjects array instead and referencing the trustfactor attribute to identify class/subclass instead of starting over with the policy based trustfactor list
                        
                        //Get the cooresponding trustfactor output object
          
                        Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [self getTrustFactorOutputObjectForTrustFactor:policyTrustFactors withTrustFactorOutputObjects:trustFactorOutputObjectsForComputation withError:error];

                        //need to check for trustFactorOutputObject == nil, meaning something went wrong and we have a missing trustFactorOutputObject for the policy trustFactors
                        
                        
                        // Check if the trustfactor was executed successfully
                        if (trustFactorOutputObject.statusCode == DNEStatus_ok) {
                            
                            //apply penalty
                            subClass.weightedPenalty = (subClass.weightedPenalty + policyTrustFactors.penalty.integerValue);

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
                            subClass.weightedPenalty = (subClass.weightedPenalty + (policyTrustFactors.dnePenalty.integerValue * penaltyMod));
                        }
                        
                        // Add the trustfactor to the subclassifications trustfactor array
                        [trustFactorsInSubClass addObject:policyTrustFactors];
                    }
                    
                 
                    
                }// End trustfactors loop
                
                // Set the trustfactors for the subclass
                [subClass setTrustFactors:trustFactorsInSubClass];
                
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
    

    // Return computation
    return [self analyzeResultsWithPolicy:policy withError:error];
}

#pragma mark - Private Helper Methods
// Get a classification from an array with the name provided
+ (Sentegrity_TrustScore_Computation *)analyzeResultsWithPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    // Create the computation to return
    Sentegrity_TrustScore_Computation *computationResults = [[Sentegrity_TrustScore_Computation alloc] init];
    
    // Interim variables
    
    //Generate the System score by averaging the BREACH_INDICATOR and SYSTEM_SECURITY scores
    computationResults.systemBreachScore = [[Sentegrity_TrustScore_Computation getClassificationForName:kBreachIndicator fromArray:policy.classifications withError:error] weightedPenalty];
    computationResults.systemSecurityScore = [[Sentegrity_TrustScore_Computation getClassificationForName:kSystemSecurity fromArray:policy.classifications withError:error] weightedPenalty];
    computationResults.systemScore = (int)((computationResults.systemBreachScore + computationResults.systemSecurityScore) / 2);
    
    //Generate the User score by averaging the POLICY_VIOLATION and USER_ANOMALLY scores
    computationResults.policyScore = [[Sentegrity_TrustScore_Computation getClassificationForName:kPolicyViolation fromArray:policy.classifications withError:error] weightedPenalty];
    computationResults.userAnomalyScore = [[Sentegrity_TrustScore_Computation getClassificationForName:kUserAnomally fromArray:policy.classifications withError:error] weightedPenalty];
    computationResults.userScore = (int)((computationResults.policyScore + computationResults.userAnomalyScore) / 2);
    
    //Generate the Device score by averaging the user score and the system scores
    computationResults.deviceScore = (int)((computationResults.userScore + computationResults.systemScore) / 2);
    
    //Analyze Results
    
    //Defaults
    computationResults.userTrusted = YES;
    computationResults.systemTrusted = YES;
    computationResults.deviceTrusted = YES;
    
    //Check System Threshold
    if (computationResults.systemScore < policy.systemThreshold.integerValue) {
        
        // System is not trusted
        computationResults.systemTrusted = NO;
        
    }
    
    // Check User Threshold
    if (computationResults.userScore < policy.userThreshold.integerValue) {
        
        // User is not trusted
        computationResults.userTrusted = NO;
        
    }
    
    // Check the device, system always has priority over user
    if (!computationResults.systemTrusted)
    {
        // Device is not trusted
        computationResults.deviceTrusted = NO;
        
        //see which classification inside system attributed the most
        if(computationResults.systemBreachScore < computationResults.systemSecurityScore) //breach indicator
        {
            //get the classification in question
            Sentegrity_Classification *attributingClassification = [Sentegrity_TrustScore_Computation getClassificationForName:kBreachIndicator fromArray:policy.classifications withError:error];
            
            //populate results
            computationResults.protectModeClassification = [attributingClassification.identification integerValue] ;
            computationResults.protectModeAction = [attributingClassification.protectMode integerValue];
            computationResults.protectModeInfo = attributingClassification.protectViolationName;
            computationResults.protectModeName = attributingClassification.protectInfo;
        }
        else //system anomaly
        {
            //get the classification in question
            Sentegrity_Classification *attributingClassification = [Sentegrity_TrustScore_Computation getClassificationForName:kSystemSecurity fromArray:policy.classifications withError:error];
            
            //populate results
            computationResults.protectModeClassification = [attributingClassification.identification integerValue];
            computationResults.protectModeAction = [attributingClassification.protectMode integerValue];
            computationResults.protectModeInfo = attributingClassification.protectViolationName;
            computationResults.protectModeName = attributingClassification.protectInfo;
        }
    }
    else if (!computationResults.userTrusted)
    {
        
        // Device is not trusted
        computationResults.userTrusted = NO;
        
        //see which classification inside user attributed the most
        if(computationResults.policyScore < computationResults.userAnomalyScore) //policy violation
        {
            //get the classification in question
            Sentegrity_Classification *attributingClassification = [Sentegrity_TrustScore_Computation getClassificationForName:kPolicyViolation fromArray:policy.classifications withError:error];
            
            //populate results
            computationResults.protectModeClassification = [attributingClassification.identification integerValue];
            computationResults.protectModeAction = [attributingClassification.protectMode integerValue];
            computationResults.protectModeInfo = attributingClassification.protectViolationName;
            computationResults.protectModeName = attributingClassification.protectInfo;
        }
        else //user anomaly
        {
            //get the classification in question
            Sentegrity_Classification *attributingClassification = [Sentegrity_TrustScore_Computation getClassificationForName:kUserAnomally fromArray:policy.classifications withError:error];
            
            //populate results
            computationResults.protectModeClassification = [attributingClassification.identification integerValue];
            computationResults.protectModeAction = [attributingClassification.protectMode integerValue];
            computationResults.protectModeInfo = attributingClassification.protectViolationName;
            computationResults.protectModeName = attributingClassification.protectInfo;
        }
        
    }
    
    return computationResults;
}

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
    
    
    for (Sentegrity_Classification *objects in classArray) {
        if ([objects.name isEqualToString:name]) {
            // Found it
            return objects;
        }
    }
    
    // Not found
    return nil;
}

// Find a trustFactorOutputObject that matches the policy trustfactor passed
+ (Sentegrity_TrustFactor_Output_Object *)getTrustFactorOutputObjectForTrustFactor:(Sentegrity_TrustFactor *)trustFactor withTrustFactorOutputObjects:(NSArray *)trustFactorOutputObjects withError:(NSError **)error {
    //TODO: Beta2 more error checking and fix comparison algorithm
    
    // Validate the trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects.count < 1) {
        // Failed, no trustfactor output objects found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No trustfactor output objects received" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Run through the trustFactorOutputObjects
    for (Sentegrity_TrustFactor_Output_Object *objects in trustFactorOutputObjects) {
        if ([objects.trustFactor.identification intValue] == [trustFactor.identification intValue]) {
            // Found it
            return objects;
        }
    }
    
    // Not found
    return nil;
}




@end
