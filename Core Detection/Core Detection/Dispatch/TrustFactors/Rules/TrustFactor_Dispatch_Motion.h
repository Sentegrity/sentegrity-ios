//
//  TrustFactor_Dispatch_Activity.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Trust Factor Dispatch Activity is a rule that get's the motion of the device by such means as gyroscope 
 *  and orientation.
 */

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"
#import <CoreMotion/CoreMotion.h>

@interface TrustFactor_Dispatch_Motion : NSObject

// Get motion using gyroscope
+ (Sentegrity_TrustFactor_Output_Object *)grip:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)movement:(NSArray *)payload;

// Gets the device's orientation
+ (Sentegrity_TrustFactor_Output_Object *)orientation:(NSArray *)payload;

@end
