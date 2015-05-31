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

// TODO: BETA2 Change the way scores are computed
// TODO: BETA2 Establish learning mode

//CLASSIFICATION SCORES

// System Score
@property (nonatomic) int systemBreachScore;
// User Score
@property (nonatomic) int systemSecurityScore;
// Device Score
@property (nonatomic) int policyScore;
// Device Score
@property (nonatomic) int userAnomalyScore;

//SUBSET SCORES

// System Score
@property (nonatomic) int systemScore;
// User Score
@property (nonatomic) int userScore;

//DEVICE SCORES

// Device Score
@property (nonatomic) int deviceScore;

//TRUST RESULTS

// System Trusted
@property (nonatomic) BOOL systemTrusted;
// User Trusted
@property (nonatomic) BOOL  userTrusted;
// Device Trusted
@property (nonatomic) BOOL deviceTrusted;

//PROTECT MODE

// Device Score
@property (nonatomic) NSInteger protectModeClassification;

@property (nonatomic) NSInteger protectModeAction;

@property (nonatomic) NSString *protectModeInfo;

@property (nonatomic) NSString *protectModeName;


// Classification information
@property (nonatomic,retain) NSArray *classificationInformation;


// Compute the systemScore and the UserScore from the trust scores and the assertion storage objects
+ (instancetype)performTrustFactorComputationWithPolicy:(Sentegrity_Policy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorAssertions withError:(NSError **)error;



@end
