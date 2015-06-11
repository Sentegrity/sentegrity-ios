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

// System Attributing Classification
@property (nonatomic) BOOL systemAttributingClassID;

// Issue Messages
@property (nonatomic) NSArray *systemGUIIssues;

// Suggesstion Messages
@property (nonatomic) NSArray *systemGUISuggesstion;

// Analysis Messages
@property (nonatomic) NSArray *systemGUIAnalysis;




// COMPOSITE USER SCORE

// User Score
@property (nonatomic) int userScore;

// User Trusted
@property (nonatomic) BOOL  userTrusted;

// User Attributing Classification
@property (nonatomic) BOOL  userAttributingClassID;

// Issue Messages
@property (nonatomic) NSArray *userGUIIssues;

// Suggesstion Messages
@property (nonatomic) NSArray *userGUISuggesstion;

// Analysis Messages
@property (nonatomic) NSArray *userGUIAnalysis;


// COMPOSITE DEVICE SCORE

// Device Score
@property (nonatomic) int deviceScore;

// device Trusted
@property (nonatomic) BOOL  deviceTrusted;


//PROTECT MODE

// Device Score
@property (nonatomic) NSInteger protectModeClassID;

@property (nonatomic) NSInteger protectModeAction;

@property (nonatomic) NSString *protectModeMessage;

//Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *protectModeWhitelist;




// Compute the systemScore and the UserScore from the trust scores and the assertion storage objects
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorAssertions withError:(NSError **)error;



@end
