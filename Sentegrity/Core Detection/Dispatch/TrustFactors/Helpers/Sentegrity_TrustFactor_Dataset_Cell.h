//
//  Sentegrity_TrustFactor_Dataset_Location.h
//  Sentegrity
//
//  Created by Jason Sinchak on 7/19/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// System Frameworks
#import <Foundation/Foundation.h>

// Import Constants
#import "Sentegrity_Constants.h"

// Headers



@interface Cell_Info : NSObject


+ (NSString *) getCarrierInfo;

+ (NSNumber *) getSignal;

+ (NSNumber *) isAirplane;


@end

