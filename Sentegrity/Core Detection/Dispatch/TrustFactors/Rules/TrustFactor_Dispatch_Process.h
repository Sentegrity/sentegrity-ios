//
//  TrustFactor_Dispatch_Process.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Process : NSObject 

/* Removed due to iOS 9
 
// 2 - Known Bad Processes
+ (Sentegrity_TrustFactor_Output_Object *)blacklisted:(NSArray *)payload;


// 11 - New Root Processes (gets all root processes: launched by launchd)
+ (Sentegrity_TrustFactor_Output_Object *)newRoot:(NSArray *)payload;

 */

@end
