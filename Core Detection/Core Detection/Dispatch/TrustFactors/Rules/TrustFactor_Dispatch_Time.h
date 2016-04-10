//
//  TrustFactor_Dispatch_Time.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Time : NSObject

// Not implemented in default policy
+ (Sentegrity_TrustFactor_Output_Object *)accessTimeDay:(NSArray *)payload;


+ (Sentegrity_TrustFactor_Output_Object *)accessTimeHour:(NSArray *)payload;


@end





