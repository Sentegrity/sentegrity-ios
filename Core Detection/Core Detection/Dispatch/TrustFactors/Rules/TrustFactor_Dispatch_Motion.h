//
//  TrustFactor_Dispatch_Activity.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"
#import <CoreMotion/CoreMotion.h>

@interface TrustFactor_Dispatch_Motion : NSObject

+ (Sentegrity_TrustFactor_Output_Object *)grip:(NSArray *)payload;

//+ (Sentegrity_TrustFactor_Output_Object *)moving:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)orientation:(NSArray *)payload;

@end
