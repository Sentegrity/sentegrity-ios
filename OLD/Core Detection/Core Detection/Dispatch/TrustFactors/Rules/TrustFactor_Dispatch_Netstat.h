//
//  TrustFactor_Dispatch_NetStat.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Trust Factor Dispatch Netstat is a rule that uses Netstat information for TrustScore calculation.
 */
#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Netstat : NSObject 

// Bad destination
+ (Sentegrity_TrustFactor_Output_Object *)badDst:(NSArray *)payload;

// Priviledged port
+ (Sentegrity_TrustFactor_Output_Object *)priviledgedPort:(NSArray *)payload;

// New service
+ (Sentegrity_TrustFactor_Output_Object *)newService:(NSArray *)payload;

// Data exfiltration
+ (Sentegrity_TrustFactor_Output_Object *)dataExfiltration:(NSArray *)payload;

// Unencrypted traffic
+ (Sentegrity_TrustFactor_Output_Object *)unencryptedTraffic:(NSArray *)payload;

@end
