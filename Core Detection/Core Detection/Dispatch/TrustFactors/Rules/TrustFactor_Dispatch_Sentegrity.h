//
//  TrustFactor_Dispatch_Sentegrity.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"


@interface TrustFactor_Dispatch_Sentegrity : NSObject 

// 6
+ (Sentegrity_TrustFactor_Output_Object *)tamper:(NSArray *)payload;

@end
