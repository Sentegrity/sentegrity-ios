//
//  TrustFactor_Dispatch_Sandbox.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Sandbox : Sentegrity_TrustFactor_Rule

// 8
+ (Sentegrity_TrustFactor_Output *)sandboxVerification:(NSArray *)verification;

@end
