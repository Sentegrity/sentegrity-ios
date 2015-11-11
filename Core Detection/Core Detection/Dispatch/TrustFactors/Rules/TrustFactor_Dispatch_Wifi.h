//
//  TrustFactor_Dispatch_Wifi.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface TrustFactor_Dispatch_Wifi : NSObject

// Determine if the connected access point is a SOHO (Small Office/Home Offic) network
+ (Sentegrity_TrustFactor_Output_Object *)highRiskAP:(NSArray *)payload;

// TODO: This ability is not available on iOS outside of private API's
//+ (Sentegrity_TrustFactor_Output_Object *)captivePortal:(NSArray *)payload;

// Unknown SSID Check - Get the current AP SSID
+ (Sentegrity_TrustFactor_Output_Object *)SSID:(NSArray *)payload;

// Known BSSID - Get the current BSSID of the AP
+ (Sentegrity_TrustFactor_Output_Object *)BSSID:(NSArray *)payload;

@end
