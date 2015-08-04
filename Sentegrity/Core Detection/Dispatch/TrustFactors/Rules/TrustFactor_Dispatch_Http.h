//
//  TrustFactor_Dispatch_Http.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Http : Sentegrity_TrustFactor_Rule

// 4 - Bad URL Handler Checks (cydia://, snoopi-it://, etc)
+ (Sentegrity_TrustFactor_Output_Object *)maliciousApps:(NSArray *)payload;

@end
