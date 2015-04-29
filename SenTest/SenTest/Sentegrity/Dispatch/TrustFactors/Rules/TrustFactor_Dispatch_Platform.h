//
//  TrustFactor_Dispatch_Platform.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Platform : Sentegrity_TrustFactor_Rule

// 23
+ (Sentegrity_Assertion *)vulnerablePlatform:(NSArray *)platforms;

// 28
+ (Sentegrity_Assertion *)platformVersionAllowed:(NSArray *)platformallowed;

// 37
+ (Sentegrity_Assertion *)powerPercent:(NSArray *)powerpercent;

// 38
+ (Sentegrity_Assertion *)shortUptime:(NSArray *)shortuptime;


@end
