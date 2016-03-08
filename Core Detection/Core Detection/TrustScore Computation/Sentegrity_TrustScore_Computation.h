//
//  Sentegrity_TrustScore_Computation.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Policy.h"

@interface Sentegrity_TrustScore_Computation : NSObject

// Policy object
@property (nonatomic) Sentegrity_Policy *policy;

#pragma mark - Debug

// Tracking not learned
@property (nonatomic) NSArray *userTrustFactorsNotLearned;
@property (nonatomic) NSArray *systemTrustFactorsNotLearned;

// Tracking triggered rules
@property (nonatomic) NSArray *userTrustFactorsAttributingToScore;
@property (nonatomic) NSArray *systemTrustFactorsAttributingToScore;

// Tracking errors
@property (nonatomic) NSArray *userTrustFactorsWithErrors;
@property (nonatomic) NSArray *systemTrustFactorsWithErrors;

// All Output
@property (nonatomic) NSArray *userAllTrustFactorOutputObjects;
@property (nonatomic) NSArray *systemAllTrustFactorOutputObjects;

#pragma mark - Classification Scores

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

#pragma mark - Composite System Score

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

#pragma mark - Composite User Score

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

// User detailed view: Authenticator Messages (we don't do this in the system space)
@property (nonatomic) NSArray *userGUIAuthenticators;

// User detailed view: Analysis Messages
@property (nonatomic) NSArray *userGUIAnalysis;

#pragma mark - Composite Device Score

// Device Score
@property (nonatomic) int deviceScore;

// device Trusted
@property (nonatomic) BOOL  deviceTrusted;

#pragma mark - Protect Mode

// Classification responsible for causing protect mode
@property (nonatomic) NSInteger protectModeClassID;

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger protectModeAction;

// Message to display in prompt box
@property (nonatomic) NSString *protectModeMessage;

// Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeWhitelist;

// Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeUserWhitelist;

// Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeSystemWhitelist;

// Holds the trustFactorOutputObjects for use in transparent authentication
@property (nonatomic) NSArray *transparentAuthenticationTrustFactors;

// Should attempt transparent authentication
@property (nonatomic) BOOL  attemptTransparentAuthentication;

// Compute the systemScore and the UserScore from the trust scores and the assertion storage objects
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorAssertions withError:(NSError **)error;

@end
