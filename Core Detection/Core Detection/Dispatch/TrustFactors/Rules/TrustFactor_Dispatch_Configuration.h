//
//  TrustFactor_Dispatch_Platform.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Configuration : NSObject 

// 38
+ (Sentegrity_TrustFactor_Output_Object *)backupEnabled:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)passcodeSet:(NSArray *)payload;

@end
