//
//  Sentegrity_Subclassification+Computation.m
//  SenTest
//
//  Created by Kramer on 4/15/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Subclassification+Computation.h"

// Import the objc runtime
#import <objc/objc-runtime.h>

@implementation Sentegrity_Subclassification (Computation)

NSString const *weightedPenaltyKey = @"Sentegrity.weightedPenalty";
NSString const *subClassificationsKey = @"Sentegrity.subClassifications";
NSString const *trustFactorsKey = @"Sentegrity.trustFactors";


// Weighted Penalty

- (void)setWeightedPenalty:(NSInteger)weightedPenalty {
    NSNumber *weightedPenaltyNumber = [NSNumber numberWithInteger:weightedPenalty];
    objc_setAssociatedObject(self, &weightedPenaltyKey, weightedPenaltyNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)weightedPenalty {
    NSNumber *weightedPenaltyNumber = objc_getAssociatedObject(self, &weightedPenaltyKey);
    return [weightedPenaltyNumber integerValue];
}

// trustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKey, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKey);
}

@end
