//  TrustFactor_Dispatch_Configuration.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "TrustFactor_Dispatch_Configuration.h"
#import <UIKit/UIKit.h>


@implementation TrustFactor_Dispatch_Configuration


// Is iCloud enabled?
+ (Sentegrity_TrustFactor_Output_Object *)backupEnabled:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[Sentegrity_TrustFactor_Datasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    
    // Is iCloud enabled
    if([[NSFileManager defaultManager] ubiquityIdentityToken] != nil){
        [outputArray addObject:@"backupEnabled"];
    }
    
    NSDictionary* status = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getStatusBar];
    NSNumber* isSyncing = [status valueForKey:@"isBackingUp"];
    
    
    if([isSyncing intValue]==1){
        [outputArray addObject:@"backupInProgress"];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// Seperate TF for system because it only returns when pw NOT set
+ (Sentegrity_TrustFactor_Output_Object *)passcodeSetSystem:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Attempt to get motion data
    NSNumber *hasPassword = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getPassword];
    
    if (!hasPassword || hasPassword == nil ) {
        
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Set status code to unavailable
    if([hasPassword integerValue] == 2){
        [outputArray addObject:@"passcodeNotSet"];
        
    }
    else if([hasPassword integerValue] == 1){
        // do nothing
    }
    else{
        
        // Set status code to unavailable
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Set the trustfactor output to the output array (regardless if empty)
        [trustFactorOutputObject setOutput:outputArray];
        
        // Return the trustfactor output object
        return trustFactorOutputObject;
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}


// Seperate TF for user because it only returns when pw IS set
+ (Sentegrity_TrustFactor_Output_Object *)passcodeSetUser:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Attempt to get motion data
    NSNumber *hasPassword = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getPassword];
    
    if (!hasPassword || hasPassword == nil ) {
        // Set status code to unavailable
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Set the trustfactor output to the output array (regardless if empty)
        [trustFactorOutputObject setOutput:outputArray];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Set status code to unavailable
    if([hasPassword integerValue] == 2){
        // do nothing
        
    }
    else if([hasPassword integerValue] == 1){
        [outputArray addObject:@"passcodeSet"];
    }
    else{
        
        // Set status code to unavailable
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Set the trustfactor output to the output array (regardless if empty)
        [trustFactorOutputObject setOutput:outputArray];
        
        // Return the trustfactor output object
        return trustFactorOutputObject;
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



@end
