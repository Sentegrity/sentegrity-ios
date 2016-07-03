//
//  Sentegrity_TrustFactor_Dataset_Location.h
//  Sentegrity
//
//  Created by Jason Sinchak on 7/19/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// System Frameworks
#import <Foundation/Foundation.h>

// Import Constants
#import "Sentegrity_Constants.h"

// Headers
#import <arpa/inet.h>
#import "Sentegrity_TrustFactor_Datasets.h"
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <net/if.h>

@interface Wifi_Info : NSObject

// Get wifi information
+ (NSDictionary*)getWifi;

// Signal information
+ (NSNumber *) getSignal;

// Check if wifi enables
+ (NSNumber *)isWiFiEnabled;

// Check if tethering
+ (NSNumber *)isTethering;

// check if connected to unencrypted wifi
+ (NSArray *) getWifiEncryption;

@end

