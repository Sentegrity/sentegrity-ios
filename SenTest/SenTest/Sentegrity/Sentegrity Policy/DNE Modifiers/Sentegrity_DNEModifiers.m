//
//  DNEModifiers.m
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_DNEModifiers.h"

@implementation Sentegrity_DNEModifiers

// Unauthorized
- (void)setUnauthorized:(NSNumber *)unauthorized{
    _unauthorized = unauthorized;
}

// Unsupported
- (void)setUnsupported:(NSNumber *)unsupported{
    _unsupported = unsupported;
}

// Disabled
- (void)setDisabled:(NSNumber *)disabled{
    _disabled = disabled;
}

// Expired
- (void)setExpired:(NSNumber *)expired{
    _expired = expired;
}

//Error
- (void)setError:(NSNumber *)error{
    _error = error;
}



@end
