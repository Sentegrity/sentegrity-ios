//
//  TrustFactor_Dispatch_Wifi.h
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"


@interface TrustFactor_Dispatch_Wifi : NSObject


// 17 - Determine if the connected access point is a SOHO (Small Office/Home Offic) network
+ (Sentegrity_TrustFactor_Output_Object *)highRiskAP:(NSArray *)payload;

// 19 - TODO: This ability is not available on iOS outside of private API's
+ (Sentegrity_TrustFactor_Output_Object *)captivePortal:(NSArray *)payload;

// 19 - Unknown SSID Check - Get the current AP SSID
+ (Sentegrity_TrustFactor_Output_Object *)SSID:(NSArray *)payload;

// 27 - Known BSSID - Get the current BSSID of the AP
+ (Sentegrity_TrustFactor_Output_Object *)BSSID:(NSArray *)payload;



@end
