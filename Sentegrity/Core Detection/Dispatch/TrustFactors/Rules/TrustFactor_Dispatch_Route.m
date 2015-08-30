//
//  TrustFactor_Dispatch_Route.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Route.h"
#import "Sentegrity_TrustFactor_Dataset_Netstat.h"

@implementation TrustFactor_Dispatch_Route


// 15
+ (Sentegrity_TrustFactor_Output_Object *)vpnUp:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Validate the payload
    if (![[Sentegrity_TrustFactor_Datasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get routes
    NSArray *routeArray = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getRouteInfo];

    
    // Check for routes
    if (!routeArray || routeArray == nil || routeArray.count < 1) {
        // Current route array is EMPTY
        
        // Set the DNE status code to UNAVAILABLE
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the routes
    @try {
        
        // Run through each route
        for (NSDictionary *route in routeArray) {
            
            // Get the current process name
            NSString *interfaceName = [route objectForKey:@"Interface"];
            
            // Iterate through VPN interfaces names and look for match
            for (NSString *vpnInterface in payload) {
                
                // Check if the interface is equal to a known VPN interface name
                if([interfaceName isEqualToString:vpnInterface]) {
                    
                    // make sure we don't add more than one instance of the VPN interface name
                    if (![outputArray containsObject:vpnInterface]){
                        NSString *vpnSignature = [vpnInterface stringByAppendingString:[route objectForKey:@"Gateway"]];
                        
                        // Add the interface of VPN to the output array
                        [outputArray addObject:vpnSignature];
                    }
                }
            }
            
            
        }
        
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}




// 16
+ (Sentegrity_TrustFactor_Output_Object *)noRoute:(NSArray *)payload {
    
   
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Get routes
    NSArray *routeArray = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getRouteInfo];
    bool defaultRoute = NO;
    
    // Check for routesy
    if (!routeArray || routeArray == nil || routeArray.count < 1) {
        // Current route array is EMPTY
        
        // Set the DNE status code to UNAVAILABLE
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the routes
    @try {
        
        // Run through each route
        for (NSDictionary *route in routeArray) {
            
            // Get the current process name
            NSNumber *isDefault = [route objectForKey:@"IsDefault"];
            if([isDefault intValue] == 1){
                defaultRoute = YES;
            }
            
        }
        
        // Did not find a default route
        if (defaultRoute==NO){
            [outputArray addObject:@"noRoute"];
        }
        
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}



@end
