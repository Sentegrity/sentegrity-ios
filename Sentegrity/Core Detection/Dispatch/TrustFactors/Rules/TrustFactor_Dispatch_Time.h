//
//  TrustFactor_Dispatch_Time.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Time : Sentegrity_TrustFactor_Rule

// Not implemented in default policy
//+ (Sentegrity_TrustFactor_Output_Object *)allowedAccessTime:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)unknownAccessTime:(NSArray *)payload;

@end





