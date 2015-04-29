//
//  TrustFactor_Dispatch_Wifi.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Wifi : Sentegrity_TrustFactor_Rule


// 17
+ (Sentegrity_TrustFactor_Output *)apSoho:(NSArray *)soho;

// 18
+ (Sentegrity_TrustFactor_Output *)apHotspotter:(NSArray *)hotspotter;

// 19
+ (Sentegrity_TrustFactor_Output *)wifiEncType:(NSArray *)enctype;

// 27
+ (Sentegrity_TrustFactor_Output *)ssidAllowed:(NSArray *)ssidallowed;


@end
