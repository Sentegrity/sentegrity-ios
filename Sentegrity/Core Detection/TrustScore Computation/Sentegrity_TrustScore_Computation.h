//
//  Sentegrity_TrustScore_Computation.h
//  SenTest
//
//  Created by Kramer on 4/8/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Policy.h"

@interface Sentegrity_TrustScore_Computation : NSObject

// Singleton instance
+ (id)sharedComputationResults;

// Policy object
@property (nonatomic) Sentegrity_Policy *policy;


//DEBUG

// Tracking not learned
@property (nonatomic) NSArray *userTrustFactorsNotLearned;
@property (nonatomic) NSArray *systemTrustFactorsNotLearned;

// Tracking triggered rules
@property (nonatomic) NSArray *userTrustFactorsTriggered;
@property (nonatomic) NSArray *systemTrustFactorsTriggered;

// Tracking errors
@property (nonatomic) NSArray *userTrustFactorsWithErrors;
@property (nonatomic) NSArray *systemTrustFactorsWithErrors;

// All Output
@property (nonatomic) NSArray *userAllTrustFactorOutputObjects;
@property (nonatomic) NSArray *systemAllTrustFactorOutputObjects;


//CLASSIFICATION SCORES

// System Breach
@property (nonatomic) int systemBreachScore;
// Device Policy Violation
@property (nonatomic) int systemPolicyScore;
// System Security (Anomaly)
@property (nonatomic) int systemSecurityScore;
// User Policy Violation
@property (nonatomic) int userPolicyScore;
// User Anomaly
@property (nonatomic) int userAnomalyScore;


// COMPOSITE SYSTEM SCORE

// System Score
@property (nonatomic) int systemScore;

// System Trusted
@property (nonatomic) BOOL systemTrusted;

// System Icon index for dash and detailed view
@property (nonatomic) int systemGUIIconID;

// System text to accompany icon
@property (nonatomic) NSString *systemGUIIconText;

// System detailed view: Issue Messages
@property (nonatomic) NSArray *systemGUIIssues;

// System detailed view: Suggesstion Messages
@property (nonatomic) NSArray *systemGUISuggestions;

// System detailed view: Analysis Messages
@property (nonatomic) NSArray *systemGUIAnalysis;


// COMPOSITE USER SCORE

// User Score
@property (nonatomic) int userScore;

// User Trusted
@property (nonatomic) BOOL  userTrusted;

// User Icon index for dash and detailed view
@property (nonatomic) int  userGUIIconID;

// User text to accompany icon on dash and detailed view
@property (nonatomic) NSString *userGUIIconText;

// User detailed view: Issue Messages
@property (nonatomic) NSArray *userGUIIssues;

// User detailed view: Suggesstion Messages
@property (nonatomic) NSArray *userGUISuggestions;

// User detailed view: Analysis Messages
@property (nonatomic) NSArray *userGUIAnalysis;


// COMPOSITE DEVICE SCORE

// Device Score
@property (nonatomic) int deviceScore;

// device Trusted
@property (nonatomic) BOOL  deviceTrusted;


//PROTECT MODE

// Classification responsible for causing protect mode
@property (nonatomic) NSInteger protectModeClassID;

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger protectModeAction;

// Message to display in prompt box
@property (nonatomic) NSString *protectModeMessage;

//Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeWhitelist;

//Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeUserWhitelist;

//Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeSystemWhitelist;



// Compute the systemScore and the UserScore from the trust scores and the assertion storage objects
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorAssertions withError:(NSError **)error;



@end
