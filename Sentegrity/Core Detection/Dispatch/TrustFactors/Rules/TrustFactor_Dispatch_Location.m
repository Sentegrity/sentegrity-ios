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
    if (![[Sentegrity_TrustFactor_Datasets sharedDatasets] validatePayload:payload]) {
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
    currentPlacemark = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getPlacemarkInfo];
    
    // Check if error was already determined when placemark was started
    if([[Sentegrity_TrustFactor_Datasets sharedDatasets]  placemarkDNEStatus] != 0){
        
        // Set the DNE status code for the TF to what was previously determined by placemark
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  placemarkDNEStatus]];
        
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
+ (Sentegrity_TrustFactor_Output_Object *)unknownGPS:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[Sentegrity_TrustFactor_Datasets sharedDatasets]  validatePayload:payload]) {
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
    
    // Check if error was determined by location callback in app delegate
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  locationDNEStatus] != 0 ){
        
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  locationDNEStatus]];
        
        if([[Sentegrity_TrustFactor_Datasets sharedDatasets] locationDNEStatus] == DNEStatus_unauthorized){
            
            // Manually call unknown geo first
            
            // then return
            return trustFactorOutputObject;
            
            
        }else{
        
        // Some other error happened
        // Return with the blank output object
        return trustFactorOutputObject;
            
        }

    }
    
    
    // Attempt to get the current location
    currentLocation = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getLocationInfo];
    
     // Check if error was determined after call to dataset helper
    if([[Sentegrity_TrustFactor_Datasets sharedDatasets]  locationDNEStatus] != 0){
        
        // Set the DNE status code for the TF to what was previously determined by location services
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  locationDNEStatus]];
        
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
    int decimalPlaces = [[[payload objectAtIndex:0] objectForKey:@"rounding"] intValue];
    
    // Rounded location
    NSString *roundedLocation = [NSString stringWithFormat:@"LO_%.*f_LT_%.*f",decimalPlaces,currentLocation.coordinate.longitude,decimalPlaces,currentLocation.coordinate.latitude];
    
    // Add cell signal strength
    
    //NSString *locationTuple = [roundedLocation stringByAppendingFormat:@"_SIGNAL_%@",[[Sentegrity_TrustFactor_Datasets sharedDatasets] getCelluarSignalBars]];
  

    [outputArray addObject:roundedLocation];
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}


+ (Sentegrity_TrustFactor_Output_Object *)anomaly:(NSArray *)payload {
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
    
    //Screen level is given as a float 0.1-1
    float screenLevel = [[UIScreen mainScreen] brightness];
    
    // With a blocksize of .25 or 4 we get block 0-.25,.25-.5,.5-.75,.75-1
    // We add 1 to the blockOfBrightness after dividing to get a 1-4 block instead of 0-3
    
    float blocksize = [[[payload objectAtIndex:0] objectForKey:@"brightnessBlocksize"] floatValue];
    
    // Prevents 0/.25 = 0
    if(screenLevel < 0.1){
        screenLevel = 0.1;
    }
    
    int blockOfBrightness = ceilf(screenLevel / (1/blocksize));
    
    // Pair it with hour block of day
    NSString *blockOfDay = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getTimeDateStringWithHourBlockSize:[[[payload objectAtIndex:0] objectForKey:@"hoursInBlock"] integerValue] withDayOfWeek:NO];    // Calculate block of screen brightness
    
    NSString *blockOfDayAndSignal = [blockOfDay stringByAppendingFormat:@"_S%@",[[Sentegrity_TrustFactor_Datasets sharedDatasets] getCelluarSignalBars]];
    
    
    NSString *blockOfDayAndSignalAndBrightness = [blockOfDayAndSignal stringByAppendingFormat:@"_L%d", blockOfBrightness];
    
    // Create assertion
    [outputArray addObject: blockOfDayAndSignalAndBrightness];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}


/*
+ (Sentegrity_TrustFactor_Output_Object *)brightness:(NSArray *)payload {
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
    
    //Screen level is given as a float 0.1-1
    float screenLevel = [[UIScreen mainScreen] brightness];
    
    // With a blocksize of .25 or 4 we get block 0-.25,.25-.5,.5-.75,.75-1
    // We add 1 to the blockOfBrightness after dividing to get a 1-4 block instead of 0-3
    
    float blocksize = [[[payload objectAtIndex:0] objectForKey:@"brightnessBlocksize"] floatValue];
    
    // Prevents 0/.25 = 0
    if(screenLevel < 0.1){
        screenLevel = 0.1;
    }
    
    int blockOfBrightness = ceilf(screenLevel / (1/blocksize));
    
    // Pair it with hour block of day
    NSString *blockOfDay = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getTimeDateStringWithHourBlockSize:[[[payload objectAtIndex:0] objectForKey:@"hoursInBlock"] integerValue] withDayOfWeek:NO];    // Calculate block of screen brightness
    
    // Create assertion
    [outputArray addObject: [blockOfDay stringByAppendingString: [NSString stringWithFormat:@"-B%d",blockOfBrightness]]];
    
    //[outputArray addObject: [NSString stringWithFormat:@"B%d",blockOfBrightness]];
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}
*/


@end
