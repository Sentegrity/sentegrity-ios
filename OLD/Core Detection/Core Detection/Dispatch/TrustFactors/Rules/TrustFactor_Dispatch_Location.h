//
//  TrustFactor_Dispatch_Location.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Location is a rule that uses the location of the device and the changes of the
 *  device to assess the trust score of the user and the device.
 */

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Location : NSObject

/* Old/Archived
// Determine if device is in a location of an allowed country
// + (Sentegrity_TrustFactor_Output_Object *)countryAllowed:(NSArray *)payload;
 */

// Determine location of device
+ (Sentegrity_TrustFactor_Output_Object *)locationGPS:(NSArray *)payload;

// Location approximation using brightness of screen, strength of cell tower, and magnetometer readings
+ (Sentegrity_TrustFactor_Output_Object *)locationApprox:(NSArray *)payload;

@end
