//
//  TrustFactor_Dispatch_Process.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Application : NSObject

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)installedApp:(NSArray *)payload;


/* Removed due to iOS 9
 
// 4 - Bad URL Handler Checks (cydia://, snoopi-it://, etc)
+ (Sentegrity_TrustFactor_Output_Object *)uriHandler:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)runningApp:(NSArray *)payload;

 */

@end
