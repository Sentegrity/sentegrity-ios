//
//  TrustFactor_Dispatch_Wifi.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Wifi.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation TrustFactor_Dispatch_Wifi

// 17 - Determine if the connected access point is a SOHO (Small Office/Home Offic) network
+ (Sentegrity_TrustFactor_Output_Object *)apSoho:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![self validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the current Access Point BSSID
    NSString *bssid = nil;
    
    // Get the supported network interfaces
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    
    // Check if the array is valid
    if (!ifs || ifs == nil) {
        // Unable to use this api on this device
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_unsupported];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through the interfaces
    for (NSString *ifnam in ifs) {
        // Get the current interface object's network information
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);

        // Check if the interface contains the BSSID key
        if (info[@"BSSID"]) {
            
            // Set the BSSID variable
            bssid = info[@"BSSID"];
        }
    }
    
    // Validate the BSSID
    if (bssid != nil && bssid.length > 0) {
        // Run through the payload and compare to the BSSID
        for (NSString *oui in payload) {
            // Check if the bssid matches one of the OUI's in the payload
            if ([bssid rangeOfString:oui options:NSCaseInsensitiveSearch].location != NSNotFound) {
                
                // Add the current bssid to the list
                [outputArray addObject:bssid];
                
                // Break from the for loop
                break;
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;

}

// 18 - Unencrypted AP Check - Not available
+ (Sentegrity_TrustFactor_Output_Object *)unencrypted:(NSArray *)payload {
    
    return 0;
}

// 19 - Unknown SSID Check - Get the current AP SSID
+ (Sentegrity_TrustFactor_Output_Object *)unknownSSID:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Get the current Access Point
    NSString *ssid = nil;
    
    // Get an array of network interfaces
    CFArrayRef supportedInterfacesList = CNCopySupportedInterfaces();
    
    // Check if the array is valid
    if (!supportedInterfacesList || supportedInterfacesList == nil) {
        // Unable to use this api on this device
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_unsupported];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get the network info from the interfaces
    CFDictionaryRef currentNetworkInfoDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(supportedInterfacesList, 0));
    
    // Create an ssidList dictionary
    NSDictionary *ssidList = (__bridge NSDictionary*)currentNetworkInfoDict;
    
    // Check if the SSID was obtained
    if ([ssidList objectForKey:@"SSID"]) {
        // Set the SSID
        ssid = [ssidList valueForKey:@"SSID"];
    }
    
    // Validate the SSID
    if (ssid != nil && ssid.length > 0) {
        
        // Add the ssid to the output
        [outputArray addObject:ssid];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;

}

// 27 - Known BSSID - Get the current BSSID of the AP
+ (Sentegrity_TrustFactor_Output_Object *)knownBSSID:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![self validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the current Access Point BSSID
    NSString *bssid = nil;
    
    // Get the supported network interfaces
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    
    // Check if the array is valid
    if (!ifs || ifs == nil) {
        // Unable to use this api on this device
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_unsupported];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through the interfaces
    for (NSString *ifnam in ifs) {
        // Get the current interface object's network information
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        // Check if the interface contains the BSSID key
        if (info[@"BSSID"]) {
            
            // Set the BSSID variable
            bssid = info[@"BSSID"];
        }
    }
    
    // Validate the BSSID
    if (bssid != nil && bssid.length > 0) {
        
        // Add the current bssid to the list
        [outputArray addObject:bssid];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

@end
