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

// Title

- (void)setWarnTitle:(NSString *)warnTitle{
    _warnTitle = warnTitle;
}

// Description

- (void)setWarnDesc:(NSString *)warnDesc{
    _warnDesc = warnDesc;
}

// Dashboard Text

- (void)setDashboardText:(NSString *)dashboardText{
    _dashboardText = dashboardText;
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
