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

//trustFactorOutputObject eligable for protectMode whitelisting
@property (nonatomic) NSMutableArray *trustFactorOutputObjectsForProtectMode;

// trustFactorOutputObjects to be passed to computation
@property (nonatomic)  NSMutableArray *trustFactorOutputObjectsForComputation;

+ (instancetype)performBaselineAnalysisUsing:(NSArray *)trustFactorOutputObjects forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error;

@end
