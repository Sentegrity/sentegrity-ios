//
//  TrustFactor_Dispatch_Cellular.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Cellular is a rule that gets connection information in addition to checking if 
 *  the user's device is in airplane mode.
 */

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Celluar : NSObject 

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)cellConnectionChange:(NSArray *)payload;

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)airplaneMode:(NSArray *)payload;

@end
