//
//  TrustFactor_Dispatch_Wifi.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Celluar.h"
@import CoreTelephony;

@implementation TrustFactor_Dispatch_Celluar

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)unknownCarrier:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    
    // Get the carrier speed
    
    NSString *carrierSpeed;
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    carrierSpeed = telephonyInfo.currentRadioAccessTechnology;
    
    
    // Get the carrier name
    
    NSString *carrierName;
    
    //Public API method that only returns SIM (home) carrier name
    //[info.subscriberCellularProvider.carrierName capitalizedString]
    
    //Private API to scrap the status bar and get real carrier
    NSString *statusBarString = [NSString stringWithFormat:@"%@ar", @"_statusB"];
    UIView* statusBar = [[UIApplication sharedApplication] valueForKey:statusBarString];
    
    UIView* statusBarForegroundView = nil;
    
    for (UIView* view in statusBar.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarForegroundView")])
        {
            statusBarForegroundView = view;
            break;
        }
    }
    
    UIView* statusBarServiceItem = nil;
    
    for (UIView* view in statusBarForegroundView.subviews)
    {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarServiceItemView")])
        {
            statusBarServiceItem = view;
            break;
        }
    }
    
    if (statusBarServiceItem)
    {
        id value = [statusBarServiceItem valueForKey:@"_serviceString"];
        
        if ([value isKindOfClass:[NSString class]])
        {
            carrierName = (NSString *)value;
        }
    }

    
    // Check for a connection
    if (carrierName == nil){
        
        //WiFi is enabled but there is no connection (don't penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
   
    [outputArray addObject:carrierName];

    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;

}






@end
