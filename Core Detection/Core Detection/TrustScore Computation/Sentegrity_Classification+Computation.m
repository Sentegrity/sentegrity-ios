//
//  Sentegrity_Classification+Computation.m
//  SenTest
//
//  Created by Kramer on 4/15/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Classification+Computation.h"

// Import the objc runtime
#import <objc/runtime.h>

@implementation Sentegrity_Classification (Computation)

NSString const *basePenaltyKeyClass = @"Sentegrity.basePenalty";
NSString const *weightedPenaltyKeyClass = @"Sentegrity.weightedPenalty";
NSString const *subClassificationsKeyClass = @"Sentegrity.subClassifications";
NSString const *trustFactorsKeyClass = @"Sentegrity.trustFactors";

// ProtectMode
NSString const *trustFactorsToWhitelistKey = @"Sentegrity.trustFactorsToWhitelist";

// Debug
NSString const *trustFactorsTriggeredKey = @"Sentegrity.trustFactorsTriggered";
NSString const *trustFactorsNotLearnedKey = @"Sentegrity.trustFactorsNotLearned";
NSString const *trustFactorsWithErrorsKey = @"Sentegrity.trustFactorsWithErrors";

// GUI messages
NSString const *issuesKey = @"Sentegrity.issues";
NSString const *suggestionsKey = @"Sentegrity.suggestions";
NSString const *statusKey = @"Sentegrity.status";


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

- (void)setTrustFactorsTriggered:(NSArray *)trustFactorsTriggered{
    objc_setAssociatedObject(self, &trustFactorsTriggeredKey, trustFactorsTriggered, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsTriggered {
    return objc_getAssociatedObject(self, &trustFactorsTriggeredKey);
}

- (void)setTrustFactorsNotLearned:(NSArray *)trustFactorsNotLearned{
    objc_setAssociatedObject(self, &trustFactorsNotLearnedKey, trustFactorsNotLearned, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsNotLearned {
    return objc_getAssociatedObject(self, &trustFactorsNotLearnedKey);
}

- (void)setTrustFactorsWithErrors:(NSArray *)trustFactorsWithErrors{
    objc_setAssociatedObject(self, &trustFactorsWithErrorsKey, trustFactorsWithErrors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsWithErrors {
    return objc_getAssociatedObject(self, &trustFactorsWithErrorsKey);
}


- (void)setIssues:(NSArray *)issues{
    objc_setAssociatedObject(self, &issuesKey, issues, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)issues {
    return objc_getAssociatedObject(self, &issuesKey);
}


- (void)setSuggestions:(NSArray *)suggestions{
    objc_setAssociatedObject(self, &suggestionsKey, suggestions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)suggestions {
    return objc_getAssociatedObject(self, &suggestionsKey);
}


- (void)setStatus:(NSArray *)status{
    objc_setAssociatedObject(self, &statusKey, status, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)status {
    return objc_getAssociatedObject(self, &statusKey);
}

@end
