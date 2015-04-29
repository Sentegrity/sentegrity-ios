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
+ (Sentegrity_TrustFactor_Output *)vulnerablePlatform:(NSArray *)platforms;

// 28
+ (Sentegrity_TrustFactor_Output *)platformVersionAllowed:(NSArray *)platformallowed;

// 37
+ (Sentegrity_TrustFactor_Output *)powerPercent:(NSArray *)powerpercent;

// 38
+ (Sentegrity_TrustFactor_Output *)shortUptime:(NSArray *)shortuptime;


@end
