//
//  TrustFactor_Dispatch_Sensor.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Sensor : Sentegrity_TrustFactor_Rule


// 29
+ (Sentegrity_TrustFactor_Output_Object *)unknownMovement:(NSArray *)payload;

// 30
+ (Sentegrity_TrustFactor_Output_Object *)unknownPosition:(NSArray *)payload;

@end