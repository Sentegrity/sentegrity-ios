//
//  Sentegrity_TrustScore_Computation.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
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

@implementation Sentegrity_TrustScore_Computation

@synthesize systemScore = _systemScore, userScore = _userScore, deviceScore = _deviceScore;

/* calulate partial weight with formula:
 penaltyPercent (X) = (maxDecayMeter - X) / (maxDecayMeter - decayMeterThreshold)
 
 where:
 - penaltyPercent is function calculated in interval between 0.0 and 1.0, where 1 present 100%.
 - maxDecayMeter - decayMeter of the first (biggest) stored assertion
 - decayMeterThreshold - decayMeter defined in the policy
 - X - decayMeter of the chosen assertion
 */


/* To understand why we are adding all trustfactoroutputobjects to the transparent key
 * regardless of whether they actually matched something think about the process that takes place
 * during transparent auth:
 *
 *  1) TrustScore is high so candidate transparent key is constructed
 *  2) On the following successful login by user we get access to MASTER_KEY
 *  3) we now actually create the transparent key AND all the trustfactors that were not
 *      matching when we created the canidate key are now whitelisted
 *  4) this is where a problem can reside, our cadidate key now does not include
 *      trustfactors that we just whitelisted, this means once those trustfactor assertions
 *      match the next time, the previously created transparent key will not work
 *
 *  As a result, we add all user trustfactors, regardless of match to the candidate key
 *  this prevents that situation and also allows us opportunity to add system trustfactors
 *  adding system trustfactors adds security as it ensures that if the system changes (such as compromise)
 *  the transparent keys will no longer work. We're not currently doing this because it complicates
 *  debugging transparent auth for performance reasons. Currently its just user.
 *
 */

+ (double) weightPercentForTrustFactorOutputObject: (Sentegrity_TrustFactor_Output_Object *) trustFactorOutputObject  {
    // Partial penalities work well for TrustFactors that are likely to exhaust all possiblities, this allows us
    // to apply a relative weight based on the other stored assertions. For TrustFactors that will never exhaust
    // such as Bluetooth or WiFi this is not necessary. The risk when applied to TrustFactors that don't exhaust
    // is such that if one particular WiFi AP or Bluetooth device is used heavily the others diminish in value
    // for example, only applying 4% of their value even though this is a paired device that we automatically trust
    
    Sentegrity_Stored_Assertion *highestStoredAssertion = trustFactorOutputObject.storedTrustFactorObject.assertionObjects.firstObject;
    
    // If there is more than one matched assertion, average the decay metrics
    
    double currentAssertionDecayMetricTotal = 0;
    double currentAssertionDecayMetricAverage = 0;
    double highestStoredAssertionDecayMetric = highestStoredAssertion.decayMetric;
    double trustFactorPolicyDecayMetric = trustFactorOutputObject.trustFactor.decayMetric.doubleValue;
    
    for(Sentegrity_Stored_Assertion *matchedStoredAssertion in trustFactorOutputObject.storadeAssertionObjectsMatched) {
        currentAssertionDecayMetricTotal = currentAssertionDecayMetricTotal + matchedStoredAssertion.decayMetric;
    }
    
    currentAssertionDecayMetricAverage = currentAssertionDecayMetricTotal / trustFactorOutputObject.storadeAssertionObjectsMatched.count;
    
    //abs just in case highest stored is ever less than current
    double percent = fabs(1-((highestStoredAssertionDecayMetric - currentAssertionDecayMetricAverage) / (highestStoredAssertionDecayMetric - trustFactorPolicyDecayMetric)));
    
    return percent;
    
}


// Compute the systemScore and the UserScore from the policy
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorOutputObjects withError:(NSError **)error {
    
    // Make sure we got a policy
    if (!policy || policy == nil || policy.policyID < 0) {
        
        // Error out, no trustfactors set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No Policy Provided.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to set TrustFactors.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing a policy to set TrustFactors.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SACoreDetectionNoPolicyProvided userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No Policy Provided: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Validate trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        
        // Error out, no assertion objects set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No TrustFactorOutputObjects found to compute.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to set assertion objects.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing trustFactorOutputObjects.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No TrustFactorOutputObjects found to compute: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Validate the classifications
    if (!policy.classifications || policy.classifications.count < 1) {
        
        // Failed, no classifications found
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No Classifications Found.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to find classifications in the policy.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try checking if the policy has valid classifications.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoClassificationsFound userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No Classifications Found: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Validate the subclassifications
    if (!policy.subclassifications || policy.subclassifications.count < 1) {
        
        // Failed, no classifications found
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No Subclassifications found.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to find subclassifications in the policy.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try checking if the policy has valid subclassifications.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoSubClassificationsFound userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No Subclassifications Found: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // DEBUG
    NSMutableArray *trustFactorsNotLearnedInClass;
    NSMutableArray *trustFactorsAttributingToScoreInClass;
    NSMutableArray *trustFactorsWithErrorsInClass;
    
    // Per-Class TrustFactor sorting
    NSMutableArray *trustFactorsInClass;
    NSMutableArray *subClassesInClass;
    NSMutableArray *trustFactorsToWhitelistInClass;
    NSMutableArray *trustFactorsForTransparentAuthInClass;
    
    // Per-Subclass TrustFactor sorting
    NSMutableArray *trustFactorsInSubClass;
    
    // Overview Messages
    NSMutableArray *statusInClass;
    NSMutableArray *issuesInClass;
    NSMutableArray *suggestionsInClass;
    NSMutableArray *dynamicTwoFactorsInClass; // for user classes only
    
    // Determining errors
    NSMutableArray *subClassDNECodes;
    
    
    // For each classification in the policy
    for (Sentegrity_Classification *class in policy.classifications) {
        
        // Per-Class TrustFactor sorting
        trustFactorsInClass = [NSMutableArray array];
        subClassesInClass = [NSMutableArray array];
        trustFactorsToWhitelistInClass = [NSMutableArray array];
        
        // Transparent auth
        trustFactorsForTransparentAuthInClass = [NSMutableArray array];
        
        // DEBUG
        trustFactorsNotLearnedInClass = [NSMutableArray array];
        trustFactorsAttributingToScoreInClass = [NSMutableArray array];
        trustFactorsWithErrorsInClass = [NSMutableArray array];
        
        //GUI
        statusInClass = [NSMutableArray array];
        issuesInClass = [NSMutableArray array];
        suggestionsInClass = [NSMutableArray array];
        dynamicTwoFactorsInClass = [NSMutableArray array];
        
        // Run through all the subclassifications that are in the policy
        for (Sentegrity_Subclassification *subClass in policy.subclassifications) {
            
            // Zero out subclass score for each classification
            subClass.score = 0;
            
            // Per-Subclass TrustFactor sorting
            trustFactorsInSubClass = [NSMutableArray array];
            
            BOOL subClassContainsTrustFactor=NO;
            
            // Determines if any error existed in any TF within the subclass
            BOOL subClassAnalysisIncomplete=NO;
            
            // Determines which errors occured inside a subclass
            subClassDNECodes = [NSMutableArray array];
            
            // Run through all trustfactors
            for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorOutputObjects) {
                
                // Check if the TF class id and subclass id match (we may have no TFs in the current subclass otherwise)
                if (([trustFactorOutputObject.trustFactor.classID intValue] == [[class identification] intValue]) && ([trustFactorOutputObject.trustFactor.subClassID intValue] == [[subClass identification] intValue])) {
                    
                    //Check for hit
                    subClassContainsTrustFactor=YES;
                    
                    // Ignores TFs that have no output,not learned, etc determined during baseline analysis
                    if(trustFactorOutputObject.forComputation==YES){
                        
                        // Check if the TF was executed successfully
                        if (trustFactorOutputObject.statusCode == DNEStatus_ok) {
                            
                            // Do not count TF if its not learned yet
                            if(trustFactorOutputObject.storedTrustFactorObject.learned==NO){
                                
                                // We still want to add assertions to the store while its in learning mode
                                [trustFactorsToWhitelistInClass addObject:trustFactorOutputObject];
                                
                                //FOR DEBUG OUTPUT
                                [trustFactorsNotLearnedInClass addObject:trustFactorOutputObject];
                                
                                //go to next TF
                                continue;
                            }
                            
                            if(trustFactorOutputObject.matchFound==YES){
                                
                                // If the computation method is 1 (additive score) (e.g., only User anomaly uses this)
                                if([[class computationMethod] intValue]==1){
                                    

                                    
                                    //Add  TF to attributing list
                                    [trustFactorsAttributingToScoreInClass addObject:trustFactorOutputObject];
                                    
                                    
                                    // Determine if the TF should apply partial weight or full weight
                                    if([trustFactorOutputObject.trustFactor.partialWeight intValue]==1){
                                        
                                        // apply partial weight of TF
                                        double percent = [self weightPercentForTrustFactorOutputObject:trustFactorOutputObject];
                                        NSInteger partialWeight = (NSInteger)(percent * trustFactorOutputObject.trustFactor.weight.integerValue);
                                        subClass.score = (subClass.score + partialWeight);
                                        
                                        // Stored for debug purposes
                                        trustFactorOutputObject.appliedWeight = partialWeight;
                                        trustFactorOutputObject.percentAppliedWeight = percent;
                                        
                                        // apply issues and suggestions even though there was a match if the partial weight is very low comparatively such tht the user knows how to improve score
                                        
                                        if(partialWeight < (trustFactorOutputObject.trustFactor.weight.integerValue * 0.25)){
                                            
                                            // Add issues and suggestions for all TrustFactors since no match is always a bad thing
                                            // Check if the TF contains a custom issue message
                                            if(trustFactorOutputObject.trustFactor.lowConfidenceIssueMessage.length != 0)
                                            {
                                                // Check if we already have the issue in the our list
                                                if(![issuesInClass containsObject:trustFactorOutputObject.trustFactor.lowConfidenceIssueMessage]){
                                                    
                                                    // Add it
                                                    [issuesInClass addObject:trustFactorOutputObject.trustFactor.lowConfidenceIssueMessage];
                                                }
                                            }
                                            
                                            // Check if the TF contains a custom suggestion message
                                            if(trustFactorOutputObject.trustFactor.lowConfidenceSuggestionMessage.length != 0)
                                            {
                                                // Check if the we already have the issue in our list
                                                if(![suggestionsInClass containsObject:trustFactorOutputObject.trustFactor.lowConfidenceSuggestionMessage]){
                                                    
                                                    // Add it
                                                    [suggestionsInClass addObject:trustFactorOutputObject.trustFactor.lowConfidenceSuggestionMessage];
                                                }
                                            }
                                        }
                                        
                                        /* 
                                         * Transparent Auth Elections
                                         */
                                        
                                        if(trustFactorOutputObject.trustFactor.transparentEligible.intValue == 1){
                                            
                                            if(partialWeight >= (trustFactorOutputObject.trustFactor.weight.integerValue * 0.3)){
                                                
                                                // Avoids making transparent keys from values that may be sledom hit again
                                                // Add TF to transparent auth list
                                                [trustFactorsForTransparentAuthInClass addObject:trustFactorOutputObject];
                                                
                                                // If this is a bluetooth or wifi add it to dynamic two factor GUI list
                                                // 2 = WiFi, 8=Bluetooth
                                                if(trustFactorOutputObject.trustFactor.subClassID.integerValue == 2 || trustFactorOutputObject.trustFactor.subClassID.integerValue == 8){
                                                    
                                                    // Use the dispatch name to avoid subclass lookup
                                                    NSString *name = [trustFactorOutputObject.trustFactor.dispatch stringByAppendingString:@" authentication"];
                                                    
                                                    // Check if the we already have the dynamicTwoFactor in our list
                                                    
                                                    if (![dynamicTwoFactorsInClass containsObject:name]) {
                                                        
                                                        // Make sure the array is not nil!
                                                        if (!dynamicTwoFactorsInClass || dynamicTwoFactorsInClass.count < 1) {
                                                            
                                                            // Add it to the array and instantiate the array
                                                            dynamicTwoFactorsInClass = [NSMutableArray arrayWithObject:name];
                                                            
                                                        } else {
                                                            
                                                            // Add it to the array
                                                            [dynamicTwoFactorsInClass addObject:name];
                                                        }
                                                        
                                                    }
                                                    
                                                } // End if WiFi or Bluetooth dynamicTwoFactor

                                                   
                                                   
                                            }
                                        }
  

                                    }else{
                                        
                                        
                                        /*
                                         * Transparent Auth Elections
                                         */
                                        
                                        // This is not a partial weighted rule, always add these to transparent auth
                                        // Avoids making transparent keys that are sledom to be hit again
                                        // Add TF to transparent auth list
                                        if(trustFactorOutputObject.trustFactor.transparentEligible.intValue == 1){
                                            [trustFactorsForTransparentAuthInClass addObject:trustFactorOutputObject];
                                            
                                            // If this is a bluetooth or wifi add it to dynamic two factor GUI list
                                            // 2 = WiFi, 8=Bluetooth
                                            if(trustFactorOutputObject.trustFactor.subClassID.integerValue == 2 || trustFactorOutputObject.trustFactor.subClassID.integerValue == 8){
                                                
                                                // Use the dispatch name to avoid subclass lookup
                                                NSString *name = [trustFactorOutputObject.trustFactor.dispatch stringByAppendingString:@" authentication"];
                                                
                                                // Check if the we already have the dynamicTwoFactor in our list
                                                
                                                if (![dynamicTwoFactorsInClass containsObject:name]) {
                                                    
                                                    // Make sure the array is not nil!
                                                    if (!dynamicTwoFactorsInClass || dynamicTwoFactorsInClass.count < 1) {
                                                        
                                                        // Add it to the array and instantiate the array
                                                        dynamicTwoFactorsInClass = [NSMutableArray arrayWithObject:name];
                                                        
                                                    } else {
                                                        
                                                        // Add it to the array
                                                        [dynamicTwoFactorsInClass addObject:name];
                                                    }
                                                    
                                                }
                                                
                                            } // End if WiFi or Bluetooth dynamicTwoFactor
                                            
                                        }
                                        
                                        // apply full weight of TF
                                        subClass.score = (subClass.score + trustFactorOutputObject.trustFactor.weight.integerValue);
                                        
                                        // Stored for debug purposes
                                        trustFactorOutputObject.appliedWeight = trustFactorOutputObject.trustFactor.weight.integerValue;
                                        trustFactorOutputObject.percentAppliedWeight = 1;
                                    }
                                    
                                    
                                    
                                }else{
                                    
                                    // Computation method of 0 (subtractive score) does nothing when a match is found
                                }
                                
                                
                                
                                
                                
                            }
                            else{ // No Match found
                                
                                
                                
                                // If no match found, regardless of TF type - they are added to whitelist if "whitelistable"
                                
                                if(trustFactorOutputObject.trustFactor.whitelistable.intValue == 1) {
                                    
                                [trustFactorsToWhitelistInClass addObject:trustFactorOutputObject];
                                    
                                }
                                

                                
                                // If the computation method is 0 (subtractive scoring) (e.g., System classifications and User Policy)
                                if([[class computationMethod] intValue]==0){
                                    
                                    // Add to triggered list
                                    [trustFactorsAttributingToScoreInClass addObject:trustFactorOutputObject];
                                    
                                    // Determine if the TF should apply partial weight or full weight
                                    if([trustFactorOutputObject.trustFactor.partialWeight intValue]==1){
                                        
                                        // apply partial weight of TF
                                        double percent = [self weightPercentForTrustFactorOutputObject:trustFactorOutputObject];
                                        NSInteger partialWeight = (NSInteger)(percent * trustFactorOutputObject.trustFactor.weight.integerValue);
                                        subClass.score = (subClass.score + partialWeight);
                                        
                                        // Stored for debug purposes
                                        trustFactorOutputObject.appliedWeight = partialWeight;
                                        trustFactorOutputObject.percentAppliedWeight = percent;
                                        
                                        
                                        
                                    }else{
                                        
                                        // apply full weight of TF
                                        subClass.score = (subClass.score + trustFactorOutputObject.trustFactor.weight.integerValue);
                                        
                                        // Stored for debug purposes
                                        trustFactorOutputObject.appliedWeight = trustFactorOutputObject.trustFactor.weight.integerValue;
                                        trustFactorOutputObject.percentAppliedWeight = 1;
                                    }
                                }
                                else{
                                    // Computation method of 1 (additive scoring) does nothing when there is no match found
                                }
                                
                                // Add issues and suggestions for all TrustFactors since no match is always a bad thing
                                // Check if the TF contains a custom issue message
                                if(trustFactorOutputObject.trustFactor.notFoundIssueMessage.length != 0)
                                {
                                    // Check if we already have the issue in the our list
                                    if(![issuesInClass containsObject:trustFactorOutputObject.trustFactor.notFoundIssueMessage]){
                                        
                                        // Add it
                                        [issuesInClass addObject:trustFactorOutputObject.trustFactor.notFoundIssueMessage];
                                    }
                                }
                                
                                // Check if the TF contains a custom suggestion message
                                if(trustFactorOutputObject.trustFactor.notFoundSuggestionMessage.length != 0)
                                {
                                    // Check if the we already have the issue in our list
                                    if(![suggestionsInClass containsObject:trustFactorOutputObject.trustFactor.notFoundSuggestionMessage]){
                                        
                                        // Add it
                                        [suggestionsInClass addObject:trustFactorOutputObject.trustFactor.notFoundSuggestionMessage];
                                    }
                                }
                                
                                
                            } // End No Match found
                            
                            
                            // TrustFactor did not run successfully -> Did Not Execute
                        } else {
                            
                            // FOR DEBUG OUTPUT
                            [trustFactorsWithErrorsInClass addObject:trustFactorOutputObject];
                            
                            // Record all DNE status codes within the subclass
                            [subClassDNECodes addObject:[NSNumber numberWithInt:trustFactorOutputObject.statusCode]];
                            
                            // Mark subclass as incomplete since not all TFs ran
                            subClassAnalysisIncomplete=YES;
                            
                            // If a user TrustFactor than only add suggestions, no weight is applied (since that would boost the score)
                            if ([[class computationMethod] intValue]==1){
                                
                                [self addSuggestionsForClass:class withSubClass:subClass withSuggestions:suggestionsInClass forTrustFactorOutputObject:trustFactorOutputObject];
                                
                            }
                            // Record messages AND apply modified DNE penalty (SYSTEM classes only)
                            else if([[class computationMethod] intValue]==0)
                            {
                                
                                // Do not penalize for WiFi rules that did not run within system-based classifications
                                // This is because WiFi is considered dangerous from a system perspective and should not penalize
                                if ([[class type] intValue]!=0 && ![subClass.name isEqualToString:@"WiFi"]) {
                                    
                                    [self addSuggestionsAndCalcWeightForClass:class withSubClass:subClass withPolicy:policy withSuggestions:suggestionsInClass forTrustFactorOutputObject:trustFactorOutputObject];
                                }
                                
                                
                            }
                        }
                        
                        
                        // Add TrustFactor to classification
                        [trustFactorsInClass addObject:trustFactorOutputObject.trustFactor];
                        
                        // Add TrustFactor to subclass
                        [trustFactorsInSubClass addObject:trustFactorOutputObject.trustFactor];
                        
                    }
                    // End if ForComputation
                    
                    
                    
                }
                // End trustfactors loop
            }
            
            // Create Analysis category list for output
            // If any trustFactors existed within this subClass
            if(subClassContainsTrustFactor) {
                
                // No errors, update analysis message with subclass complete
                if(!subClassAnalysisIncomplete) {
                    [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check complete"]];
                    
                    // Subclass contains TFs with issues, identify which, if there are multiple the first (higher priority one is used)
                } else {
                    
                    if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_disabled]]){
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check disabled"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_nodata]]){
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check complete"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unauthorized]]){
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check unauthorized"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_expired]]){
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check expired"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unsupported]]){
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check unsupported"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unavailable]]){
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check unavailable"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_invalid]]){
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check invalid"]];
                        
                    }
                    else{
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check error"]];
                    }
                    
                }
                
                
                // Add the subclass total weight to the classification's base weight
                class.score = class.score +  (subClass.score * [subClass.weight integerValue]);
                
                
                //subClass.totalWeight = (subClass.baseWeight * (1-(0.1 * subClass.weight.integerValue)) );
                
                // Add trustFactors to the list of trusfactors in a subclass
                [subClass setTrustFactors:trustFactorsInSubClass];
                
                // Add the subclass to list of subclasses in class
                [subClassesInClass addObject:subClass];
            }
            
            // End subclassifications loop
        }
        
        // Link subclassification list to classification
        [class setSubClassifications:subClassesInClass];
        
        // Link trustfactors to the classification
        [class setTrustFactors:trustFactorsInClass];
        
        // Add the trustfactors for protect mode to the classification
        [class setTrustFactorsToWhitelist:trustFactorsToWhitelistInClass];
        
        // Add the trustfactor for transparent auth to the classification
        [class setTrustFactorsForTransparentAuthentication:trustFactorsForTransparentAuthInClass];
        
        // Set GUI elements
        [class setStatus: statusInClass];
        [class setIssues: issuesInClass];
        [class setSuggestions: suggestionsInClass];
        [class setDynamicTwoFactors:dynamicTwoFactorsInClass];
        
        // Set debug elements
        [class setTrustFactorsNotLearned:trustFactorsNotLearnedInClass];
        [class setTrustFactorsTriggered:trustFactorsAttributingToScoreInClass];
        [class setTrustFactorsWithErrors:trustFactorsWithErrorsInClass];
        
        
    }// End classifications loop
    
    // Perform class-level computation
    
    // Object to return
    Sentegrity_TrustScore_Computation *computationResults = [[Sentegrity_TrustScore_Computation alloc]init];
    
    //computationResults.policy = policy;
    
    // GUI Messages - System
    NSMutableSet *systemIssues = [[NSMutableSet alloc] init];
    NSMutableSet *systemSuggestions = [[NSMutableSet alloc] init];
    NSMutableSet *systemSubClassStatuses = [[NSMutableSet alloc] init];
    
    // GUI Messages - User
    NSMutableSet *userIssues = [[NSMutableSet alloc] init];
    NSMutableSet *userSuggestions = [[NSMutableSet alloc] init];
    NSMutableSet *userSubClassStatuses = [[NSMutableSet alloc] init];
    NSMutableSet *userDynamicTwoFactors = [[NSMutableSet alloc] init];
    
    // TrustFactor Sorting - System
    NSMutableArray *systemTrustFactorsAttributingToScore = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsNotLearned = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsWithErrors = [[NSMutableArray alloc] init];
    NSMutableArray *systemAllTrustFactorOutputObjects = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsToWhitelist = [[NSMutableArray alloc] init];
    
    // TrustFactor Sorting - User
    NSMutableArray *userTrustFactorsAttributingToScore = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsNotLearned = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsWithErrors = [[NSMutableArray alloc] init];
    NSMutableArray *userAllTrustFactorOutputObjects = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsToWhitelist = [[NSMutableArray alloc] init];
    
    // Transparent authentication
    NSMutableArray *allTrustFactorsForTransparentAuthentication = [[NSMutableArray alloc] init];
    
    int systemTrustScoreSum = 0;
    
    int userTrustScoreSum = 0;
    
    BOOL systemPolicyViolation=NO;
    BOOL userPolicyViolation=NO;
    
    
    // Iterate through all classifications populated in prior function
    for (Sentegrity_Classification *class in policy.classifications) {
        
        // If its a system class
        if ([[class type] intValue] == 0) {
            
            // Calculate total penalty for System classifications
            systemTrustScoreSum = systemTrustScoreSum + (int)[class score];
            
            int currentScore=0;
            // This method starts at 100 and goes down to 0
            if([[class computationMethod] intValue] == 0){
                currentScore = MIN(100,MAX(0,100-(int)[class score]));
            }
            // This method starts at 0 and goes to 100
            else if([[class computationMethod] intValue] == 1){
                currentScore = MIN(100,(int)[class score]);
            }
            
            
            // Calculate individual class penalties
            switch ([[class identification] intValue]) {
                    
                case 1:
                    computationResults.systemBreachClass = class;
                    computationResults.systemBreachScore = currentScore;
                    break;
                    
                case 2:
                    computationResults.systemPolicyClass = class;
                    computationResults.systemPolicyScore = currentScore;
                    
                    // Don't add policy scores to overall as it just inflates it
                    if(currentScore < 100){
                        systemPolicyViolation=YES;
                    }
                    break;
                    
                case 3:
                    computationResults.systemSecurityClass = class;
                    computationResults.systemSecurityScore = currentScore;
                    break;
                default:
                    break;
            }
            
            // Tally system GUI elements
            [systemIssues addObjectsFromArray:[class issues]];
            [systemSuggestions addObjectsFromArray:[class suggestions]];
            [systemSubClassStatuses addObjectsFromArray:[class status]];
            
            // Tally system debug data
            [systemTrustFactorsAttributingToScore addObjectsFromArray:[class trustFactorsTriggered]];
            [systemTrustFactorsNotLearned addObjectsFromArray:[class trustFactorsNotLearned]];
            [systemTrustFactorsWithErrors addObjectsFromArray:[class trustFactorsWithErrors]];
            [systemAllTrustFactorOutputObjects addObjectsFromArray:[class trustFactors]];
            
            // Add whitelists together
            [systemTrustFactorsToWhitelist addObjectsFromArray:[class trustFactorsToWhitelist]];
            
            // Add all transparent authentication trustfactors together
            [allTrustFactorsForTransparentAuthentication addObjectsFromArray:[class trustFactorsForTransparentAuthentication]];
            
            // When it's a user class
        } else {
            
            // Calculate total weight for User classifications
            userTrustScoreSum = userTrustScoreSum + (int)[class score];
            
            int currentScore=0;
            // This method starts at 100 and goes down to 0
            if([[class computationMethod] intValue] == 0){
                currentScore = MIN(100,MAX(0,100-(int)[class score]));
            }
            // This method starts at 0 and goes to 100
            else if([[class computationMethod] intValue] == 1){
                currentScore = MIN(100,(int)[class score]);
            }
            
            switch ([[class identification] intValue]) {
                    
                case 4:
                    
                    computationResults.userPolicyClass = class;
                    computationResults.userPolicyScore = currentScore;
                    
                    // Don't add policy scores to overall as it just inflates it
                    if(currentScore < 100){
                        userPolicyViolation=YES;
                    }
                    break;
                    
                    
                case 5:
                    computationResults.userAnomalyClass = class;
                    computationResults.userAnomalyScore = currentScore;
                    break;
                default:
                    break;
            }
            
            // Tally user GUI elements
            [userIssues addObjectsFromArray:[class issues]];
            [userSuggestions addObjectsFromArray:[class suggestions]];
            [userSubClassStatuses addObjectsFromArray:[class status]];
            [userDynamicTwoFactors addObjectsFromArray:[class dynamicTwoFactors]];
            
            // Tally user debug data
            [userTrustFactorsAttributingToScore addObjectsFromArray:[class trustFactorsTriggered]];
            [userTrustFactorsNotLearned addObjectsFromArray:[class trustFactorsNotLearned]];
            [userTrustFactorsWithErrors addObjectsFromArray:[class trustFactorsWithErrors]];
            [userAllTrustFactorOutputObjects addObjectsFromArray:[class trustFactors]];
            
            // Add whitelists together
            [userTrustFactorsToWhitelist addObjectsFromArray:[class trustFactorsToWhitelist]];
            
            // Add all transparent authentication trustfactors together
            [allTrustFactorsForTransparentAuthentication addObjectsFromArray:[class trustFactorsForTransparentAuthentication]];
        }
    }
    
    // Set GUI messages (system)
    computationResults.systemIssues = [systemIssues allObjects];
    computationResults.systemSuggestions = [systemSuggestions allObjects];
    computationResults.systemAnalysisResults = [systemSubClassStatuses allObjects];
    
    // Set GUI messages (user)
    computationResults.userIssues = [userIssues allObjects];
    computationResults.userSuggestions = [userSuggestions allObjects];
    computationResults.userAnalysisResults = [userSubClassStatuses allObjects];
    computationResults.userDynamicTwoFactors = [userDynamicTwoFactors allObjects];
    
    // Set transparent authentication list
    computationResults.transparentAuthenticationTrustFactorOutputObjects = allTrustFactorsForTransparentAuthentication;
    
    // Set whitelists for system/user domains
    computationResults.userTrustFactorWhitelist = userTrustFactorsToWhitelist;
    computationResults.systemTrustFactorWhitelist = systemTrustFactorsToWhitelist;
    
    // DEBUG: Set trustfactor objects for system/user domains
    computationResults.userAllTrustFactorOutputObjects = userAllTrustFactorOutputObjects;
    computationResults.systemAllTrustFactorOutputObjects = systemAllTrustFactorOutputObjects;
    
    // DEBUG: Set triggered for system/user domains
    computationResults.userTrustFactorsAttributingToScore = userTrustFactorsAttributingToScore;
    computationResults.systemTrustFactorsAttributingToScore = systemTrustFactorsAttributingToScore;
    
    // DEBUG: Set not learned for system/user domains
    computationResults.userTrustFactorsNotLearned = userTrustFactorsNotLearned;
    computationResults.systemTrustFactorsNotLearned = systemTrustFactorsNotLearned;
    
    // DEBUG: Set errored for system/user domains
    computationResults.userTrustFactorsWithErrors = userTrustFactorsWithErrors;
    computationResults.systemTrustFactorsWithErrors = systemTrustFactorsWithErrors;
    
    
    // Set comprehensive scores
    // Gaurantee that a policy violataion will be zero (type 4 rules could technically overpower)
    if(systemPolicyViolation == YES) {
        
        computationResults.systemScore = 0;
        
    } else {
        
        computationResults.systemScore = MIN(100,MAX(0,100 - systemTrustScoreSum));
    }
    
    if (userPolicyViolation == YES) {
        
        computationResults.userScore = 0;
        
    } else {
        
        computationResults.userScore = MIN(100,userTrustScoreSum);
    }
    
    computationResults.deviceScore = (computationResults.systemScore + computationResults.userScore)/2;
    
    
    return computationResults;
}

#pragma mark - Private Helper Methods


+ (void)addSuggestionsForClass:(Sentegrity_Classification *)class withSubClass:(Sentegrity_Subclassification *)subClass withSuggestions:(NSMutableArray *)suggestionsInClass forTrustFactorOutputObject:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject{
    
    // This is really only for inverse rules, thus we only cover a couple DNE errors
    
    switch (trustFactorOutputObject.statusCode) {
        case DNEStatus_unauthorized:
            // Unauthorized
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnauthorized.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneUnauthorized]){
                    [suggestionsInClass addObject:subClass.dneUnauthorized];
                }
            }
        case DNEStatus_disabled:
            // Disabled
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneDisabled.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneDisabled]){
                    [suggestionsInClass addObject:subClass.dneDisabled];
                }
            }
            break;
        case DNEStatus_expired:
            // Expired
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneExpired.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneExpired]){
                    [suggestionsInClass addObject:subClass.dneExpired];
                }
            }
            break;
        case DNEStatus_nodata:
            // Expired
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneNoData.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneNoData]){
                    [suggestionsInClass addObject:subClass.dneNoData];
                }
            }
            break;
        case DNEStatus_invalid:
            // Invalid
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneInvalid.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneInvalid]){
                    [suggestionsInClass addObject:subClass.dneInvalid];
                }
            }
            break;
        default:
            break;
    }
    
}

// Calculates penalty and adds suggestions
+ (void)addSuggestionsAndCalcWeightForClass:(Sentegrity_Classification *)class withSubClass:(Sentegrity_Subclassification *)subClass withPolicy:(Sentegrity_Policy *)policy withSuggestions:(NSMutableArray *)suggestionsInClass forTrustFactorOutputObject:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject{
    
    // Create an int to hold the dnePenalty multiplied by the modifier
    double penaltyMod = 0;
    
    switch (trustFactorOutputObject.statusCode) {
        case DNEStatus_error:
            // Error
            penaltyMod = [policy.DNEModifiers.error doubleValue];
            
            break;
            
        case DNEStatus_unauthorized:
            
            // Unauthorized
            penaltyMod = [policy.DNEModifiers.unauthorized doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnauthorized.length!= 0) {
                //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneUnauthorized]){
                    [suggestionsInClass addObject:subClass.dneUnauthorized];
                }
            }
            
            break;
            
        case DNEStatus_unsupported:
            
            // Unsupported
            penaltyMod = [policy.DNEModifiers.unsupported doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnsupported.length!= 0) {
                
                //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneUnsupported]){
                    [suggestionsInClass addObject:subClass.dneUnsupported];
                }
            }
            break;
            
        case DNEStatus_unavailable:
            
            // Unavailable
            penaltyMod = [policy.DNEModifiers.unavailable doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnavailable.length!= 0) {
                
                // Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneUnavailable]){
                    [suggestionsInClass addObject:subClass.dneUnavailable];
                }
            }
            break;
            
        case DNEStatus_disabled:
            
            // Unavailable
            penaltyMod = [policy.DNEModifiers.disabled doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneDisabled.length!= 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneDisabled]){
                    [suggestionsInClass addObject:subClass.dneDisabled];
                }
            }
            break;
            
        case DNEStatus_nodata:
            
            // Unavailable
            penaltyMod = [policy.DNEModifiers.noData doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneNoData.length!= 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneNoData]){
                    [suggestionsInClass addObject:subClass.dneNoData];
                }
            }
            
            break;
            
        case DNEStatus_expired:
            
            // Expired
            penaltyMod = [policy.DNEModifiers.expired doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneExpired.length!= 0) {
                
                //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneExpired]){
                    [suggestionsInClass addObject:subClass.dneExpired];
                }
            }
            
            break;
        case DNEStatus_invalid:
            
            // Expired
            penaltyMod = [policy.DNEModifiers.invalid doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneInvalid.length!= 0) {
                
                //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneInvalid]){
                    [suggestionsInClass addObject:subClass.dneInvalid];
                }
            }
            
            break;
        default:
            
            // Apply error by default
            penaltyMod = [policy.DNEModifiers.error doubleValue];
            break;
    }
    
    NSInteger weight = (trustFactorOutputObject.trustFactor.weight.integerValue * penaltyMod);
    
    // Apply DNE percent to the TFs normal penalty to reduce it (penaltyMode of 0 negates the rule completely)
    subClass.score = subClass.score + weight;
    
    // For debug;
    trustFactorOutputObject.appliedWeight = weight;
    trustFactorOutputObject.percentAppliedWeight = 1;
    
}

@end
