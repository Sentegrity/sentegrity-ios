//
//  Sentegrity_Classifications.m
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Classification.h"

@implementation Sentegrity_Classification

// Identification

- (void)setIdentification:(NSNumber *)identification{
    _identification = identification;
}

// Name

- (void)setName:(NSString *)name{
    _name = name;
}

// Weight

- (void)setWeight:(NSNumber *)weight{
    _weight = weight;
}

// ProtectMode

- (void)setProtectMode:(NSNumber *)protectMode{
    _protectMode = protectMode;
}

// ProtectViolationName

- (void)setProtectViolationName:(NSString *)protectViolationName{
    _protectViolationName = protectViolationName;
}

// ProtectInfo

- (void)setProtectInfo:(NSString *)protectInfo{
    _protectInfo = protectInfo;
}

// Contact Phone

- (void)setContactPhone:(NSString *)contactPhone{
    _contactPhone = contactPhone;
}

// Contact URL

- (void)setContactURL:(NSString *)contactURL{
    _contactURL = contactURL;
}

// Contact Email

- (void)setContactEmail:(NSString *)contactEmail{
    _contactEmail = contactEmail;
}

@end
