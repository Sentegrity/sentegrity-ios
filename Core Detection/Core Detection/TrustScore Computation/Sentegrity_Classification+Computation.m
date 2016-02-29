//
//  Sentegrity_Classification+Computation.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
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

// Transparent Auth
NSString const *trustFactorsForTransparentAuthenticationKey = @"Sentegrity.trustFactorsForTransparentAuthentication";

// Debug
NSString const *trustFactorsTriggeredKey = @"Sentegrity.trustFactorsTriggered";
NSString const *trustFactorsNotLearnedKey = @"Sentegrity.trustFactorsNotLearned";
NSString const *trustFactorsWithErrorsKey = @"Sentegrity.trustFactorsWithErrors";

// GUI messages
NSString const *issuesKey = @"Sentegrity.issues";
NSString const *suggestionsKey = @"Sentegrity.suggestions";
NSString const *statusKey = @"Sentegrity.status";
NSString const *authenticatorsKey = @"Sentegrity.authenticators";


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

// TrustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKeyClass, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKeyClass);
}

// TrustFactors for transparent authentication

- (void)setTrustFactorsForTransparentAuthentication:(NSArray *)trustFactorsForTransparentAuthentication{
    objc_setAssociatedObject(self, &trustFactorsForTransparentAuthenticationKey, trustFactorsForTransparentAuthentication, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsForTransparentAuthentication {
    return objc_getAssociatedObject(self, &trustFactorsForTransparentAuthenticationKey);
}

// TrustFactors to whitelist during protect mode deactivation

- (void)setTrustFactorsToWhitelist:(NSArray *)trustFactorsToWhitelist{
    objc_setAssociatedObject(self, &trustFactorsToWhitelistKey, trustFactorsToWhitelist, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsToWhitelist {
    return objc_getAssociatedObject(self, &trustFactorsToWhitelistKey);
}

// TrustFactors that are triggered during tests
- (void)setTrustFactorsTriggered:(NSArray *)trustFactorsTriggered{
    objc_setAssociatedObject(self, &trustFactorsTriggeredKey, trustFactorsTriggered, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsTriggered {
    return objc_getAssociatedObject(self, &trustFactorsTriggeredKey);
}

// TrustFactors that have not been learned yet by assertion
- (void)setTrustFactorsNotLearned:(NSArray *)trustFactorsNotLearned{
    objc_setAssociatedObject(self, &trustFactorsNotLearnedKey, trustFactorsNotLearned, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsNotLearned {
    return objc_getAssociatedObject(self, &trustFactorsNotLearnedKey);
}

// TrustFactors with error checking
- (void)setTrustFactorsWithErrors:(NSArray *)trustFactorsWithErrors{
    objc_setAssociatedObject(self, &trustFactorsWithErrorsKey, trustFactorsWithErrors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsWithErrors {
    return objc_getAssociatedObject(self, &trustFactorsWithErrorsKey);
}

// Issues
- (void)setIssues:(NSArray *)issues{
    objc_setAssociatedObject(self, &issuesKey, issues, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)issues {
    return objc_getAssociatedObject(self, &issuesKey);
}

// Suggestion
- (void)setSuggestions:(NSArray *)suggestions{
    objc_setAssociatedObject(self, &suggestionsKey, suggestions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)suggestions {
    return objc_getAssociatedObject(self, &suggestionsKey);
}

// Status
- (void)setStatus:(NSArray *)status{
    objc_setAssociatedObject(self, &statusKey, status, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)status {
    return objc_getAssociatedObject(self, &statusKey);
}

// Authenticators
- (void)setAuthenticators:(NSArray *)authenticators{
    objc_setAssociatedObject(self, &authenticatorsKey, authenticators, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)authenticators {
    return objc_getAssociatedObject(self, &authenticatorsKey);
}

@end
