//
//  Sentegrity_Assertion.h
//  SenTest
//
//  Created by Kramer on 2/24/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_TrustFactor.h"

@interface Sentegrity_TrustFactor_Output : NSObject

// Get the trustfactor
@property (nonatomic,retain) Sentegrity_TrustFactor *trustFactor;

// Get the revision number (from policy)
@property (nonatomic,retain) NSNumber *revision;

// Get the trustfactor return result (pass/fail)
@property (nonatomic,retain) NSNumber *returnResult;

// Get the trustfactor output
@property (nonatomic,retain) NSArray *output;

// Did the trustfactor run
@property BOOL ran;

// Get when the trustfactor ran
@property (nonatomic,retain) NSDate *runDate;

@end
