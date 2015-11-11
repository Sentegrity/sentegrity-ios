//
//  TrustFactor_Dispatch_Sandbox.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Sandbox : NSObject 

// Sandbox Verification
+ (Sentegrity_TrustFactor_Output_Object *)integrity:(NSArray *)payload;

@end
