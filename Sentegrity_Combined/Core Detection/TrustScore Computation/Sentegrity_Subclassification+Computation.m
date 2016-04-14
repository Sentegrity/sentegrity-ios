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
NSString const *totalScoreKey = @"Sentegrity.score";
NSString const *subClassificationsKey = @"Sentegrity.subClassifications";
NSString const *trustFactorsKey = @"Sentegrity.trustFactors";

// Subclass Score

- (void)setScore:(NSInteger)score {
    NSNumber *totalScore = [NSNumber numberWithInteger:score];
    objc_setAssociatedObject(self, &totalScoreKey, totalScore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)score {
    NSNumber *totalScore = objc_getAssociatedObject(self, &totalScoreKey);
    return [totalScore integerValue];
}

// TrustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKey, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKey);
}

@end
