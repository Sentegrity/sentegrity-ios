//
//  TrustFactor_Dispatch_Process.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Process : Sentegrity_TrustFactor_Rule

// 2 - Known Bad Processes
+ (Sentegrity_TrustFactor_Output_Object *)knownBad:(NSArray *)payload;


// 11 - New Root Processes (gets all root processes: launched by launchd)
+ (Sentegrity_TrustFactor_Output_Object *)newRoot:(NSArray *)payload;


// 20 - Checks for process names that match high risk application names
+ (Sentegrity_TrustFactor_Output_Object *)highRiskApp:(NSArray *)payload;

@end
