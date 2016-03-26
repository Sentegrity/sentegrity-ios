//
//  Sentegrity_TrustScore_Computation.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Policy.h"
#import "Sentegrity_Classification.h"

// Transparent Authentication
#import "TransparentAuthentication.h"

@interface Sentegrity_TrustScore_Computation : NSObject

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


#pragma mark - Classification Types

// After we figure out what classification is which we assign them here in order to map protect mode actions

@property (nonatomic) Sentegrity_Classification *systemBreachClass;
@property (nonatomic) Sentegrity_Classification *systemPolicyClass;
@property (nonatomic) Sentegrity_Classification *systemSecurityClass;
@property (nonatomic) Sentegrity_Classification *userAnomalyClass;
@property (nonatomic) Sentegrity_Classification *userPolicyClass;

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
@property (nonatomic) NSArray *systemIssues;

// System detailed view: Suggesstion Messages
@property (nonatomic) NSArray *systemSuggestions;

// System detailed view: Analysis Messages
@property (nonatomic) NSArray *systemAnalysisResults;


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
@property (nonatomic) NSArray *userIssues;

// User detailed view: Suggesstion Messages
@property (nonatomic) NSArray *userSuggestions;

// User detailed view: Analysis Messages
@property (nonatomic) NSArray *userAnalysisResults;



#pragma mark - Composite Device Score

// Device Score
@property (nonatomic) int deviceScore;

// device Trusted
@property (nonatomic) BOOL  deviceTrusted;



#pragma mark - Core Detection Results and Action Code

// Classification responsible for causing protect mode
@property (nonatomic) NSInteger attributingClassID;

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger violationActionCode;

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger authenticationActionCode;

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger CoreDetectionResultCode;


#pragma mark - Authentication Results and Action Code

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger authenticationResponseCode;


#pragma mark - Core Detection Whitelists

// Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeWhitelist;

// Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeUserWhitelist;

// Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeSystemWhitelist;


#pragma mark - Transparent Authentication

// Holds the trustFactorOutputObjects for use in transparent authentication
@property (nonatomic) NSArray *transparentAuthenticationTrustFactorOutputObjects;

// Transparent authentication result
@property (nonatomic) NSInteger  transparentAuthenticationAction;

// Should attempt transparent authentication
@property (nonatomic) BOOL  shouldAttemptTransparentAuthentication;



// Compute the systemScore and the UserScore from the trust scores and the assertion storage objects
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorAssertions withError:(NSError **)error;

@end
