//
//  TrustFactor_Dispatch_Platform.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Power: Sentegrity_TrustFactor_Rule

// 37
+ (Sentegrity_TrustFactor_Output_Object *)unknownPowerLevel:(NSArray *)payload;

// 38
+ (Sentegrity_TrustFactor_Output_Object *)pluggedIn:(NSArray *)payload;



@end
