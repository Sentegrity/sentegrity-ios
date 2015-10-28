//
//  TrustFactor_Dispatch_Sandbox.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Sandbox : NSObject 

// 8 - Sandbox Verification
+ (Sentegrity_TrustFactor_Output_Object *)integrity:(NSArray *)payload;

@end
