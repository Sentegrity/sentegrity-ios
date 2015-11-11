//
//  TrustFactor_Dispatch_File.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch File is a rule that checks for bad files that may have been added to the device
 *  of the user in addition to size changes that are out of the ordinary
 */
#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_File : NSObject 

// Check for bad files
+ (Sentegrity_TrustFactor_Output_Object *)blacklisted:(NSArray *)payload;

// File size change check
+ (Sentegrity_TrustFactor_Output_Object *)sizeChange:(NSArray *)payload;

@end
