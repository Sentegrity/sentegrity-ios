//
//  TrustFactor_Dispatch_Activity.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Activity : Sentegrity_TrustFactor_Rule

// 39
+ (Sentegrity_Assertion *)activity:(NSArray *)activity;

@end
