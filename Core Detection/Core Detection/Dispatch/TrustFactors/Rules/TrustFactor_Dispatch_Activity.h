//
//  TrustFactor_Dispatch_Activity.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Activity is a rule that gets the user's activities whether they are moving,
 *  stationary, or in a vehicle.
 */

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"
#import <CoreMotion/CoreMotion.h>

@interface TrustFactor_Dispatch_Activity : NSObject 

// Get the user's previous activities as in if they are moving, stationary, etc.
+ (Sentegrity_TrustFactor_Output_Object *)previous:(NSArray *)payload;


@end
