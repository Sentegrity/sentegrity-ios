//
//  TrustFactor_Dispatch_Activity.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

#import <CoreMotion/CoreMotion.h>

@interface TrustFactor_Dispatch_Motion : Sentegrity_TrustFactor_Rule


+ (Sentegrity_TrustFactor_Output_Object *)unknown:(NSArray *)payload;

@end