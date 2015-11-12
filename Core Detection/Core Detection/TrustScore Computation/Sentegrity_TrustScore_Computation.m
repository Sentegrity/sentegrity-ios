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

// Compute the systemScore and the UserScore from the policy
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorOutputObjects withError:(NSError **)error {
    
    // Make sure we got a policy
    if (!policy || policy == nil || policy.policyID < 0) {
        
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No policy provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SACoreDetectionNoPolicyProvided userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Validate trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        
        // Error out, no assertion objects set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No TrustFactorOutputObjects found to compute" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAAssertionStoreNoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
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
    
    // DEBUG
    NSMutableArray *trustFactorsNotLearnedInClass;
    NSMutableArray *trustFactorsTriggeredInClass;
    NSMutableArray *trustFactorsWithErrorsInClass;
    
    // Per-Class TrustFactor sorting
    NSMutableArray *trustFactorsInClass;
    NSMutableArray *subClassesInClass;
    NSMutableArray *trustFactorsToWhitelistInClass;
    
    // Per-Subclass TrustFactor sorting
    NSMutableArray *trustFactorsInSubClass;
    
    // Overview Messages
    NSMutableArray *statusInClass;
    NSMutableArray *issuesInClass;
    NSMutableArray *suggestionsInClass;
    NSMutableArray *authenticatorsInClass; // for user classes only
    
    // Determining errors
    NSMutableArray *subClassDNECodes;
    
    
    // For each classification in the policy
    for (Sentegrity_Classification *class in policy.classifications) {
        
        // Reset mutable temp vars fro each class
        
        // Per-Class TrustFactor sorting
        trustFactorsInClass = [NSMutableArray array];
        subClassesInClass = [NSMutableArray array];
        trustFactorsToWhitelistInClass = [NSMutableArray array];
        
        // DEBUG
        trustFactorsNotLearnedInClass = [NSMutableArray array];
        trustFactorsTriggeredInClass = [NSMutableArray array];
        trustFactorsWithErrorsInClass = [NSMutableArray array];
        
        //GUI
        statusInClass = [NSMutableArray array];
        issuesInClass = [NSMutableArray array];
        suggestionsInClass = [NSMutableArray array];
        authenticatorsInClass = [NSMutableArray array];
        
        // Run through all the subclassifications that are in the policy
        for (Sentegrity_Subclassification *subClass in policy.subclassifications) {
            
            // Per-Subclass TrustFactor sorting
            trustFactorsInSubClass = [NSMutableArray array];
            
            BOOL subClassContainsTrustFactors=NO;
            
            // Determines if any error existed in any TF within the subclass
            BOOL subClassAnalysisIncomplete=NO;
            
            // Determines which errors occured inside a subclass
            subClassDNECodes = [NSMutableArray array];
            
            // Run through all trustfactors
            for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorOutputObjects) {
                
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
                            [trustFactorsNotLearnedInClass addObject:trustFactorOutputObject];
                            
                            //go to next TF
                            continue;
                        }
                        
                        // IF RULE TRIGGERED
                        if(trustFactorOutputObject.triggered==YES){
                            
                            //FOR DEBUG OUTPUT
                            [trustFactorsTriggeredInClass addObject:trustFactorOutputObject];
                            
                            // Apply TF's penalty to subclass base penalty score
                            subClass.basePenalty = (subClass.basePenalty + trustFactorOutputObject.trustFactor.penalty.integerValue);
                            
                            // IF the TF triggers on no match (not type 4), update issues and suggestion messages  (triggering a non type 4 rule is bad)
                            if(trustFactorOutputObject.trustFactor.ruleType.intValue != 4){
                                
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
                            } else {
                                // Rule triggered is of Type4 (inverse), such as WiFI BSSID or Bluetooth, this is good
                                
                                // Generate authentictor name based on dispatch (could add a policy attribute if we wanted more custom)
                                NSString *name = [trustFactorOutputObject.trustFactor.dispatch stringByAppendingString:@" authenticator found"];
                                
                                // Check if the we already have the authenticator in our list
                                
                                if (![authenticatorsInClass containsObject:name]) {
                                    
                                    // Make sure the array is not nil!
                                    if (!authenticatorsInClass || authenticatorsInClass.count < 1) {
                                        
                                        // Add it to the array and instantiate the array
                                        authenticatorsInClass = [NSMutableArray arrayWithObject:name];
                                        
                                    } else {
                                        
                                        // Add it to the array
                                        [authenticatorsInClass addObject:name];
                                    }
                                    
                                }
                                
                            }
                            
                            // Rule did not trigger
                        } else {
                            
                            // Check if TF is inverse (not triggering a type 4 rule should not boost score, i.e., don't do anything score wise)
                            if(trustFactorOutputObject.trustFactor.ruleType.intValue == 4){
                                
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
                                if(trustFactorOutputObject.trustFactor.suggestionMessage.length != 0) {
                                    
                                    // Check if we already have the suggestion in our list
                                    if(![suggestionsInClass containsObject:trustFactorOutputObject.trustFactor.suggestionMessage]){
                                        
                                        // Add it
                                        [suggestionsInClass addObject:trustFactorOutputObject.trustFactor.suggestionMessage];
                                    }
                                }
                            }
                        }
                        
                        // TrustFactor did not run successfully -> Did Not Execute
                    } else {
                        
                        // FOR DEBUG OUTPUT
                        [trustFactorsWithErrorsInClass addObject:trustFactorOutputObject];
                        
                        // Record all DNE status codes within the subclass
                        [subClassDNECodes addObject:[NSNumber numberWithInt:trustFactorOutputObject.statusCode]];
                        
                        // Mark subclass as incomplete since not all TFs ran
                        subClassAnalysisIncomplete=YES;
                        
                        // If TrustFactor is inverse then only add suggestions (e.g., we don't penalize for a faulty rule that boosts your score)
                        // If TrustFactor is inverse then only add suggestions (e.g., we don't penalize for a faulty rule that boosts your score)
                        if (trustFactorOutputObject.trustFactor.ruleType.intValue==4){
                            
                            [self addSuggestionsForClass:class withSubClass:subClass withSuggestions:suggestionsInClass forTrustFactorOutputObject:trustFactorOutputObject];
                            
                            // Not an inverse rule therefore record messages AND apply modified DNE penalty
                        } else {
                            
                            [self addSuggestionsAndCalcPenaltyForClass:class withSubClass:subClass withPolicy:policy withSuggestions:suggestionsInClass forTrustFactorOutputObject:trustFactorOutputObject];
                        }
                    }
                    
                    // Add TrustFactor to classification
                    [trustFactorsInClass addObject:trustFactorOutputObject.trustFactor];
                    
                    // Add TrustFactor to subclass
                    [trustFactorsInSubClass addObject:trustFactorOutputObject.trustFactor];
                    
                }
                // End trustfactors loop
            }
            
            // Create Analysis category list for output
            // If any trustFactors existed within this subClass
            if(subClassContainsTrustFactors) {
                
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
                    else{
                        
                        [statusInClass addObject:[NSString stringWithFormat:@"%@ %@", subClass.name, @"check error"]];
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
            
            // End subclassifications loop
        }
        
        // Link subclassification list to classification
        [class setSubClassifications:subClassesInClass];
        
        // Link trustfactors to the classification
        [class setTrustFactors:trustFactorsInClass];
        
        // Add the trustfactors for protect mode to the classification
        [class setTrustFactorsToWhitelist:trustFactorsToWhitelistInClass];
        
        // Set the penalty weight for the classification
        class.weightedPenalty = (class.basePenalty * (1-(0.1 * class.weight.integerValue)) );
        
        // Set GUI elements
        [class setStatus: statusInClass];
        [class setIssues: issuesInClass];
        [class setSuggestions: suggestionsInClass];
        [class setAuthenticators:authenticatorsInClass];
        
        // Set debug elements
        [class setTrustFactorsNotLearned:trustFactorsNotLearnedInClass];
        [class setTrustFactorsTriggered:trustFactorsTriggeredInClass];
        [class setTrustFactorsWithErrors:trustFactorsWithErrorsInClass];
        
        
    }// End classifications loop
    
    // Object to return
    Sentegrity_TrustScore_Computation *computationResults = [[Sentegrity_TrustScore_Computation alloc]init];
    
    computationResults.policy = policy;
    
    // Return computation (mainly to check for errors since this is singleton return not really needed)
    return [computationResults analyzeResultsWithError:error];
}

#pragma mark - Private Helper Methods
// Get a classification from an array with the name provided
- (Sentegrity_TrustScore_Computation *)analyzeResultsWithError:(NSError **)error {
    
    
    // GUI Messages - System
    NSMutableSet *systemIssues = [[NSMutableSet alloc] init];
    NSMutableSet *systemSuggestions = [[NSMutableSet alloc] init];
    NSMutableSet *systemSubClassStatuses = [[NSMutableSet alloc] init];
    
    // GUI Messages - User
    NSMutableSet *userIssues = [[NSMutableSet alloc] init];
    NSMutableSet *userSuggestions = [[NSMutableSet alloc] init];
    NSMutableSet *userAuthenticators = [[NSMutableSet alloc] init];
    NSMutableSet *userSubClassStatuses = [[NSMutableSet alloc] init];
    
    // TrustFactor Sorting - System
    NSMutableArray *systemTrustFactorsTriggered = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsNotLearned = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsWithErrors = [[NSMutableArray alloc] init];
    NSMutableArray *systemAllTrustFactorOutputObjects = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsToWhitelist = [[NSMutableArray alloc] init];
    
    // TrustFactor Sorting - User
    NSMutableArray *userTrustFactorsTriggered = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsNotLearned = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsWithErrors = [[NSMutableArray alloc] init];
    NSMutableArray *userAllTrustFactorOutputObjects = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsToWhitelist = [[NSMutableArray alloc] init];
    
    // Get classifications
    Sentegrity_Classification *systemBreachClass;
    Sentegrity_Classification *systemPolicyClass;
    Sentegrity_Classification *systemSecurityClass;
    Sentegrity_Classification *userAnomalyClass;
    Sentegrity_Classification *userPolicyClass;
    
    int systemClassCount = 0;
    int systemScoreSum = 0;
    
    int userClassCount = 0;
    int userScoreSum = 0;
    
    BOOL systemPolicyViolation=NO;
    BOOL userPolicyViolation=NO;
    
    // Iterate through all classifications populated in prior function
    for (Sentegrity_Classification *class in self.policy.classifications) {
        
        // If its a system class
        if([[class user] intValue]==0){
            
            int currentScore = MIN(100,MAX(0,100-(int)[class weightedPenalty]));
            
            switch ([[class identification] intValue]) {
                    
                case 1:
                    systemBreachClass = class;
                    self.systemBreachScore = currentScore;
                    systemScoreSum = systemScoreSum + currentScore;
                    systemClassCount++;
                    break;
                    
                case 2:
                    systemPolicyClass = class;
                    self.systemPolicyScore = currentScore;
                    
                    // Don't add policy scores to overall as it just inflates it
                    if(currentScore < 100){
                        systemPolicyViolation=YES;
                    }
                    break;
                    
                case 3:
                    systemSecurityClass = class;
                    self.systemSecurityScore = currentScore;
                    systemScoreSum = systemScoreSum + currentScore;
                    systemClassCount++;
                    break;
                default:
                    break;
            }
            
            // Tally system GUI elements
            [systemIssues addObjectsFromArray:[class issues]];
            [systemSuggestions addObjectsFromArray:[class suggestions]];
            [systemSubClassStatuses addObjectsFromArray:[class status]];
            
            // Tally system debug data
            [systemTrustFactorsTriggered addObjectsFromArray:[class trustFactorsTriggered]];
            [systemTrustFactorsNotLearned addObjectsFromArray:[class trustFactorsNotLearned]];
            [systemTrustFactorsWithErrors addObjectsFromArray:[class trustFactorsWithErrors]];
            [systemAllTrustFactorOutputObjects addObjectsFromArray:[class trustFactors]];
            
            // Add whitelists together
            [systemTrustFactorsToWhitelist addObjectsFromArray:[class trustFactorsToWhitelist]];
            
            // When it's a user class
        } else {
            
            int currentScore = MIN(100,MAX(0,100-(int)[class weightedPenalty]));
            
            switch ([[class identification] intValue]) {
                    
                case 4:
                    userPolicyClass = class;
                    self.userPolicyScore = currentScore;
                    
                    // Don't add policy scores to overall as it just inflates it
                    if(currentScore < 100){
                        userPolicyViolation=YES;
                    }
                    break;
                    
                case 5:
                    userAnomalyClass = class;
                    self.userAnomalyScore = currentScore;
                    userScoreSum = userScoreSum +  currentScore;
                    userClassCount++;
                    break;
                default:
                    break;
            }
            
            // Tally user GUI elements
            [userIssues addObjectsFromArray:[class issues]];
            [userSuggestions addObjectsFromArray:[class suggestions]];
            [userSubClassStatuses addObjectsFromArray:[class status]];
            [userAuthenticators addObjectsFromArray:[class authenticators]];
            
            // Tally user debug data
            [userTrustFactorsTriggered addObjectsFromArray:[class trustFactorsTriggered]];
            [userTrustFactorsNotLearned addObjectsFromArray:[class trustFactorsNotLearned]];
            [userTrustFactorsWithErrors addObjectsFromArray:[class trustFactorsWithErrors]];
            [userAllTrustFactorOutputObjects addObjectsFromArray:[class trustFactors]];
            
            // Add whitelists together
            [userTrustFactorsToWhitelist addObjectsFromArray:[class trustFactorsToWhitelist]];
        }
    }
    
    // Set GUI messages (system)
    self.systemGUIIssues = [systemIssues allObjects];
    self.systemGUISuggestions = [systemSuggestions allObjects];
    self.systemGUIAnalysis = [systemSubClassStatuses allObjects];
    
    // Set GUI messages (user)
    self.userGUIIssues = [userIssues allObjects];
    self.userGUISuggestions = [userSuggestions allObjects];
    self.userGUIAnalysis = [userSubClassStatuses allObjects];
    self.userGUIAuthenticators = [userAuthenticators allObjects];
    
    // DEBUG: Set whitelists for system/user domains
    self.protectModeUserWhitelist = userTrustFactorsToWhitelist;
    self.protectModeSystemWhitelist = systemTrustFactorsToWhitelist;
    
    // DEBUG: Set trustfactor objects for system/user domains
    self.userAllTrustFactorOutputObjects = userAllTrustFactorOutputObjects;
    self.systemAllTrustFactorOutputObjects = systemAllTrustFactorOutputObjects;
    
    // DEBUG: Set triggered for system/user domains
    self.userTrustFactorsTriggered = userTrustFactorsTriggered;
    self.systemTrustFactorsTriggered = systemTrustFactorsTriggered;
    
    // DEBUG: Set not learned for system/user domains
    self.userTrustFactorsNotLearned = userTrustFactorsNotLearned;
    self.systemTrustFactorsNotLearned = systemTrustFactorsNotLearned;
    
    // DEBUG: Set errored for system/user domains
    self.userTrustFactorsWithErrors = userTrustFactorsWithErrors;
    self.systemTrustFactorsWithErrors = systemTrustFactorsWithErrors;
    
    
    // Set comprehensive scores
    if(systemPolicyViolation == YES) {
        
        self.systemScore = 0;
        
    } else {
        
        self.systemScore = systemScoreSum / systemClassCount;
    }
    
    if (userPolicyViolation == YES) {
        
        self.userScore = 0;
        
    } else {
        
        self.userScore = userScoreSum / userClassCount;
    }
    
    self.deviceScore = (self.systemScore + self.userScore)/2;
    
    //Defaults
    self.deviceTrusted = YES;
    self.userTrusted = YES;
    self.systemTrusted = YES;
    
    //Check system threshold
    if (self.systemScore < self.policy.systemThreshold.integerValue) {
        // System is not trusted
        self.systemTrusted = NO;
        self.deviceTrusted = NO;
    }
    
    // Check User Threshold
    if (self.userScore < self.policy.userThreshold.integerValue) {
        // User is not trusted
        self.userTrusted = NO;
        self.deviceTrusted = NO;
    }
    
    
    // Analyze system first as it has priority
    
    if(!self.systemTrusted){
        
        // Set protect mode whitelist to all of the system domain
        self.protectModeWhitelist =  self.protectModeSystemWhitelist;
        
        if(self.systemBreachScore <= self.systemSecurityScore) // SYSTEM_BREACH is attributing
        {
            self.protectModeClassID = [systemBreachClass.identification integerValue] ;
            self.protectModeAction = [systemBreachClass.protectModeAction integerValue];
            self.protectModeMessage = systemBreachClass.protectModeMessage;
            
            // Set dashboard and detailed system view info
            self.systemGUIIconID = [systemBreachClass.identification intValue];
            self.systemGUIIconText = systemBreachClass.desc;
            
            // SYSTEM_POLICY is attributing
        } else if(self.systemPolicyScore <= self.systemSecurityScore) {
            
            self.protectModeClassID = [systemPolicyClass.identification integerValue] ;
            self.protectModeAction = [systemPolicyClass.protectModeAction integerValue];
            self.protectModeMessage = systemPolicyClass.protectModeMessage;
            
            // Set dashboard and detailed system view info
            self.systemGUIIconID = [systemPolicyClass.identification intValue];
            self.systemGUIIconText = systemPolicyClass.desc;
            
            //SYSTEM_SECURITY is attributing
        } else {
            
            self.protectModeClassID = [systemSecurityClass.identification integerValue] ;
            self.protectModeAction = [systemSecurityClass.protectModeAction integerValue];
            self.protectModeMessage = systemSecurityClass.protectModeMessage;
            
            // Set dashboard and detailed system view info
            self.systemGUIIconID = [systemSecurityClass.identification intValue];
            self.systemGUIIconText = systemSecurityClass.desc;
        }
        
    } else {
        
        // Set dashboard and detailed system view info
        self.systemGUIIconID = 0;
        self.systemGUIIconText = @"Device Trusted";
    }
    
    if(!self.userTrusted){
        
        // See which classification inside user attributed the most and set protect mode
        // USER_POLICY is attributing
        if(self.userPolicyScore <= self.userAnomalyScore) {
            
            if(self.systemTrusted) {
                
                // Get value of Class ID
                self.protectModeClassID = [userPolicyClass.identification integerValue];
                
                // Get value of protect mode
                self.protectModeAction = [userPolicyClass.protectModeAction integerValue];
                
                // Get protect mode message from policy class and set it to self
                self.protectModeMessage = userPolicyClass.protectModeMessage;
                
                // Initialize protect mode white list
                self.protectModeWhitelist = [[NSArray alloc] init];
                
                // Add entire user domain to whitelist
                self.protectModeWhitelist = [self.protectModeWhitelist arrayByAddingObjectsFromArray:self.protectModeUserWhitelist] ;
            }
            
            // Set dashboard and detailed user view info
            self.userGUIIconID = [userPolicyClass.identification intValue];
            self.userGUIIconText = userPolicyClass.desc;
            
            //USER_ANOMALY is attributing
        } else {
            
            // Set protect mode action to the class specified action ONLY if system did not already
            if(self.systemTrusted){
                self.protectModeClassID = [userAnomalyClass.identification integerValue];
                self.protectModeAction = [userAnomalyClass.protectModeAction integerValue];
                self.protectModeMessage = userAnomalyClass.protectModeMessage;
                
                self.protectModeWhitelist = [[NSMutableArray alloc] init];
                
                // Add just user anomaly to whitelist
                self.protectModeWhitelist = [self.protectModeWhitelist arrayByAddingObjectsFromArray:userAnomalyClass.trustFactorsToWhitelist];
            }
            
            // Set dashboard and detailed user view info
            self.userGUIIconID = [userAnomalyClass.identification intValue];
            self.userGUIIconText = userAnomalyClass.desc;
        }
        
    } else {
        
        // Set dashboard and detailed system view info
        self.userGUIIconID = 0;
        self.userGUIIconText = @"User Trusted";
    }
    
    return self;
}

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
        default:
            break;
    }
    
}

// Calculates penalty and adds suggestions
+ (void)addSuggestionsAndCalcPenaltyForClass:(Sentegrity_Classification *)class withSubClass:(Sentegrity_Subclassification *)subClass withPolicy:(Sentegrity_Policy *)policy withSuggestions:(NSMutableArray *)suggestionsInClass forTrustFactorOutputObject:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject{
    
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
        default:
            
            // Apply error by default
            penaltyMod = [policy.DNEModifiers.error doubleValue];
            break;
    }
    
    // Apply DNE percent to the TFs normal penalty to reduce it (penaltyMode of 0 negates the rule completely)
    subClass.basePenalty = subClass.basePenalty + (trustFactorOutputObject.trustFactor.penalty.integerValue * penaltyMod);
    
}

@end
