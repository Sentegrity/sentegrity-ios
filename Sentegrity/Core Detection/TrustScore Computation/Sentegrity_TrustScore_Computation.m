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
    
    //Not learned (debug)
    NSMutableArray *trustFactorsNotLearned = [NSMutableArray array];
    
    NSMutableArray *trustFactorsTriggered = [NSMutableArray array];

    //For each classification in the policy
    for (Sentegrity_Classification *class in policy.classifications) {
        
        // Links
        NSMutableArray *trustFactorsInClass = [NSMutableArray array];
        
        NSMutableArray *subClassesInClass = [NSMutableArray array];
        
        NSMutableArray *trustFactorsToWhitelistInClass = [NSMutableArray array];
        
        
        //GUI: Analysis results displayed on a per subclass basis
        NSMutableArray *subClassStatus = [NSMutableArray array];
        
        //GUI: Issues displayed
        NSMutableArray *issuesInClass = [NSMutableArray array];
        
        //GUI: Suggestions displayed
        NSMutableArray *suggestionsInClass = [NSMutableArray array];
        
        // Run through all the subclassifications that are in the policy
        for (Sentegrity_Subclassification *subClass in policy.subclassifications) {
            
            NSMutableArray *trustFactorsInSubClass = [NSMutableArray array];
            
            BOOL subClassContainsTrustFactors=NO;
            BOOL subClassContainsErrors=NO;
            
            // Run through all trustfactors
            for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorOutputObjects) {
                
                if(trustFactorOutputObject.trustFactor.identification == [NSNumber numberWithInt:1026]){
                    
                    
                }

                // Check if the trustfactor class id and subclass id match (we may have no TFs in the current subclass otherwise)
                if (([trustFactorOutputObject.trustFactor.classID intValue] == [[class identification] intValue]) && ([trustFactorOutputObject.trustFactor.subClassID intValue] == [[subClass identification] intValue])) {
                    
                    //Check for hit
                    subClassContainsTrustFactors=YES;
                    
                    // Check if the trustfactor was executed successfully
                    if (trustFactorOutputObject.statusCode == DNEStatus_ok) {
                        
                        //add to whitelist array if baseline analysis determined this is whitelistable
                        if(trustFactorOutputObject.whitelist==YES){
                            [trustFactorsToWhitelistInClass addObject:trustFactorOutputObject];
                        }
                        
                        if(trustFactorOutputObject.storedTrustFactorObject.learned==NO){
                            
                            //DEBUG
                            [trustFactorsNotLearned addObject:trustFactorOutputObject.trustFactor.name];
                            
                            //go to next TF
                            continue;
                        }
                        
                        if(trustFactorOutputObject.triggered==YES){
                            
                            //DEBUG
                            [trustFactorsTriggered addObject:trustFactorOutputObject.trustFactor.name];
                            
                            //apply penalty to subclass base
                            subClass.basePenalty = (subClass.basePenalty + trustFactorOutputObject.trustFactor.penalty.integerValue);
                            
                            // IF normal rule: Update issues and suggestion messages  (triggering a normal rule is bad)
                            if(trustFactorOutputObject.trustFactor.inverse.intValue==0){
                                
                                //Is a issue set for this TF?
                                if(trustFactorOutputObject.trustFactor.issueMessage.length != 0)
                                {   //Does issue already exist in our list?
                                    if(![issuesInClass containsObject:trustFactorOutputObject.trustFactor.issueMessage]){
                                        [issuesInClass addObject:trustFactorOutputObject.trustFactor.issueMessage];
                                    }
                                }
                                
                                //Is a suggestion set for this TF?
                                if(trustFactorOutputObject.trustFactor.suggestionMessage.length != 0)
                                {   //Does suggestion already exist in our list?
                                    if(![suggestionsInClass containsObject:trustFactorOutputObject.trustFactor.suggestionMessage]){
                                        [suggestionsInClass addObject:trustFactorOutputObject.trustFactor.suggestionMessage];
                                    }
                                }
                                
                            }
                            
                        }
                        else{
                            // IF inverse rule: Update issues message (not triggering inverse rule is bad)
                            if(trustFactorOutputObject.trustFactor.inverse.intValue==1){
                                
                                //Is a issue set for this TF?
                                if(trustFactorOutputObject.trustFactor.issueMessage.length != 0)
                                {   //Does issue already exist in our list?
                                    if(![issuesInClass containsObject:trustFactorOutputObject.trustFactor.issueMessage]){
                                        [issuesInClass addObject:trustFactorOutputObject.trustFactor.issueMessage];
                                    }
                                }
                                
                                //Is suggestion set for this TF?
                                if(trustFactorOutputObject.trustFactor.suggestionMessage.length != 0)
                                {   //Does suggestion already exist in our list?
                                    if(![suggestionsInClass containsObject:trustFactorOutputObject.trustFactor.suggestionMessage]){
                                        [suggestionsInClass addObject:trustFactorOutputObject.trustFactor.suggestionMessage];
                                    }
                                }
                            }
                            
                        }


                    }else {
                        // TrustFactor did not run successfully (DNE)
                        //  Update issues/suggesstions as possible and penalty for non-inverse rules
                        
                        // We only report when there are errors not user issues (disabled/unauthorized)
                        if(trustFactorOutputObject.statusCode == DNEStatus_error)
                            subClassContainsErrors=YES;
                        
                        // if its an inverse rule there is no DNE penalty applied, don't do the penalty calculation but add suggestions (e.g., we don't penalize for a faulty rule that boosts your score)
                        if (trustFactorOutputObject.trustFactor.inverse.intValue ==1){
                
                            [self addSuggestionsForClass:class withSubClass:subClass withSuggestions:suggestionsInClass forTrustFactorOutputObject:trustFactorOutputObject];

                        }
                        else //not an inverse rule therefore record messages and penalty
                        {
                
                            [self addSuggestionsForClassAndCalcPenalty:class withPolicy:policy withSubClass:subClass withSuggestions:suggestionsInClass forTrustFactorOutputObject:trustFactorOutputObject];
                        }
                
                    }
                
                    //add TF to classification
                    [trustFactorsInClass addObject:trustFactorOutputObject.trustFactor];
                    //add TF to subclass
                    [trustFactorsInSubClass addObject:trustFactorOutputObject.trustFactor];
                    
                } // End IF class/subclass match
                
            }// End trustfactors loop
            
            //If any trustFactors existed within this subClass
            if(subClassContainsTrustFactors){
                
                //update analysis message with subclass complete or failed
                if(!subClassContainsErrors) {
                    [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@ %@", @"Completed", subClass.name, @"analysis."]];
                }
                else{
                    [subClassStatus addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"analysis incomplete (error)."]];
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
    

    // Return computation (trustFactorsNotLearned/Triggered added for debug purposes)
    return [self analyzeResultsWithPolicy:policy trustFactorsNotLearned:trustFactorsNotLearned trustFactorsTriggered:trustFactorsTriggered withError:error];
}

#pragma mark - Private Helper Methods
// Get a classification from an array with the name provided
+ (Sentegrity_TrustScore_Computation *)analyzeResultsWithPolicy:(Sentegrity_Policy *)policy trustFactorsNotLearned:(NSMutableArray *)trustFactorsNotLearned trustFactorsTriggered:(NSMutableArray *)trustFactorsTriggered withError:(NSError **)error {
    
    // Create the computation to return
    Sentegrity_TrustScore_Computation *computationResults = [[Sentegrity_TrustScore_Computation alloc] init];
    
    // DEBUG
    computationResults.trustFactorsNotLearned = trustFactorsNotLearned;
    computationResults.trustFactorsTriggered = trustFactorsTriggered;
    
    
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
    
    // Identify attributing system classifications
    if (!computationResults.systemTrusted)
        
    {
        //see which classification inside system attributed the most and set protect mode
        
        if(computationResults.systemBreachScore <= computationResults.systemSecurityScore) // SYSTEM_BREACH is attributing
        {
            // Set protect mode action to the class specified action
            computationResults.protectModeClassID = [systemBreachClass.identification integerValue] ;
            computationResults.protectModeAction = [systemBreachClass.protectModeAction integerValue];
            computationResults.protectModeMessage = systemBreachClass.protectModeMessage;
            computationResults.protectModeWhitelist = systemBreachClass.trustFactorsToWhitelist;
            
            // Set dashboard and detailed system view info
            computationResults.systemGUIIconID = [systemBreachClass.identification intValue];
            computationResults.systemGUIIconText = systemBreachClass.desc;
            
            //Set messaging for detailed system view
            computationResults.systemGUIIssues = systemBreachClass.issuesInClass;
            computationResults.systemGUISuggestions = systemBreachClass.suggestionsInClass;
            computationResults.systemGUIAnalysis = systemBreachClass.subClassStatus;
            
        }
        else if(computationResults.systemPolicyScore <= computationResults.systemSecurityScore) // SYSTEM_POLICY is attributing
        {
            // Set protect mode action to the class specified action
            computationResults.protectModeClassID = [systemPolicyClass.identification intValue] ;
            computationResults.protectModeAction = [systemPolicyClass.protectModeAction integerValue];
            computationResults.protectModeMessage = systemPolicyClass.protectModeMessage;
            computationResults.protectModeWhitelist = systemPolicyClass.trustFactorsToWhitelist;
            
            // Set dashboard and detailed system view info
            computationResults.systemGUIIconID = [systemPolicyClass.identification intValue];
            computationResults.systemGUIIconText = systemPolicyClass.desc;
            
            //Set messaging for detailed system view
            computationResults.systemGUIIssues = systemPolicyClass.issuesInClass;
            computationResults.systemGUISuggestions = systemPolicyClass.suggestionsInClass;
            computationResults.systemGUIAnalysis = systemPolicyClass.subClassStatus;
        }
        else //SYSTEM_SECURITY is attributing
        {

            // Set protect mode action to the class specified action
            computationResults.protectModeClassID = [systemSecurityClass.identification integerValue];
            computationResults.protectModeAction = [systemSecurityClass.protectModeAction integerValue];
            computationResults.protectModeMessage = systemSecurityClass.protectModeMessage;
            computationResults.protectModeWhitelist = systemSecurityClass.trustFactorsToWhitelist;
            
            // Set dashboard and detailed system view info
            computationResults.systemGUIIconID = [systemSecurityClass.identification intValue];
            computationResults.systemGUIIconText = systemSecurityClass.desc;
            
            //Set messaging for detailed system view
            computationResults.systemGUIIssues = systemSecurityClass.issuesInClass;
            computationResults.systemGUISuggestions = systemSecurityClass.suggestionsInClass;
            computationResults.systemGUIAnalysis = systemSecurityClass.subClassStatus;
        }
        

    }
    else //it is trusted, combine messages from all classifications
    {
        // Set protect mode to 0
        computationResults.protectModeClassID = 0;
        computationResults.protectModeAction = 0;
        
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
    
    // check if user is untrusted
    if (!computationResults.userTrusted)
    {
        
        //see which classification inside user attributed the most and set protect mode
        
        if(computationResults.userPolicyScore <= computationResults.userAnomalyScore) //USER_POLICY is attributing
        {

            // Set protect mode action to the class specified action
            computationResults.protectModeClassID = [userPolicyClass.identification integerValue];
            computationResults.protectModeAction = [userPolicyClass.protectModeAction integerValue];
            computationResults.protectModeMessage = userPolicyClass.protectModeMessage;
            computationResults.protectModeWhitelist = userPolicyClass.trustFactorsToWhitelist;
            
            // Set dashboard and detailed user view info
            computationResults.userGUIIconID = [userPolicyClass.identification intValue];
            computationResults.userGUIIconText = userPolicyClass.desc;
            
            //Set messaging for detailed user view
            computationResults.userGUIIssues = userPolicyClass.issuesInClass;
            computationResults.userGUISuggestions = userPolicyClass.suggestionsInClass;
            computationResults.userGUIAnalysis = userPolicyClass.subClassStatus;
        }
        else //USER_ANOMALY is attributing
        {
            // Set protect mode action to the class specified action
            computationResults.protectModeClassID = [userAnomalyClass.identification integerValue];
            computationResults.protectModeAction = [userAnomalyClass.protectModeAction integerValue];
            computationResults.protectModeMessage = userAnomalyClass.protectModeMessage;
            computationResults.protectModeWhitelist = userAnomalyClass.trustFactorsToWhitelist;
            
            // Set dashboard and detailed user view info
            computationResults.userGUIIconID = [userAnomalyClass.identification intValue];
            computationResults.userGUIIconText = userAnomalyClass.desc;
            
            //Set messaging for detailed user view
            computationResults.userGUIIssues = userAnomalyClass.issuesInClass;
            computationResults.userGUISuggestions = userAnomalyClass.suggestionsInClass;
            computationResults.userGUIAnalysis = userAnomalyClass.subClassStatus;
        }
        

    }
    else //it is trusted, combine messages from all user classifications
    {

        // Set protect mode (commented otherwise it overrides system values)
        //computationResults.protectModeClassID = 0;
        //computationResults.protectModeAction = 0;
        
        // Set dashboard and detailed system view info
        computationResults.userGUIIconID = 0;
        computationResults.userGUIIconText = @"User Trusted";
        
        //Combine issue messages
        NSMutableArray *combinedIssues = [[NSMutableArray alloc] init];
        [combinedIssues addObjectsFromArray:userAnomalyClass.issuesInClass];
        [combinedIssues addObjectsFromArray:userPolicyClass.issuesInClass];
        
        //remove dups and set
        computationResults.userGUIIssues = [[NSSet setWithArray:combinedIssues] allObjects];
        
        //Combine suggesstion messages
        NSMutableArray *combinedSuggestions = [[NSMutableArray alloc] init];
        [combinedSuggestions addObjectsFromArray:userAnomalyClass.suggestionsInClass];
        [combinedSuggestions addObjectsFromArray:userPolicyClass.suggestionsInClass];
        
        //remove dups and set
        computationResults.userGUISuggestions = [[NSSet setWithArray:combinedSuggestions] allObjects];
        
        //Combine analysis messages
        NSMutableArray *combinedAnalysis = [[NSMutableArray alloc] init];
        [combinedAnalysis addObjectsFromArray:userAnomalyClass.subClassStatus];
        [combinedAnalysis addObjectsFromArray:userPolicyClass.subClassStatus];
    
        
        //set
        computationResults.userGUIAnalysis =  [[NSSet setWithArray:combinedAnalysis] allObjects];
        
    }
    
    //Combine user whitelist-able trustfactors with at-fault system trustfactors if the system protect mode action is admin/policy, since this is more powerful than a user pin
    if(computationResults.protectModeAction == 3 && !computationResults.systemTrusted){
        NSArray *existing = computationResults.protectModeWhitelist;
        computationResults.protectModeWhitelist = [[existing arrayByAddingObjectsFromArray:userPolicyClass.trustFactorsToWhitelist] arrayByAddingObjectsFromArray:userAnomalyClass.trustFactorsToWhitelist];
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


+(void)addSuggestionsForClass:(Sentegrity_Classification *)class withSubClass:(Sentegrity_Subclassification *)subClass withSuggestions:(NSMutableArray *)suggestionsInClass forTrustFactorOutputObject:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject{
    
    switch (trustFactorOutputObject.statusCode) {
        case DNEStatus_unauthorized:
            // Unauthorized
            
            //Is suggestion set?
            if(subClass.dneUnauthorized.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInClass containsObject:subClass.dneUnauthorized]){
                    [suggestionsInClass addObject:subClass.dneUnauthorized];
                }
            }
        case DNEStatus_disabled:
            // Disabled
            
            //Is suggestion set?
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
    
    // Static suggestion strings
    NSString *errorMsg;
    NSString *expiredMsg;
    
    switch (trustFactorOutputObject.statusCode) {
        case DNEStatus_error:
            // Error
            penaltyMod = [policy.DNEModifiers.error doubleValue];
            // Only show suggestions for fixable TFs
            // Is suggestion set for rule in policy?
            errorMsg = [subClass.name stringByAppendingString:@" dataset error"];
            
            if(![suggestionsInClass containsObject:errorMsg]){
                [suggestionsInClass addObject:errorMsg];
            }
            break;
        case DNEStatus_unauthorized:
            // Unauthorized
            penaltyMod = [policy.DNEModifiers.unauthorized doubleValue];
            
            // Only show suggestions for fixable TFs
            // Is suggestion set for rule in policy?
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

            // Only show suggestions for fixable TFs
            // Is suggestion set for rule in policy?
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
            
            // Only show suggestions for fixable TFs
            // Is suggestion set for rule in policy?
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

            // Only show suggestions for fixable TFs
            // Is suggestion set for rule in policy?
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
            
            // Only show suggestions for fixable TFs
            // Is suggestion set for rule in policy?
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
            
            // Only show suggestions for fixable TFs
            // Is suggestion set for rule in policy?
             expiredMsg = [subClass.name stringByAppendingString:@" dataset timer expired"];
        
            if(![suggestionsInClass containsObject:expiredMsg]){
                [suggestionsInClass addObject:expiredMsg];
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
