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

NSString const *baseWeightKey = @"Sentegrity.baseWeight";
NSString const *totalWeightKey = @"Sentegrity.totalWeight";
NSString const *subClassificationsKey = @"Sentegrity.subClassifications";
NSString const *trustFactorsKey = @"Sentegrity.trustFactors";

// Base Weight

- (void)setBaseWeight:(NSInteger)baseWeight {
    NSNumber *baseWeightNumber = [NSNumber numberWithInteger:baseWeight];
    objc_setAssociatedObject(self, &baseWeightKey, baseWeightNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)baseWeight {
    NSNumber *baseWeightNumber = objc_getAssociatedObject(self, &baseWeightKey);
    return [baseWeightNumber integerValue];
}

// Total Weight

- (void)setTotalWeight:(NSInteger)totalWeight {
    NSNumber *totalWeightNumber = [NSNumber numberWithInteger:totalWeight];
    objc_setAssociatedObject(self, &totalWeightKey, totalWeightNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)totalWeight {
    NSNumber *totalWeightNumber = objc_getAssociatedObject(self, &totalWeightKey);
    return [totalWeightNumber integerValue];
}

// TrustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKey, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKey);
}

@end
