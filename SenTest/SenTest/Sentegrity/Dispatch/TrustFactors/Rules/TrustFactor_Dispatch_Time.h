//
//  TrustFactor_Dispatch_Time.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Time : Sentegrity_TrustFactor_Rule


// 25
+ (Sentegrity_Assertion *)timeAllowed:(NSArray *)timeallowed;

// 32
+ (Sentegrity_Assertion *)accessTime:(NSArray *)accesstime;


@end
