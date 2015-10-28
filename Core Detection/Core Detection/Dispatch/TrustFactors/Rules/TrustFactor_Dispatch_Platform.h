//
//  TrustFactor_Dispatch_Platform.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Platform : NSObject 

// 23
+ (Sentegrity_TrustFactor_Output_Object *)vulnerableVersion:(NSArray *)payload;

// 28
+ (Sentegrity_TrustFactor_Output_Object *)versionAllowed:(NSArray *)payload;

// 38
+ (Sentegrity_TrustFactor_Output_Object *)shortUptime:(NSArray *)payload;



@end
