//
//  TrustFactor_Dispatch_Process.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Process.h"
#import "ActiveProcess.h"

@implementation TrustFactor_Dispatch_Process

// Implementations

// Known Bad Files
+ (Sentegrity_TrustFactor_Output_Object *)blacklisted:(NSArray *)payload {
    
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[Sentegrity_TrustFactor_Datasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Current process name
    NSString *procName;
    
    // Get the current processes
    NSArray *currentProcesses = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getProcessInfo];
    
    // Check the array
    if (!currentProcesses || currentProcesses == nil || currentProcesses.count < 1) {
        // Current Processes array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the process information
    for (ActiveProcess *processData in currentProcesses) {
        
        
        // Iterate through payload names and look for matching processes
        for (NSString *badProcName in payload) {
            
            // Check if the process name is equal to the current process being viewed
            
            // Does the badProcName contain a wildcard?
            if([badProcName containsString:@"*"]){
                
                NSString *trimmedString = [[badProcName componentsSeparatedByString:@"*"] objectAtIndex:0];
                
                // Has wildcard, only check for prefix
                if([processData.name hasPrefix:trimmedString]) {
                    
                    // make sure we don't add more than one instance of the proc
                    if (![outputArray containsObject:processData.name]){
                        
                        // Add the process to the output array
                        [outputArray addObject:processData.name];
                    }
                }
                
            }
            else{ // Does not contain wildecard
                
                if([processData.name isEqualToString:badProcName]) {
                    
                    // make sure we don't add more than one instance of the proc
                    if (![outputArray containsObject:processData.name]){
                        
                        // Add the process to the output array
                        [outputArray addObject:processData.name];
                    }
                }

                
            }
            
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

// Get all root processes (parent pid of 1 or less)
+ (Sentegrity_TrustFactor_Output_Object *)newRoot:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Current process UID
    int UID;
    
    // Get the current processes
    NSArray *currentProcesses = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getProcessInfo];
    
    // Check the array
    if (!currentProcesses || currentProcesses == nil || currentProcesses.count < 1) {
        // Current Processes array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the process information
    for (ActiveProcess *processData in currentProcesses) {
        

        // Check if the process parent id is 1 or less
        if ([processData.uid intValue] <= 0) {
            // Root process
            
            
            // make sure we don't add more than one instance of the proc
            if (![outputArray containsObject:processData.name]){
                
                // Add the process to the output array
                [outputArray addObject:processData.name];
            }
            
        }

    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end
