//
//  Sentegrity_Classifications.m
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Authentication.h"

@implementation Sentegrity_Authentication

// Identification

- (void)setIdentification:(NSNumber *)identification{
    _identification = identification;
}

// Name

- (void)setName:(NSString *)name{
    _name = name;
}

// warning desc

- (void)setWarnDesc:(NSString *)warnDesc{
    _warnDesc = warnDesc;
}


// warning title

- (void)setWarnTitle:(NSString *)warnTitle{
    _warnTitle = warnTitle;
}

// gui icon text

- (void)setDashboardText:(NSString *)dashboardText{
    _dashboardText = dashboardText;
}

// ActivationRange

- (void)setActivationRange:(NSNumber *)activationRange{
    _activationRange = activationRange;
}

// PostAuthenticationAction

- (void)setAuthenticationAction:(NSNumber *)authenticationAction{
    _authenticationAction = authenticationAction;
}


// PostAuthenticationAction

- (void)setPostAuthenticationAction:(NSNumber *)postAuthenticationAction{
    _postAuthenticationAction = postAuthenticationAction;
}



@end

