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
+ (Sentegrity_TrustFactor_Output *)badProcesses:(NSArray *)processes;


// 11
+ (Sentegrity_TrustFactor_Output *)newRootProcess:(NSArray *)rootprocesses;


// 12
+ (Sentegrity_TrustFactor_Output *)badProcessPath:(NSArray *)processpaths;


// 20
+ (Sentegrity_TrustFactor_Output *)highRiskApp:(NSArray *)riskyapps;

@end
