//
//  TrustFactor_Dispatch_Cellular.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "TrustFactor_Dispatch_Celluar.h"

@implementation TrustFactor_Dispatch_Celluar

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)cellConnectionChange:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Get the current list of user apps
    NSString *carrierConnectionInfo = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getCarrierConnectionInfo];
    
    // Check the array
    if (!carrierConnectionInfo || carrierConnectionInfo == nil || carrierConnectionInfo.length < 1) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }

    // Add carrier connection info to the output array
    [outputArray addObject:carrierConnectionInfo];

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// USES PRIVATE API
+ (Sentegrity_TrustFactor_Output_Object *)airplaneMode:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Get the status Bar
    NSNumber *enabled = [[Sentegrity_TrustFactor_Datasets sharedDatasets] isAirplaneMode];
    
    // Check the array
    if (!enabled || enabled == nil) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Is airplane enabled?
    if(enabled.intValue == 1){
        [outputArray addObject:@"airplane"];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end
