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
- (void)setAppID:(NSString *)appID{
    _appID = appID;
}

// Revision
- (void)setRevision:(NSNumber *)revision{
    _revision = revision;
}

// Private APIs
- (void)setAllowPrivateAPIs:(NSNumber *)allowPrivateAPIs{
    _allowPrivateAPIs = allowPrivateAPIs;
}

// UserThreshold
- (void)setUserThreshold:(NSNumber *)userThreshold{
    _userThreshold = userThreshold;
}

// SystemThreshold
- (void)setSystemThreshold:(NSNumber *)systemThreshold{
    _systemThreshold = systemThreshold;
}

// ContactPhone
- (void)setContactPhone:(NSString *)contactPhone{
    _contactPhone  = contactPhone;
}

// ContactURL
- (void)setContactURL:(NSString *)contactURL{
    _contactURL = contactURL;
}

// ContactEmail
- (void)setContactEmail:(NSString *)contactEmail{
    _contactEmail = contactEmail;
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
- (void)setSubclassifications:(NSArray *)subclassifications{
    _subclassifications = subclassifications;
}

// TrustFactors
- (void)setTrustFactors:(NSArray *)trustFactors{
    _trustFactors = trustFactors;
}

@end