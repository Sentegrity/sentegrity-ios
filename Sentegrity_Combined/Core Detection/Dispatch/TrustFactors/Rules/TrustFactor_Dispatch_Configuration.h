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

// Seperate TF for user because it only returns when pw IS set
+ (Sentegrity_TrustFactor_Output_Object *)passcodeSetUser:(NSArray *)payload;

// Seperate TF for system because it only returns when pw NOT set
+ (Sentegrity_TrustFactor_Output_Object *)passcodeSetSystem:(NSArray *)payload;

@end
