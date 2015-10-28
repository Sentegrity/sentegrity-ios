//
//  Sentegrity_TrustFactor_Dataset_Cell.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// System Frameworks
#import <Foundation/Foundation.h>

// Import Constants
#import "Sentegrity_Constants.h"

// Headers

@interface Cell_Info : NSObject

// Check which carrier we have
+ (NSString *) getCarrierInfo;

// Check how strong the signal is
+ (NSNumber *) getSignalBars;

// Check the strength of the signal
+ (NSNumber *) getSignalRaw;

// Check if we are in airplane mode
+ (NSNumber *) isAirplane;


@end

