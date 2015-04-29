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
+ (Sentegrity_TrustFactor_Output *)policyTamper:(NSArray *)poltamper;

// 24
+ (Sentegrity_TrustFactor_Output *)systemProtectMode:(NSArray *)protectionmode;

// 40
+ (Sentegrity_TrustFactor_Output *)userProtectMode:(NSArray *)userprotectmode;


@end
