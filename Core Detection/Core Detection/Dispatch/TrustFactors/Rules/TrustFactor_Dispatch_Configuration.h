//
//  TrustFactor_Dispatch_Configuration.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Configuration is a simple rule that checks for basic information such as
 *  if the user uses a passcode or iCloud backup capability.
 */

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Configuration : NSObject 

// Check if iCloud is enabled
+ (Sentegrity_TrustFactor_Output_Object *)backupEnabled:(NSArray *)payload;

// Does the user use a passcode?
+ (Sentegrity_TrustFactor_Output_Object *)passcodeSet:(NSArray *)payload;

@end
