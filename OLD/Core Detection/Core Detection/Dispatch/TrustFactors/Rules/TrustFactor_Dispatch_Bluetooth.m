//
//  TrustFactor_Dispatch_Bluetooth.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "TrustFactor_Dispatch_Bluetooth.h"

// Private APIs
//#import "BluetoothManager.h"
//#import "BluetoothDevice.h"

@implementation TrustFactor_Dispatch_Bluetooth

// Check which classic bluetooth devices are connected
+ (Sentegrity_TrustFactor_Output_Object *)connectedClassicDevice:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];

    
    // Check if error was determined by BT callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedClassicDNEStatus] != DNEStatus_ok && [[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedClassicDNEStatus] != DNEStatus_expired ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedClassicDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Try to get current bluetooth devices
    NSArray *bluetoothDevices = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getClassicBTInfo];
    
    // Check if error was determined after call to dataset helper (e.g., timer expired)
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedClassicDNEStatus] != DNEStatus_ok ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedClassicDNEStatus]];
        
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
    for (NSString *mac in bluetoothDevices) {
        
        [outputArray addObject:mac];
    }

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

// Check connected BLE devices
+ (Sentegrity_TrustFactor_Output_Object *)connectedBLEDevice:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Check if error was determined by BT callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedBLESDNEStatus] != DNEStatus_ok && [[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedBLESDNEStatus] != DNEStatus_expired ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedBLESDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Try to get current bluetooth devices
    NSArray *bluetoothDevices = [[Sentegrity_TrustFactor_Datasets sharedDatasets]  getConnectedBLEInfo];
    
    // Check if error was determined after call to dataset helper (e.g., timer expired)
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedBLESDNEStatus] != DNEStatus_ok){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  connectedBLESDNEStatus]];
        
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
    
    
    // Modified to only use the first one as this is likely the fastest responder all the time
    //[outputArray addObject:[bluetoothDevices objectAtIndex:0]];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}



// Check which BLE devices get discovered
+ (Sentegrity_TrustFactor_Output_Object *)discoveredBLEDevice:(NSArray *)payload {

    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Check if error was determined by BT callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  discoveredBLESDNEStatus] != DNEStatus_ok && [[Sentegrity_TrustFactor_Datasets sharedDatasets]  discoveredBLESDNEStatus] != DNEStatus_expired ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  discoveredBLESDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }

    // Try to get current bluetooth devices
    NSArray *bluetoothDevices = [[Sentegrity_TrustFactor_Datasets sharedDatasets]  getDiscoveredBLEInfo];
    
    // Check if error was determined after call to dataset helper (e.g., timer expired)
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  discoveredBLESDNEStatus] != DNEStatus_ok){
        
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

    
    // Modified to only use the first one as this is likely the fastest responder all the time
    //[outputArray addObject:[bluetoothDevices objectAtIndex:0]];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

@end
