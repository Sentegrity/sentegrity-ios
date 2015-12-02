//
//  TrustFactor_Dispatch_Route.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Dispatch Route is a rule that checks for a VPN and routes.
 */

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Route : NSObject 

// Check if using a VPN
+ (Sentegrity_TrustFactor_Output_Object *)vpnUp:(NSArray *)payload;

// No route
+ (Sentegrity_TrustFactor_Output_Object *)noRoute:(NSArray *)payload;

@end
