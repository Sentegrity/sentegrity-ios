//
//  TrustFactor_Dispatch_Route.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Route : Sentegrity_TrustFactor_Rule


// 15
+ (Sentegrity_TrustFactor_Output_Object *)unknownVpnUp:(NSArray *)payload;

// 16
+ (Sentegrity_TrustFactor_Output_Object *)noRoute:(NSArray *)payload;

@end
