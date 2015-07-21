//
//  TrustFactor_Dispatch_Location.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Location.h"
@import CoreLocation;

@implementation TrustFactor_Dispatch_Location



// 26
+ (Sentegrity_TrustFactor_Output_Object *)allowed:(NSArray *)payload {
    
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
    
    // Get the current location
    CLLocation *currentLocation = [self locationInfo];
    
    // Check the location, if its empty check DNE and set it
    if (!currentLocation || currentLocation == nil) {
        // Current Processes array is EMPTY
        if([self locationDNEStatus] != 0)
        {
            // Set the DNE status code to what was previously determined
            [trustFactorOutputObject setStatusCode:[self locationDNEStatus]];
        }else{
            // We don't know what happened but its nil so set to error
            [trustFactorOutputObject setStatusCode:DNEStatus_error];
        }
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
   
    NSString *lng = [NSString stringWithFormat:@"%.*f", 2,currentLocation.coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%.*f", 2, currentLocation.coordinate.latitude];
    
    
    [outputArray addObject:[lng stringByAppendingString:lat]];
    
    //TODO: compare to payload
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;

}



// 31
+ (Sentegrity_TrustFactor_Output_Object *)unknown:(NSArray *)payload {
    
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
    
    // Get the current location
    CLLocation *currentLocation = [self locationInfo];
    
    // Check the location, if its empty check DNE and set it
    if (!currentLocation || currentLocation == nil) {
        // Current Processes array is EMPTY
        if([self locationDNEStatus] != 0)
        {
            // Set the DNE status code to what was previously determined
            [trustFactorOutputObject setStatusCode:[self locationDNEStatus]];
        }else{
            // We don't know what happened but its nil so set to error
            [trustFactorOutputObject setStatusCode:DNEStatus_error];
        }
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    NSString *lng = [NSString stringWithFormat:@"%.*f", [[[payload objectAtIndex:0] objectForKey:@"rounding"] integerValue],currentLocation.coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%.*f", [[[payload objectAtIndex:0] objectForKey:@"rounding"] integerValue], currentLocation.coordinate.latitude];
    
    
    [outputArray addObject:[lng stringByAppendingString:lat]];
    
    //TODO: convert to int and round
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}




@end
