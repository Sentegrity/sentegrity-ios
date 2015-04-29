//
//  TrustFactor_Dispatch_CoreDetection.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_CoreDetection : Sentegrity_TrustFactor_Rule

// 7
+ (Sentegrity_Assertion *)policyTamper:(NSArray *)poltamper;

// 24
+ (Sentegrity_Assertion *)systemProtectMode:(NSArray *)protectionmode;

// 40
+ (Sentegrity_Assertion *)userProtectMode:(NSArray *)userprotectmode;


@end
