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
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Placemark
    CLPlacemark *currentPlacemark;
    
    // Attempt to get the current placemark
    currentPlacemark = [self placemarkInfo];
    
    // Check if error was already determined when placemark was started
    if([self placemarkDNEStatus] != 0){
        
        // Set the DNE status code for the TF to what was previously determined by placemark
        [trustFactorOutputObject setStatusCode:[self placemarkDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    } else {
        
        // No known errors occured previously, try to get dataset and check our object
        
        // Check the placemark, if its empty set DNE
        if (!currentPlacemark || currentPlacemark == nil) {
            
            [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
            // Return with the blank output object
            return trustFactorOutputObject;
        }
        
    }
    
    NSString *countryCode = currentPlacemark.ISOcountryCode;
    
    // Used to increase complexity of policy violation hashes
    NSString *assertion = currentPlacemark.country;
    
    BOOL match=NO;
    
    if(countryCode != nil && assertion != nil){
        
        // Iterate through payload names and look for matching processes
        for (NSString *allowedCountryCode in payload) {
            
            // Check if the country code matches one in the payload
            if([countryCode isEqualToString:allowedCountryCode]) {
                match=YES;
                break;
            }
        }
        
        // Did not match any of the payloads
        if(!match){
            // Add the country to the output array (add the asseriton which is the full country name, not just the code)
            [outputArray addObject:assertion];
        }
        
    }else{
        
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }

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
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Location
    CLLocation *currentLocation;
    
    // Attempt to get the current location
    currentLocation = [self locationInfo];
    
     // Check if error was already determined when placemark was started
    if([self locationDNEStatus] != 0){
        
        // Set the DNE status code for the TF to what was previously determined by location services
        [trustFactorOutputObject setStatusCode:[self locationDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    } else {
        // No known errors occured previously, check our object
        
        // Check the location, if its empty  set DNE
        if (!currentLocation || currentLocation == nil) {
            
            [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
            // Return with the blank output object
            return trustFactorOutputObject;
        }
        
    }
    
    // Rounding from policy
    int decimalPlaces = -1;
    decimalPlaces = [[[payload objectAtIndex:0] objectForKey:@"rounding"] intValue];
    
    // Validate the payload
    if (decimalPlaces < 0) {
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Rounded location
    NSString *roundedLocation = [NSString stringWithFormat:@"%.*f,%.*f",decimalPlaces,currentLocation.coordinate.longitude,decimalPlaces,currentLocation.coordinate.latitude];
  

    [outputArray addObject:roundedLocation];
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}




@end
