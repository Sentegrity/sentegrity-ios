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

// User

- (void)setType:(NSNumber *)type{
    _type = type;
}

// Computation method

- (void)setComputationMethod:(NSNumber *)computationMethod{
    _computationMethod = computationMethod;
}

// Name

- (void)setName:(NSString *)name{
    _name = name;
}

// Description

- (void)setDesc:(NSString *)desc{
    _desc = desc;
}


// ProtectModeAction

- (void)setAuthenticationAction:(NSNumber *)authenticationAction{
    _authenticationAction = authenticationAction;
}

// ProtectModeMessage

- (void)setPostAuthenticationAction:(NSNumber *)postAuthenticationAction{
    _postAuthenticationAction = postAuthenticationAction;
}



@end
