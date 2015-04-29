//
//  TrustFactor_Dispatch_Sentegrity.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Sentegrity : Sentegrity_TrustFactor_Rule


// 6
+ (Sentegrity_TrustFactor_Output *)selfTamper:(NSArray *)selftamper;


// 21
+ (Sentegrity_TrustFactor_Output *)sentegrityVersion:(NSArray *)senversion;


@end
