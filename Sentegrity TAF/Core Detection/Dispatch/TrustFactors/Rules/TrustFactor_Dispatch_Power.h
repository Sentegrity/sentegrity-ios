//
//  TrustFactor_Dispatch_Platform.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Power is a rule that uses power level, whether the device is plugged in, and 
 *  battery state for TrustFactor calculations
 */

#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_TrustFactor_Datasets.h"

@interface TrustFactor_Dispatch_Power : NSObject

// Check power level of device
+ (Sentegrity_TrustFactor_Output_Object *)powerLevelTime:(NSArray *)payload;

// Check if device is plugged in and charging
+ (Sentegrity_TrustFactor_Output_Object *)pluggedIn:(NSArray *)payload;

// Get the state of the battery
+ (Sentegrity_TrustFactor_Output_Object *)batteryState:(NSArray *)payload;


@end
