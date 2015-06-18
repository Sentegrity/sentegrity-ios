//
//  TrustFactor_Dispatch_Location.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Location : Sentegrity_TrustFactor_Rule


// 26
+ (Sentegrity_TrustFactor_Output_Object *)allowed:(NSArray *)payload;

// 31
+ (Sentegrity_TrustFactor_Output_Object *)unknown:(NSArray *)payload;

@end
