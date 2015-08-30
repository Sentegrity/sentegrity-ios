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

@interface TrustFactor_Dispatch_Activity : NSObject 

+ (Sentegrity_TrustFactor_Output_Object *)previous:(NSArray *)payload;


@end
