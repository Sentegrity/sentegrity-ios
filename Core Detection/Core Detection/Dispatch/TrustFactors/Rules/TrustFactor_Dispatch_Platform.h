//
//  TrustFactor_Dispatch_Platform.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Platform is rule that checks for bad/allowed versions as well as up time for
 *  TrustFactor calculations.
 */
#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Platform : NSObject 

// Vunerable/bad version
+ (Sentegrity_TrustFactor_Output_Object *)vulnerableVersion:(NSArray *)payload;

// Allowed versions
+ (Sentegrity_TrustFactor_Output_Object *)versionAllowed:(NSArray *)payload;

// Short up time
+ (Sentegrity_TrustFactor_Output_Object *)shortUptime:(NSArray *)payload;



@end
