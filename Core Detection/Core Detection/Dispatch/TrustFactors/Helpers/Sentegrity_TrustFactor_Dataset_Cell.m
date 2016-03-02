//
//  Sentegrity_TrustFactor_Dataset_Cell.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Import header file
#import "Sentegrity_TrustFactor_Dataset_Cell.h"

// System Frameworks
#import <UIKit/UIKit.h>
@import CoreTelephony;


@implementation Cell_Info

static UIView* statusBarForegroundView;


// Check for signal strength
+(NSNumber*)getSignalRaw {
    
    NSDictionary* status = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getStatusBar];
    return [status valueForKey:@"cellSignal"];
}

// Get WiFi IP Address
+ (NSString *)getCarrierName {
    
    NSDictionary* status = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getStatusBar];
    return [status valueForKey:@"cellServiceString"];
}

// Get WiFi IP Address
+ (NSString *)getCarrierSpeed {
    
    NSString *carrierSpeed;
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    carrierSpeed = telephonyInfo.currentRadioAccessTechnology;
    
    return carrierSpeed;
}


// Check if we are in airplane mode
+(NSNumber *)isAirplane{

    NSDictionary* status = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getStatusBar];
    return [status valueForKey:@"isAirplaneMode"];
}

@end