//
//  TrustFactor_Dispatch_Platform.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_TrustFactor_Datasets.h"

@interface TrustFactor_Dispatch_Power
 : NSObject 
// 37
+ (Sentegrity_TrustFactor_Output_Object *)powerLevel:(NSArray *)payload;

// 38
+ (Sentegrity_TrustFactor_Output_Object *)pluggedIn:(NSArray *)payload;

// 38
+ (Sentegrity_TrustFactor_Output_Object *)batteryState:(NSArray *)payload;


@end
