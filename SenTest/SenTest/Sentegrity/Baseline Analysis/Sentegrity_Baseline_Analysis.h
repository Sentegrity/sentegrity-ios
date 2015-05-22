//
//  Sentegrity_TrustScore_Computation.h
//  SenTest
//
//  Created by Kramer on 4/8/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_Policy.h"

@interface Sentegrity_Baseline_Analysis : NSObject

// trustFactorOutputObjects for whitelist during user protect modes
@property (nonatomic) NSMutableArray *userTrustFactorsToWhitelist;

// trustFactorOutputObjects for whitelist during policy protect modes
@property (nonatomic) NSMutableArray *systemTrustFactorsToWhitelist;

// trustFactorOutputObjects for whitelist during system protect modes
@property (nonatomic) NSMutableArray *policyTrustFactorsToWhitelist;

// trustFactorOutputObjects to be passed to computation
@property (nonatomic)  NSMutableArray *trustFactorOutputObjectsForComputation;

+ (instancetype)performBaselineAnalysisUsing:(NSArray *)trustFactorOutputObjects forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error;

@end
