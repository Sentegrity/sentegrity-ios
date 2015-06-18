//
//  TrustFactor_Dispatch_Wifi.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

@interface TrustFactor_Dispatch_Wifi : Sentegrity_TrustFactor_Rule


// 17 - Determine if the connected access point is a SOHO (Small Office/Home Offic) network
+ (Sentegrity_TrustFactor_Output_Object *)apSoho:(NSArray *)payload;

// 19 - TODO: This ability is not available on iOS outside of private API's
+ (Sentegrity_TrustFactor_Output_Object *)unencrypted:(NSArray *)payload;

// 19 - Unknown SSID Check - Get the current AP SSID
+ (Sentegrity_TrustFactor_Output_Object *)unknownSSID:(NSArray *)payload;

// 27 - Known BSSID - Get the current BSSID of the AP
+ (Sentegrity_TrustFactor_Output_Object *)knownBSSID:(NSArray *)payload;


@end
