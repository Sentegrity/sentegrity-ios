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

NSString const *scoreKeyClass = @"Sentegrity.score";
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
NSString const *trustFactorsIssuesKey = @"Sentegrity.trustFactorIssues";
NSString const *trustFactorsSuggestionsKey = @"Sentegrity.trustFactorSuggestions";
NSString const *trustFactorsStatusKey = @"Sentegrity.trustFactorStatus";

// GUI messages
NSString const *subClassResultObjectsKey = @"Sentegrity.subClassResultObjects";


// Classification score

- (void)setScore:(NSInteger)score {
    NSNumber *scoreNumber = [NSNumber numberWithInteger:score];
    objc_setAssociatedObject(self, &scoreKeyClass, scoreNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)score {
    NSNumber *scoreNumber = objc_getAssociatedObject(self, &scoreKeyClass);
    return [scoreNumber integerValue];
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


// SubClassResultObjects, one object per subclass that is used within this class
- (void)setSubClassResultObjects:(NSArray *)subClassResultObjects{
    objc_setAssociatedObject(self, &subClassResultObjectsKey, subClassResultObjects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)subClassResultObjects {
    return objc_getAssociatedObject(self, &subClassResultObjectsKey);
}

@end
