//
//  TrustFactor_Dispatch_Wifi.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"




@interface TrustFactor_Dispatch_Celluar : Sentegrity_TrustFactor_Rule

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)unknownCarrier:(NSArray *)payload;



@end
