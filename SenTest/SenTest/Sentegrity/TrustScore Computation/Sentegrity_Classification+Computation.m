//
//  Sentegrity_Classification+Computation.m
//  SenTest
//
//  Created by Kramer on 4/15/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Classification+Computation.h"

// Import the objc runtime
#import <objc/objc-runtime.h>

@implementation Sentegrity_Classification (Computation)

NSString const *weightedPenaltyKeyClass = @"Sentegrity.weightedPenalty";
NSString const *subClassificationsKeyClass = @"Sentegrity.subClassifications";
NSString const *trustFactorsKeyClass = @"Sentegrity.trustFactors";

// Weighted Penalty

- (void)setWeightedPenalty:(NSInteger)weightedPenalty {
    NSNumber *weightedPenaltyNumber = [NSNumber numberWithInteger:weightedPenalty];
    objc_setAssociatedObject(self, &weightedPenaltyKeyClass, weightedPenaltyNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)weightedPenalty {
    NSNumber *weightedPenaltyNumber = objc_getAssociatedObject(self, &weightedPenaltyKeyClass);
    return [weightedPenaltyNumber integerValue];
}

// Subclassifications

- (void)setSubClassifications:(NSArray *)subClassifications {
    objc_setAssociatedObject(self, &subClassificationsKeyClass, subClassifications, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)subClassifications {
    return objc_getAssociatedObject(self, &subClassificationsKeyClass);
}

// trustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKeyClass, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKeyClass);
}

@end
