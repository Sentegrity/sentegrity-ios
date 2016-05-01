//
//  TrustFactor_Dispatch_Sentegrity.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Sentegrity is a tamper check rule.
 */
#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Sentegrity : NSObject 

// Tamper check
+ (Sentegrity_TrustFactor_Output_Object *)tamper:(NSArray *)payload;

@end
