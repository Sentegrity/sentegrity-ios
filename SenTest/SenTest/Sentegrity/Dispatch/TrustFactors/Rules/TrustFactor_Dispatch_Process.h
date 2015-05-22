//
//  TrustFactor_Dispatch_Process.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Process : Sentegrity_TrustFactor_Rule

+ (BOOL)updateProcessList;

// 2
+ (Sentegrity_TrustFactor_Output_Object *)knownBad:(NSArray *)payload;


// 11
+ (Sentegrity_TrustFactor_Output_Object *)newRoot:(NSArray *)payload;


// 20
+ (Sentegrity_TrustFactor_Output_Object *)highRiskApp:(NSArray *)payload;

@end
