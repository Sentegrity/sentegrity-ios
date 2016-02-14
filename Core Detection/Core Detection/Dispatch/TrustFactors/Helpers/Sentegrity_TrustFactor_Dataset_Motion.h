//
//  Sentegrity_TrustFactor_Dataset_Motion.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// System Frameworks
#import <Foundation/Foundation.h>

// Import Constants
#import "Sentegrity_Constants.h"

// Headers
#import "Sentegrity_TrustFactor_Datasets.h"

// Location Info
@interface Motion_Info : NSObject

// Moving function
+ (NSNumber *) gripMovement;

// Orientation function
+ (NSString *) orientation;

// Total movement of user and device
+ (NSString *) userMovement;



@end

