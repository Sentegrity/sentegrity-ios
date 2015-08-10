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



@synthesize systemScore = _systemScore, userScore = _userScore, deviceScore = _deviceScore;

//FOR DEBUG OUTPUT
static NSMutableArray *trustFactorsNotLearned;
static NSMutableArray *trustFactorsTriggered;
static NSMutableArray *trustFactorsWithErrors;
static NSArray *allTrustFactorsOutputObjects;

// Compute the systemScore and the UserScore from the policy
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorOutputObjects withError:(NSError **)error {
    
    
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
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        // Error out, no assertion objects set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No TrustFactorOutputObjects found to compute" forKey:NSLocalizedDescriptionKey];
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
    if (!policy.subclassifications || policy.subclassifications.count < 1) {
        // Failed, no classifications found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No subclassifications found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoSubClassificationsFound userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    //FOR DEBUG OUTPUT
    trustFactorsNotLearned = [NSMutableArray array];
    trustFactorsTriggered = [NSMutableArray array];
    trustFactorsWithErrors = [NSMutableArray array];
    allTrustFactorsOutputObjects = trustFactorOutputObjects;
    
    //For each classification in the policy
    for (Sentegrity_Classification *class in policy.classifications) {
        
        // Links
        NSMutableArray *trustFactorsInClass = [NSMutableArray array];
        
        NSMutableArray *subClassesInClass = [NSMutableArray array];
        
        NSMutableArray *trustFactorsToWhitelistInClass = [NSMutableArray array];
        
        
        //GUI: Analysis results are displayed on a subclass basis to categorize issues across multiple rules  (no location, no network, etc)
        NSMutableArray *subClassStatus = [NSMutableArray array];
        
        //GUI: Issues displayed on a per trustfactor basis
        NSMutableArray *issuesInClass = [NSMutableArray array];
        
        //GUI: Suggestions displayed on a per subclass basis OR trustfactor (if the trustfactor contains specific suggestion text)
        NSMutableArray *suggestionsInClass = [NSMutableArray array];
        
        // Run through all the subclassifications that are in the policy
        for (Sentegrity_Subclassification *subClass in policy.subclassifications) {
            
            NSMutableArray *trustFactorsInSubClass = [NSMutableArray array];
            
            BOOL subClassContainsTrustFactors=NO;
            
            // Determines if any error existed in any TF within the subclass
            BOOL subClassAnalysisIncomplete=NO;
            
            // Determines which errors occured
            NSMutableArray *subClassDNECodes = [NSMutableArray array];
            
            // Run through all trustfactors
            for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorOutputObjects) {
                
                if(trustFactorOutputObject.trustFactor.identification == [NSNumber numberWithInt:1026]){
                    
                    
                }
                
                // Check if the TF class id and subclass id match (we may have no TFs in the current subclass otherwise)
                if (([trustFactorOutputObject.trustFactor.classID intValue] == [[class identification] intValue]) && ([trustFactorOutputObject.trustFactor.subClassID intValue] == [[subClass identification] intValue])) {
                    
                    //Check for hit
                    subClassContainsTrustFactors=YES;
                    
                    // Check if the TF was executed successfully
                    if (trustFactorOutputObject.statusCode == DNEStatus_ok) {
                        
                        // Add TF to whitelist array if baseline analysis determined this is whitelistable
                        if(trustFactorOutputObject.whitelist==YES){
                            [trustFactorsToWhitelistInClass addObject:trustFactorOutputObject];
                        }
                        
                        // Do not count TF if its not learned yet
                        if(trustFactorOutputObject.storedTrustFactorObject.learned==NO){
                            
                            //FOR DEBUG OUTPUT
                            [trustFactorsNotLearned addObject:trustFactorOutputObject];
                            
                            //go to next TF
                            continue;
                        }
                        
                        // IF RULE TRIGGERED
                        if(trustFactorOutputObject.triggered==YES){
                            
                            //FOR DEBUG OUTPUT
                            [trustFactorsTriggered addObject:trustFactorOutputObject];
                            
                            // Apply TF's penalty to subclass base penalty score
                            subClass.basePenalty = (subClass.basePenalty + trustFactorOutputObject.trustFactor.penalty.integerValue);
                            
                            // IF the TF operates as a normal rule (triger on no match), update issues and suggestion messages  (triggering a normal rule is bad)
                            if(trustFactorOutputObject.trustFactor.inverse.intValue==0){
                                
                                // Check if the TF contains a custom issue message
                                if(trustFactorOutputObject.trustFactor.issueMessage.length != 0)
                                {
                                    // Check if we already have the issue in the our list
                                    if(![issuesInClass containsObject:trustFactorOutputObject.trustFactor.issueMessage]){
                                        
                                        // Add it
                                        [issuesInClass addObject:trustFactorOutputObject.trustFactor.issueMessage];
                                    }
                                }
                                
                                // Check if the TF contains a custom suggestion message
                                if(trustFactorOutputObject.trustFactor.suggestionMessage.length != 0)
                                {
                                    // Check if the we already have the issue in our list
                                    if(![suggestionsInClass containsObject:trustFactorOutputObject.trustFactor.suggestionMessage]){
                                        
                                        // Add it
                                        [suggestionsInClass addObject:trustFactorOutputObject.trustFactor.suggestionMessage];
                                    }
                                }
                                
                            }
                            
                        }
                        else{ // RULE DID NOT TRIGGER
                            
                            // Check if TF is inverse (not triggering inverse rule does not boost score)
                            if(trustFactorOutputObject.trustFactor.inverse.intValue==1){
                                
                                // Check if the inverse TF contains a custom issue message (this is rare, don't think any inverse rules have one)
                                if(trustFactorOutputObject.trustFactor.issueMessage.length != 0)
                                {
                                    // Check if we already have the issue in our list
                                    if(![issuesInClass containsObject:trustFactorOutputObject.trustFactor.issueMessage]){
                                        
                                        // Add it
                                        [issuesInClass addObject:trustFactorOutputObject.trustFactor.issueMessage];
                                    }
                                }
                                
                                // Check if the inverse TF contains a suggestion message (this is common as it gives the user ways to boost score)
                                if(trustFactorOutputObject.trustFactor.suggestionMessage.length != 0)
                                {
                                    // Check if we already have the suggestion in our list
                                    if(![suggestionsInClass containsObject:trustFactorOutputObject.trustFactor.suggestionMessage]){
                                        
                                        // Add it
                                        [suggestionsInClass addObject:trustFactorOutputObject.trustFactor.suggestionMessage];
                                    }
                                }
                            }
                            
                        }
                        
                        
                    }else { // TF did not run successfully (DNE)
                        
                        
                        // FOR DEBUG OUTPUT
                        [trustFactorsWithErrors addObject:trustFactorOutputObject];
                        
                        // Record all DNE status codes within the subclass
                        [subClassDNECodes addObject:[NSNumber numberWithInt:trustFactorOutputObject.statusCode]];
                        
                        subClassAnalysisIncomplete=YES;
                        
                        // If TF is inverse then only add suggestions (e.g., we don't penalize for a faulty rule that boosts your score)
                        if (trustFactorOutputObject.trustFactor.inverse.intValue ==1){
                            
                            [self addSuggestionsForClass:class withSubClass:subClass withSuggestions:suggestionsInClass forTrustFactorOutputObject:trustFactorOutputObject];
                            
                        }
                        else //not an inverse rule therefore record messages AND apply modified DNE penalty
                        {
                            
                            [self addSuggestionsForClassAndCalcPenalty:class withPolicy:policy withSubClass:subClass withSuggestions:suggestionsInClass forTrustFactorOutputObject:trustFactorOutputObject];
                        }
                        
                    }
                    
                    //add TF to classification
                    [trustFactorsInClass addObject:trustFactorOutputObject.trustFactor];
                    //add TF to subclass
                    [trustFactorsInSubClass addObject:trustFactorOutputObject.trustFactor];
                    
                }
                
            }// End trustfactors loop
            
            // Create Analysis category list for output
            if(subClassContainsTrustFactors){ // If any trustFactors existed within this subClass
                
                // No errors, update analysis message with subclass complete
                if(!subClassAnalysisIncomplete) {
                    [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis complete"]];
                }
                else{ // Subclass contains TFs with issues, identify which, if there are multiple the first (higher priority one is used)
                    
                    if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_disabled]]){
                        
                        [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis disabled"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_nodata]]){
                        
                        [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis complete"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unauthorized]]){
                        
                        [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis unauthorized"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_expired]]){
                        
                        [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis expired"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unsupported]]){
                        
                        [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis unsupported"]];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unavailable]]){
                        
                        [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis unavailable"]];
                        
                    }
                    else{
                        
                        [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis error"]];
                    }
                    
                }
                
                
                // Set the penalty weight for the subclass
                subClass.weightedPenalty = (subClass.basePenalty * (1-(0.1 * subClass.weight.integerValue)) );
                
                // Add the subclass weightedPenalty to the classification basePenalty
                class.basePenalty = (class.basePenalty + subClass.weightedPenalty);
                
                // Add trustFactors to the list of trusfactors in a subclass
                [subClass setTrustFactors:trustFactorsInSubClass];
                
                // Add the subclass to list of subclasses in class
                [subClassesInClass addObject:subClass];
            }
            
            
        }// End subclassifications loop
        
        //Link subclassification list to classification
        [class setSubClassifications:subClassesInClass];
        
        //Link trustfactors to the classification
        [class setTrustFactors:trustFactorsInClass];
        
        //Add the trustfactors for protect mode to the classification
        [class setTrustFactorsToWhitelist:trustFactorsToWhitelistInClass];
        
        // Set the penalty weight for the classification
        class.weightedPenalty = (class.basePenalty * (1-(0.1 * class.weight.integerValue)) );
        
        // Set GUI elements
        [class setSubClassStatus: subClassStatus];
        [class setIssuesInClass: issuesInClass];
        [class setSuggestionsInClass:suggestionsInClass];
        
    }// End classifications loop
    
    
    // Return computation (trustFactorsNotLearned/trustFactorsTriggered/allTrustFactorOutputObjects added for debug purposes)
    return [self analyzeResultsWithPolicy:policy withError:error];
}

#pragma mark - Private Helper Methods
// Get a classification from an array with the name provided
+ (Sentegrity_TrustScore_Computation *)analyzeResultsWithPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    // Create the computation to return
    Sentegrity_TrustScore_Computation *computationResults = [[Sentegrity_TrustScore_Computation alloc] init];
    
    //FOR DEBUG OUTPUT (can eventualy revert method call as well)
    computationResults.trustFactorsNotLearned = trustFactorsNotLearned;
    computationResults.trustFactorsWithErrors = trustFactorsWithErrors;
    computationResults.trustFactorsTriggered = trustFactorsTriggered;
    computationResults.allTrustFactorOutputObjects = allTrustFactorsOutputObjects;
    
    Sentegrity_Classification *systemBreachClass = [Sentegrity_TrustScore_Computation getClassificationForName:KSystemBreach fromArray:policy.classifications withError:error];
    Sentegrity_Classification *systemSecurityClass = [Sentegrity_TrustScore_Computation getClassificationForName:kSystemSecurity fromArray:policy.classifications withError:error];
    Sentegrity_Classification *systemPolicyClass = [Sentegrity_TrustScore_Computation getClassificationForName:kSystemPolicy fromArray:policy.classifications withError:error];
    Sentegrity_Classification *userPolicyClass = [Sentegrity_TrustScore_Computation getClassificationForName:kUserPolicy fromArray:policy.classifications withError:error];
    Sentegrity_Classification *userAnomalyClass = [Sentegrity_TrustScore_Computation getClassificationForName:kUserAnomally fromArray:policy.classifications withError:error];
    
    // Get classification scores
    int systemBreachScore =  (int)[systemBreachClass weightedPenalty];
    int systemSecurityScore = (int) [systemSecurityClass weightedPenalty];
    int systemPolicyScore = (int) [systemPolicyClass weightedPenalty];
    int userPolicyScore =  (int)[userPolicyClass weightedPenalty];
    int userAnomalyScore = (int) [userAnomalyClass weightedPenalty];
    
    // Min/Max to adjust from 0-100
    computationResults.systemBreachScore = MIN(100,MAX(0,100-systemBreachScore));
    computationResults.systemSecurityScore = MIN(100,MAX(0,100-systemSecurityScore));
    computationResults.systemPolicyScore = MIN(100,MAX(0,100-systemPolicyScore));
    computationResults.userPolicyScore = MIN(100,MAX(0,100-userPolicyScore));
    computationResults.userAnomalyScore = MIN(100,MAX(0,100-userAnomalyScore));
    
    // Get composite scores
    computationResults.systemScore =  (computationResults.systemSecurityScore + computationResults.systemBreachScore + computationResults.systemPolicyScore) / 3;
    computationResults.userScore = (computationResults.userPolicyScore + computationResults.userAnomalyScore) / 2;
    computationResults.deviceScore = (computationResults.userScore + computationResults.systemScore) / 2;
    
    //Analyze Results
    
    //Defaults
    computationResults.deviceTrusted = YES;
    computationResults.userTrusted = YES;
    computationResults.systemTrusted = YES;
    
    //Check system threshold
    if (computationResults.systemScore < policy.systemThreshold.integerValue) {
        
        // System is not trusted
        computationResults.systemTrusted = NO;
        computationResults.deviceTrusted = NO;
    }
    
    // Check User Threshold
    if (computationResults.userScore < policy.userThreshold.integerValue) {
        
        // User is not trusted
        computationResults.userTrusted = NO;
        computationResults.deviceTrusted = NO;
    }
    
    
    // Analyze system first as it has priority
    
    if(!computationResults.systemTrusted){
        
        
        // Add all classification whitelists together for System
        computationResults.protectModeWhitelist = [[NSMutableArray alloc] init];
        computationResults.protectModeWhitelist = [[[computationResults.protectModeWhitelist arrayByAddingObjectsFromArray:systemBreachClass.trustFactorsToWhitelist] arrayByAddingObjectsFromArray:systemPolicyClass.trustFactorsToWhitelist] arrayByAddingObjectsFromArray:systemSecurityClass.trustFactorsToWhitelist];
        
        // Add user anomaly assertions whitelist (not policy)
        //computationResults.protectModeWhitelist = [computationResults.protectModeWhitelist arrayByAddingObjectsFromArray:userAnomalyClass.trustFactorsToWhitelist];
        
        //Combine issue messages
        NSMutableArray *combinedIssues = [[NSMutableArray alloc] init];
        [combinedIssues addObjectsFromArray:systemBreachClass.issuesInClass];
        [combinedIssues addObjectsFromArray:systemPolicyClass.issuesInClass];
        [combinedIssues addObjectsFromArray:systemSecurityClass.issuesInClass];
        computationResults.systemGUIIssues = [[NSSet setWithArray:combinedIssues] allObjects];
        
        //Combine suggesstion messages
        NSMutableArray *combinedSuggestions = [[NSMutableArray alloc] init];
        [combinedSuggestions addObjectsFromArray:systemBreachClass.suggestionsInClass];
        [combinedSuggestions addObjectsFromArray:systemPolicyClass.suggestionsInClass];
        [combinedSuggestions addObjectsFromArray:systemSecurityClass.suggestionsInClass];
        computationResults.systemGUISuggestions = [[NSSet setWithArray:combinedSuggestions] allObjects];
        
        //Combine analysis messages
        NSMutableArray *combinedAnalysis = [[NSMutableArray alloc] init];
        [combinedAnalysis addObjectsFromArray:systemBreachClass.subClassStatus];
        [combinedAnalysis addObjectsFromArray:systemPolicyClass.subClassStatus];
        [combinedAnalysis addObjectsFromArray:systemSecurityClass.subClassStatus];
        computationResults.systemGUIAnalysis = [[NSSet setWithArray:combinedAnalysis] allObjects];
        
        
        if(computationResults.systemBreachScore <= computationResults.systemSecurityScore) // SYSTEM_BREACH is attributing
        {
            computationResults.protectModeClassID = [systemBreachClass.identification integerValue] ;
            computationResults.protectModeAction = [systemBreachClass.protectModeAction integerValue];
            computationResults.protectModeMessage = systemBreachClass.protectModeMessage;
            
            // Set dashboard and detailed system view info
            computationResults.systemGUIIconID = [systemBreachClass.identification intValue];
            computationResults.systemGUIIconText = systemBreachClass.desc;
            
            
        }
        else if(computationResults.systemPolicyScore <= computationResults.systemSecurityScore) // SYSTEM_POLICY is attributing
        {
            
            computationResults.protectModeClassID = [systemPolicyClass.identification integerValue] ;
            computationResults.protectModeAction = [systemPolicyClass.protectModeAction integerValue];
            computationResults.protectModeMessage = systemPolicyClass.protectModeMessage;
            
            // Set dashboard and detailed system view info
            computationResults.systemGUIIconID = [systemPolicyClass.identification intValue];
            computationResults.systemGUIIconText = systemPolicyClass.desc;
            
            
        }
        else //SYSTEM_SECURITY is attributing
        {
            computationResults.protectModeClassID = [systemSecurityClass.identification integerValue] ;
            computationResults.protectModeAction = [systemSecurityClass.protectModeAction integerValue];
            computationResults.protectModeMessage = systemSecurityClass.protectModeMessage;
            
            // Set dashboard and detailed system view info
            computationResults.systemGUIIconID = [systemSecurityClass.identification intValue];
            computationResults.systemGUIIconText = systemSecurityClass.desc;
            
        }
        
        
        
    }
    else{
        
        // Set dashboard and detailed system view info
        computationResults.systemGUIIconID = 0;
        computationResults.systemGUIIconText = @"Device Trusted";
        
        //Combine issue messages
        NSMutableArray *combinedIssues = [[NSMutableArray alloc] init];
        [combinedIssues addObjectsFromArray:systemBreachClass.issuesInClass];
        [combinedIssues addObjectsFromArray:systemPolicyClass.issuesInClass];
        [combinedIssues addObjectsFromArray:systemSecurityClass.issuesInClass];
        
        // remove dups and set
        computationResults.systemGUIIssues = [[NSSet setWithArray:combinedIssues] allObjects];
        
        //Combine suggesstion messages
        NSMutableArray *combinedSuggestions = [[NSMutableArray alloc] init];
        [combinedSuggestions addObjectsFromArray:systemBreachClass.suggestionsInClass];
        [combinedSuggestions addObjectsFromArray:systemPolicyClass.suggestionsInClass];
        [combinedSuggestions addObjectsFromArray:systemSecurityClass.suggestionsInClass];
        
        // remove dups and set
        computationResults.systemGUISuggestions = [[NSSet setWithArray:combinedSuggestions] allObjects];
        
        //Combine analysis messages
        NSMutableArray *combinedAnalysis = [[NSMutableArray alloc] init];
        [combinedAnalysis addObjectsFromArray:systemBreachClass.subClassStatus];
        [combinedAnalysis addObjectsFromArray:systemPolicyClass.subClassStatus];
        [combinedAnalysis addObjectsFromArray:systemSecurityClass.subClassStatus];
        
        // remove dups and set
        computationResults.systemGUIAnalysis = [[NSSet setWithArray:combinedAnalysis] allObjects];
        
    }
    
    if(!computationResults.userTrusted){
        
        
        //Combine analysis messages
        NSMutableArray *combinedAnalysis = [[NSMutableArray alloc] init];
        [combinedAnalysis addObjectsFromArray:userAnomalyClass.subClassStatus];
        [combinedAnalysis addObjectsFromArray:userPolicyClass.subClassStatus];
        computationResults.userGUIAnalysis =  [[NSSet setWithArray:combinedAnalysis] allObjects];
        
        //Combine issue messages
        NSMutableArray *combinedIssues = [[NSMutableArray alloc] init];
        [combinedIssues addObjectsFromArray:userAnomalyClass.issuesInClass];
        [combinedIssues addObjectsFromArray:userPolicyClass.issuesInClass];
        computationResults.userGUIIssues = [[NSSet setWithArray:combinedIssues] allObjects];
        
        //Combine suggesstion messages
        NSMutableArray *combinedSuggestions = [[NSMutableArray alloc] init];
        [combinedSuggestions addObjectsFromArray:userAnomalyClass.suggestionsInClass];
        [combinedSuggestions addObjectsFromArray:userPolicyClass.suggestionsInClass];
        computationResults.userGUISuggestions = [[NSSet setWithArray:combinedSuggestions] allObjects];
        
        
        //see which classification inside user attributed the most and set protect mode
        if(computationResults.userPolicyScore <= computationResults.userAnomalyScore) //USER_POLICY is attributing
        {
            
            if(computationResults.systemTrusted){
                
                computationResults.protectModeClassID = [userPolicyClass.identification integerValue];
                computationResults.protectModeAction = [userPolicyClass.protectModeAction integerValue];
                computationResults.protectModeMessage = userPolicyClass.protectModeMessage;
                
                computationResults.protectModeWhitelist = [[NSMutableArray alloc] init];
                
                // Add user anomaly to policy violation
                computationResults.protectModeWhitelist = [[computationResults.protectModeWhitelist arrayByAddingObjectsFromArray:userPolicyClass.trustFactorsToWhitelist] arrayByAddingObjectsFromArray:userAnomalyClass.trustFactorsToWhitelist] ;
                
            }
            
            // Set dashboard and detailed user view info
            computationResults.userGUIIconID = [userPolicyClass.identification intValue];
            computationResults.userGUIIconText = userPolicyClass.desc;
            
            
        }
        else //USER_ANOMALY is attributing
        {
            
            // Set protect mode action to the class specified action ONLY if system did not already
            if(computationResults.systemTrusted){
                computationResults.protectModeClassID = [userAnomalyClass.identification integerValue];
                computationResults.protectModeAction = [userAnomalyClass.protectModeAction integerValue];
                computationResults.protectModeMessage = userAnomalyClass.protectModeMessage;
                
                computationResults.protectModeWhitelist = [[NSMutableArray alloc] init];
                computationResults.protectModeWhitelist = [computationResults.protectModeWhitelist arrayByAddingObjectsFromArray:userAnomalyClass.trustFactorsToWhitelist];
            }
            
            // Set dashboard and detailed user view info
            computationResults.userGUIIconID = [userAnomalyClass.identification intValue];
            computationResults.userGUIIconText = userAnomalyClass.desc;
            
        }
        
    }
    else{
        
        // Set dashboard and detailed system view info
        computationResults.userGUIIconID = 0;
        computationResults.userGUIIconText = @"User Trusted";
        
        //Set messaging for detailed user view
        
        //Combine issue messages
        NSMutableArray *combinedIssues = [[NSMutableArray alloc] init];
        [combinedIssues addObjectsFromArray:userAnomalyClass.issuesInClass];
        [combinedIssues addObjectsFromArray:userPolicyClass.issuesInClass];
        computationResults.userGUIIssues = [[NSSet setWithArray:combinedIssues] allObjects];
        
        //Combine analysis messages
        NSMutableArray *combinedAnalysis = [[NSMutableArray alloc] init];
        [combinedAnalysis addObjectsFromArray:userAnomalyClass.subClassStatus];
        [combinedAnalysis addObjectsFromArray:userPolicyClass.subClassStatus];
        computationResults.userGUIAnalysis =  [[NSSet setWithArray:combinedAnalysis] allObjects];
        
        //Combine suggesstion messages
        NSMutableArray *combinedSuggestions = [[NSMutableArray alloc] init];
        [combinedSuggestions addObjectsFromArray:userAnomalyClass.suggestionsInClass];
        [combinedSuggestions addObjectsFromArray:userPolicyClass.suggestionsInClass];
        computationResults.userGUISuggestions = [[NSSet setWithArray:combinedSuggestions] allObjects];
        
    }
    
    
    
    //Combine user whitelist-able trustfactors with at-fault system trustfactors if the system protect mode action is admin/policy, since this is more powerful than a user pin
    //if(computationResults.protectModeAction == 3 && !computationResults.systemTrusted){
    //  NSArray *existing = computationResults.protectModeWhitelist;
    //  computationResults.protectModeWhitelist = [[existing arrayByAddingObjectsFromArray:userPolicyClass.trustFactorsToWhitelist] arrayByAddingObjectsFromArray:userAnomalyClass.trustFactorsToWhitelist];
    //}
    
    
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


+(void)addSuggestionsForClass:(Sentegrity_Classification *)class withSubClass:(Sentegrity_Subclassification *)subClass withSuggestions:(NSMutableArray *)suggestionsInClass forTrustFactorOutputObject:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject{
    
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
        default:
            break;
    }
    
}

+(void)addSuggestionsForClassAndCalcPenalty:(Sentegrity_Classification *)class withPolicy:(Sentegrity_Policy *)policy withSubClass:(Sentegrity_Subclassification *)subClass withSuggestions:(NSMutableArray *)suggestionsInClass forTrustFactorOutputObject:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject{
    
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
            if(subClass.dneUnauthorized.length!= 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneUnauthorized]){
                    [suggestionsInClass addObject:subClass.dneUnauthorized];
                }
            }
            
            break;
        case DNEStatus_unsupported:
            // Unsupported
            penaltyMod = [policy.DNEModifiers.unsupported doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnsupported.length!= 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneUnsupported]){
                    [suggestionsInClass addObject:subClass.dneUnsupported];
                }
            }
            break;
        case DNEStatus_unavailable:
            // Unavailable
            penaltyMod = [policy.DNEModifiers.unavailable doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnavailable.length!= 0)
            {   //Does suggestion already exist?
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

            if(subClass.dneExpired.length!= 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneExpired]){
                    [suggestionsInClass addObject:subClass.dneExpired];
                }
            }
            
            break;
        default:
            // apply error by default
            penaltyMod = [policy.DNEModifiers.error doubleValue];
            break;
    }
    
    
    // Apply DNE percent to the TFs normal penalty to reduce it (penaltyMode of 0 negates the rule completely)
    subClass.basePenalty = subClass.basePenalty + (trustFactorOutputObject.trustFactor.penalty.integerValue * penaltyMod);
    
}




@end
