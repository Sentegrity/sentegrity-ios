//
//  TrustFactor_Dispatch_Location.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"


@interface TrustFactor_Dispatch_Location : NSObject


// 26
+ (Sentegrity_TrustFactor_Output_Object *)countryAllowed:(NSArray *)payload;

// 31
+ (Sentegrity_TrustFactor_Output_Object *)locationGPS:(NSArray *)payload;

// 31
+ (Sentegrity_TrustFactor_Output_Object *)locationApprox:(NSArray *)payload;

@end
