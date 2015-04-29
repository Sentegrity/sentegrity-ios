//
//  TrustFactor_Dispatch_NetStat.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Netstat : Sentegrity_TrustFactor_Rule

// 3
+ (Sentegrity_TrustFactor_Output *)badNetDst:(NSArray *)destination;


// 9
+ (Sentegrity_TrustFactor_Output *)priviledgedNetServices:(NSArray *)netservices;


// 13
+ (Sentegrity_TrustFactor_Output *)newNetService:(NSArray *)netservices;


// 14
+ (Sentegrity_TrustFactor_Output *)unencryptedTraffic:(NSArray *)traffic;


@end
