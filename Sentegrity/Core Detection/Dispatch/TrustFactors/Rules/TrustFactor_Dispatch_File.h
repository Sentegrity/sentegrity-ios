//
//  TrustFactor_Dispatch_File.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_File : NSObject 

// 1 - knownBad Files Check
+ (Sentegrity_TrustFactor_Output_Object *)blacklisted:(NSArray *)payload;

// 10 - fileSize check
+ (Sentegrity_TrustFactor_Output_Object *)sizeChange:(NSArray *)payload;

@end
