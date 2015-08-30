//
//  TrustFactor_Dispatch_NetStat.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Netstat : NSObject 

// 3
+ (Sentegrity_TrustFactor_Output_Object *)badDst:(NSArray *)payload;


// 9
+ (Sentegrity_TrustFactor_Output_Object *)priviledgedPort:(NSArray *)payload;


// 13
+ (Sentegrity_TrustFactor_Output_Object *)newService:(NSArray *)payload;

// 13
+ (Sentegrity_TrustFactor_Output_Object *)dataExfiltration:(NSArray *)payload;

// 13
+ (Sentegrity_TrustFactor_Output_Object *)unencryptedTraffic:(NSArray *)payload;



@end
