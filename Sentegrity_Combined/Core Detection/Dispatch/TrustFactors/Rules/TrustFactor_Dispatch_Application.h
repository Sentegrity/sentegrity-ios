//
//  TrustFactor_Dispatch_Application.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Application is a rule that that looks for installed apps on the user's device to
 *  determine which ones are trusted as opposed to ones that are high risk.
 */

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Application : NSObject

// USES PRIVATE API
//+ (Sentegrity_TrustFactor_Output_Object *)installedApp:(NSArray *)payload;

/* Removed due to iOS 9
 
// 4 - Bad URL Handler Checks (cydia://, snoopi-it://, etc)
+ (Sentegrity_TrustFactor_Output_Object *)uriHandler:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)runningApp:(NSArray *)payload;

 */

@end
