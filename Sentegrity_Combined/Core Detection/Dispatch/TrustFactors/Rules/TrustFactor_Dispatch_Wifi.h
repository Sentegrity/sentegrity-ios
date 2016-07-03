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
+ (Sentegrity_TrustFactor_Output_Object *)consumerAP:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)hotspot:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)defaultSSID:(NSArray *)payload;

+ (Sentegrity_TrustFactor_Output_Object *)unencryptedWifi:(NSArray *)payload;

/* Old/Archived
//+ (Sentegrity_TrustFactor_Output_Object *)captivePortal:(NSArray *)payload;
 */

// Unknown SSID Check - Get the current AP SSID
+ (Sentegrity_TrustFactor_Output_Object *)SSIDBSSID:(NSArray *)payload;


@end
