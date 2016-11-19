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
NSString const *totalPossibleScoreKey = @"Sentegrity.totalPossibleScore";
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

// Subclass Total Possible Score

- (void)setTotalPossibleScore:(NSInteger)totalPossibleScore {
    NSNumber *totalPossible = [NSNumber numberWithInteger:totalPossibleScore];
    objc_setAssociatedObject(self, &totalPossibleScoreKey, totalPossible, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)totalPossibleScore {
    NSNumber *totalPossibleScore = objc_getAssociatedObject(self, &totalPossibleScoreKey);
    return [totalPossibleScore integerValue];
}


// TrustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKey, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKey);
}

@end
