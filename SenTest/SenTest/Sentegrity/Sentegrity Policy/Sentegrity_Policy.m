//
//  Sentegrity_Policy.m
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Policy.h"

@implementation Sentegrity_Policy


#pragma mark - Override setters

// Policy ID
- (void)setPolicyID:(NSNumber *)policyID{
    _policyID = policyID;
}

// App ID
- (void)setAppID:(NSNumber *)appID{
    _appID = appID;
}

// Revision
- (void)setRevision:(NSNumber *)revision{
    _revision = revision;
}

// Runtime
- (void)setRuntime:(NSNumber *)runtime{
    _runtime = runtime;
}

// UserThreshold
- (void)setUserThreshold:(NSNumber *)userThreshold{
    _userThreshold = userThreshold;
}

// SystemThreshold
- (void)setSystemThreshold:(NSNumber *)systemThreshold{
    _systemThreshold = systemThreshold;
}

// DNEModifiers
- (void)setDNEModifiers:(Sentegrity_DNEModifiers *)DNEModifiers{
    _DNEModifiers = DNEModifiers;
}

// Classifications
- (void)setClassifications:(NSArray *)classifications{
    _classifications = classifications;
}

// Subclassifications
- (void)setSubclassification:(NSArray *)subclassification{
    _subclassification = subclassification;
}

// TrustFactors
- (void)setTrustFactors:(NSArray *)trustFactors{
    _trustFactors = trustFactors;
}

@end
