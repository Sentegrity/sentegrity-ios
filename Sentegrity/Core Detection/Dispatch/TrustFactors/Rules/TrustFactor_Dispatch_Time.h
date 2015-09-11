//
//  TrustFactor_Dispatch_Time.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Time : NSObject

// Not implemented in default policy
//+ (Sentegrity_TrustFactor_Output_Object *)allowedAccessTime:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)timeHour:(NSArray *)payload;


+ (Sentegrity_TrustFactor_Output_Object *)timeDay:(NSArray *)payload;

@end





