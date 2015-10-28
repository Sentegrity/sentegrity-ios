//
//  TrustFactor_Dispatch_Wifi.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"



@interface TrustFactor_Dispatch_Celluar : NSObject 

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)cellConnectionChange:(NSArray *)payload;

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)airplaneMode:(NSArray *)payload;



@end
