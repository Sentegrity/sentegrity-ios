//
//  TrustFactor_Dispatch_Process.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Process : Sentegrity_TrustFactor_Rule

// 2
+ (Sentegrity_Assertion *)badProcesses:(NSArray *)processes;


// 11
+ (Sentegrity_Assertion *)newRootProcess:(NSArray *)rootprocesses;


// 12
+ (Sentegrity_Assertion *)badProcessPath:(NSArray *)processpaths;


// 20
+ (Sentegrity_Assertion *)highRiskApp:(NSArray *)riskyapps;

@end
