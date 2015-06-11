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

NSString const *basePenaltyKeyClass = @"Sentegrity.basePenalty";
NSString const *weightedPenaltyKeyClass = @"Sentegrity.weightedPenalty";
NSString const *subClassificationsKeyClass = @"Sentegrity.subClassifications";
NSString const *trustFactorsKeyClass = @"Sentegrity.trustFactors";
NSString const *trustFactorsToWhitelistKey = @"Sentegrity.trustFactorsToWhitelist";

// GUI messages
NSString const *issuesInClassKey = @"Sentegrity.issuesInClass";
NSString const *suggestionsInClassKey = @"Sentegrity.suggestionsInClass";
NSString const *subClassStatusKey = @"Sentegrity.subClassStatus";


// Base Penalty

- (void)setBasePenalty:(NSInteger)basePenalty {
    NSNumber *basePenaltyNumber = [NSNumber numberWithInteger:basePenalty];
    objc_setAssociatedObject(self, &basePenaltyKeyClass, basePenaltyNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)basePenalty {
    NSNumber *basePenaltyNumber = objc_getAssociatedObject(self, &basePenaltyKeyClass);
    return [basePenaltyNumber integerValue];
}
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

// trustFactors to whitelist during protect mode deactivation

- (void)setTrustFactorsToWhitelist:(NSArray *)trustFactorsToWhitelist{
    objc_setAssociatedObject(self, &trustFactorsToWhitelistKey, trustFactorsToWhitelist, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsToWhitelist {
    return objc_getAssociatedObject(self, &trustFactorsToWhitelistKey);
}

- (void)setIssuesInClass:(NSArray *)issuesInClass{
    objc_setAssociatedObject(self, &issuesInClassKey, issuesInClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)issuesInClass {
    return objc_getAssociatedObject(self, &issuesInClassKey);
}


- (void)setSuggestionsInClass:(NSArray *)suggestionsInClass{
    objc_setAssociatedObject(self, &suggestionsInClassKey, suggestionsInClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)suggestionsInClass {
    return objc_getAssociatedObject(self, &suggestionsInClassKey);
}


- (void)setSubClassStatus:(NSArray *)subClassStatus{
    objc_setAssociatedObject(self, &subClassStatusKey, subClassStatus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)subClassStatus {
    return objc_getAssociatedObject(self, &subClassStatusKey);
}

@end
