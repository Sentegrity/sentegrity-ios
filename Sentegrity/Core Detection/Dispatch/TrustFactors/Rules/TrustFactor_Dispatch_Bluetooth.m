//
//  TrustFactor_Dispatch_Bluetooth.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Bluetooth.h"

@implementation TrustFactor_Dispatch_Bluetooth

+ (Sentegrity_TrustFactor_Output_Object *)connectedClassicDevice:(NSArray *)payload {
    
    return 0;
}

+ (Sentegrity_TrustFactor_Output_Object *)discoveredClassicDevice:(NSArray *)payload {
    
    return 0;
}
// 33
+ (Sentegrity_TrustFactor_Output_Object *)discoveredBLEDevice:(NSArray *)payload {

    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    
    // Check if error was determined by bluetooth scanner in app delegate
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  discoveredBLESDNEStatus] != 0 ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  discoveredBLESDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }

    
    // Try to get current bluetooth devices
    NSArray *bluetoothDevices = [[Sentegrity_TrustFactor_Datasets sharedDatasets]  getDiscoveredBLEInfo];
    
    
    // Check if error was determined after call to dataset helper (e.g., timer expired)
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  discoveredBLESDNEStatus] != 0 ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  discoveredBLESDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }

    
    
    // Check the array
    if (!bluetoothDevices || bluetoothDevices == nil || bluetoothDevices.count < 1) {
        // Current Processes array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all found devices information
    for (NSString *deviceUUID in bluetoothDevices) {
        
        [outputArray addObject:deviceUUID];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    

    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



@end
