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
+ (NSNumber *) movement;

// Orientation function
+ (NSString *) orientation;

@end

