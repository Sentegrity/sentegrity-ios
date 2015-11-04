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
+ (Sentegrity_TrustFactor_Output_Object *)countryAllowed:(NSArray *)payload {
    
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
    
    
    // Check if error was already determined when placemark was started
    if([[Sentegrity_TrustFactor_Datasets sharedDatasets]  placemarkDNEStatus] != 0){
        
        // Set the DNE status code for the TF to what was previously determined by placemark
        //  [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets]  placemarkDNEStatus]];
        
        //Changed to no-data otherwise this triggers a policy violation when the user does not authorize location (policy violations require admin pin)
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Attempt to get the current placemark
    currentPlacemark = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getPlacemarkInfo];
    
    // Check if error after (i.e., timer expired)
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
+ (Sentegrity_TrustFactor_Output_Object *)locationGPS:(NSArray *)payload {
    
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
        
        return trustFactorOutputObject;
        
        
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


+ (Sentegrity_TrustFactor_Output_Object *)locationAnomaly:(NSArray *)payload {
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
    
    
    // This string gets built by various factors that are available
    NSString *anomalyString = @"";
    
    // ** LOCATION **
    
    // Try to get location
    CLLocation *currentLocation;
    BOOL locationAvailable=YES;
    
    // Check if error was determined by location callback in app delegate
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets]  locationDNEStatus] != 0 ){
        
        locationAvailable=NO;
    }
    else{
        
        // Attempt to get the current location
        currentLocation = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getLocationInfo];
        
        
        // Check if error was determined after call to dataset helper
        if([[Sentegrity_TrustFactor_Datasets sharedDatasets]  locationDNEStatus] == 0){
            
            if(currentLocation != nil){
                
                // Rounding from policy
                int decimalPlaces = [[[payload objectAtIndex:0] objectForKey:@"locationRounding"] intValue];
                
                // Rounded location
                NSString *roundedLocation = [NSString stringWithFormat:@"LO_%.*f_LT_%.*f",decimalPlaces,currentLocation.coordinate.longitude,decimalPlaces,currentLocation.coordinate.latitude];
                
                anomalyString = [anomalyString stringByAppendingString:roundedLocation];

            }
            
        } else
        {
                locationAvailable=NO;
        }
        
        
    }
    

    // ** MAGNETIC FIELD **
    
    int magneticBlockSize=0;
    
    // If no location data use magnetometer, if we have location we don't use it
    if(locationAvailable==NO){
        
       magneticBlockSize = [[[payload objectAtIndex:0] objectForKey:@"magneticBlockSizeNoLocation"] intValue];
        
        NSArray *headings;
        
        // Check if error was determined when magnetic was started, if so don't use magnetic
        if ([[Sentegrity_TrustFactor_Datasets sharedDatasets] headingsMotionDNEStatus] == 0 ){
            
            // Attempt to get motion data
            headings = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getHeadingsInfo];
            
            // Check motion dataset has something
            if (headings != nil ) {
                
                float x = 0.0;
                float y = 0.0;
                float z = 0.0;
                
                float magnitudeAverage = 0.0;
                float magnitudeTotal = 0.0;
                float magnitude = 0.0;
                
                float counter = 0.0;
                
                // Run through all the sample we got prior to stopping motion
                for (NSDictionary *sample in headings) {
                    
                    // Get the calibrated magnetometer data
                    x = [[sample objectForKey:@"x"] floatValue];
                    y = [[sample objectForKey:@"y"] floatValue];
                    z = [[sample objectForKey:@"z"] floatValue];
                    
                    // Calculate totl magnetic field regardless of position for each measurement
                    magnitude = sqrt (pow(x,2)+
                                      pow(y,2)+
                                      pow(z,2));
                    
                    magnitudeTotal = magnitudeTotal + magnitude;
                    
                    counter++;
                    
                    
                }
                
                // compute average across all samples taken
                magnitudeAverage = magnitudeTotal/counter;
                
                int blockOfMagnetic = ceilf(fabsf(magnitudeAverage)/magneticBlockSize);
                // round to the nearest n:  x_rounded = ((x + n/2)/n)*n;
                // round to nearest X
                //int rounded = floor((magnitudeAverage+(roundingSensitivity/2))/roundingSensitivity)*roundingSensitivity;
                
                NSString *magnitudeString = [NSString stringWithFormat:@"_M%d",blockOfMagnetic];
                
                anomalyString = [anomalyString stringByAppendingString:magnitudeString];
                
                
            }
            
        }

    
    }
    
    // ** SCREEN BRIGHTNESS **
    
    //Screen level is given as a float 0.1-1
    float screenLevel = [[UIScreen mainScreen] brightness];
    
    float blocksize=0;
    
    
    // If no location data use sensitive
    if(locationAvailable==NO){
        
        blocksize = [[[payload objectAtIndex:0] objectForKey:@"brightnessBlocksizeNoLocation"] floatValue];
        
    } //else use liberal
    else{
        
        blocksize = [[[payload objectAtIndex:0] objectForKey:@"brightnessBlocksizeWithLocation"] floatValue];
    }
    
    // With a blocksize of .25 or 4 we get block 0-.25,.25-.5,.5-.75,.75-1
    // We add 1 to the blockOfBrightness after dividing to get a 1-4 block instead of 0-3
    
    
    // Prevents 0/.25 = 0
    if(screenLevel < 0.1){
        screenLevel = 0.1;
    }
    
    int blockOfBrightness = ceilf(screenLevel / (1/blocksize));
    
    anomalyString = [anomalyString stringByAppendingString:[NSString stringWithFormat:@"_L%d", blockOfBrightness]];
    
    
    // ** CELLUAR SIGNAL STRENGTH **
    
    NSString *celluar = [NSString stringWithFormat:@"_S%@",[[Sentegrity_TrustFactor_Datasets sharedDatasets] getCelluarSignalBars]];
    
    // Probably in airplane mode or no signal
    if(celluar.length < 1){
        
        celluar = @"NO_SIGNAL";
        
    }
    
    anomalyString = [anomalyString stringByAppendingString:celluar];
    
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Create assertion
    [outputArray addObject: anomalyString];
    
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
