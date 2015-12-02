//
//  Sentegrity_Subclassification+Computation.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_Subclassification+Computation.h"

// Import the objc runtime
#import <objc/runtime.h>

@implementation Sentegrity_Subclassification (Computation)

NSString const *basePenaltyKey = @"Sentegrity.basePenalty";
NSString const *weightedPenaltyKey = @"Sentegrity.weightedPenalty";
NSString const *subClassificationsKey = @"Sentegrity.subClassifications";
NSString const *trustFactorsKey = @"Sentegrity.trustFactors";

// Base Penalty

- (void)setBasePenalty:(NSInteger)basePenalty {
    NSNumber *basePenaltyNumber = [NSNumber numberWithInteger:basePenalty];
    objc_setAssociatedObject(self, &basePenaltyKey, basePenaltyNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)basePenalty {
    NSNumber *basePenaltyNumber = objc_getAssociatedObject(self, &basePenaltyKey);
    return [basePenaltyNumber integerValue];
}

// Weighted Penalty

- (void)setWeightedPenalty:(NSInteger)weightedPenalty {
    NSNumber *weightedPenaltyNumber = [NSNumber numberWithInteger:weightedPenalty];
    objc_setAssociatedObject(self, &weightedPenaltyKey, weightedPenaltyNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)weightedPenalty {
    NSNumber *weightedPenaltyNumber = objc_getAssociatedObject(self, &weightedPenaltyKey);
    return [weightedPenaltyNumber integerValue];
}

// TrustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKey, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKey);
}

@end
