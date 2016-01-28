//
//  TrustFactor_Dispatch_Location.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//


#import "TrustFactor_Dispatch_Location.h"
@import CoreLocation;

@implementation TrustFactor_Dispatch_Location

/* Old/Archived
 
// Determine if the device is in a location of an allowed country
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
 
 */

// Determine location of device
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

// Location approximation using brightness of screen, strength of cell tower, and magnetometer readings
+ (Sentegrity_TrustFactor_Output_Object *)locationApprox:(NSArray *)payload {
    
    // This TrustFactor is designed to detect changes in a users environment within a generic GPS location. We round GPS locations and rely
    // on this TrustFactor to determine if they are in a new environment within the broader GPS location.
    // There are a couple of way this function works, if the user has not authorized location services than we increase the sensitivity
    // in order to collect more datapoint. If they did authorize location then we decrease the sensitivity.
    // Location approximation takes into consideration 3 different values, the brightness of the screen (indicating light in room), the strength of the cell tower signal, and magnetomter readings that attempt to calculate the magnetic field of a room.
    
    // The following is  generaly TrustFactor stuff that is not too specific to this function
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
        
        // Location services was not authorized or we didn't get any data, this is later used to increase sensitivity
        locationAvailable=NO;
    }
    else{
        // We do have authorization/data
        // Attempt to get the current location
        currentLocation = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getLocationInfo];
        
        
        // Check if error was determined after call to dataset helper
        if([[Sentegrity_TrustFactor_Datasets sharedDatasets]  locationDNEStatus] == 0){
            
            if(currentLocation != nil){
                
                // Rounding from policy
                int decimalPlaces = [[[payload objectAtIndex:0] objectForKey:@"locationRounding"] intValue];
                
                // Round the GPS location to two decimals
                NSString *roundedLocation = [NSString stringWithFormat:@"LO_%.*f_LT_%.*f",decimalPlaces,currentLocation.coordinate.longitude,decimalPlaces,currentLocation.coordinate.latitude];
                
                // Build the first part of our anomaly string by appending the location GPS
                anomalyString = [anomalyString stringByAppendingString:roundedLocation];

            }
            
        } else {
                // Problem occured so don't use location
                locationAvailable=NO;
        }
        
        
    }
    
    // ** WiFi Signal Strength **
    
    // Check if WiFi is disabled
    if([[[Sentegrity_TrustFactor_Datasets sharedDatasets] isWifiEnabled] intValue]==0){
        
        // Return NA for WiFi
        anomalyString = [anomalyString stringByAppendingString:@"_WIFI:DISABLED"];
        
    }    // If we're enabled, still check if we're tethering and set as unavaialble if we are
    else if([[[Sentegrity_TrustFactor_Datasets sharedDatasets] isTethering] intValue]==1){
        
        // Return NA for WiFi
        anomalyString = [anomalyString stringByAppendingString:@"_WIFI:TETHERING"];
        
    }
    else{
        
        NSDictionary *wifiInfo = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getWifiInfo];
        
        // Check for a connection
        if (wifiInfo == nil){
            
            // Return NA for WiFi
            anomalyString = [anomalyString stringByAppendingString:@"_WIFI:NOCON"];
            
        }
        else{
            
            // Get the ssid
            NSString *ssid = [wifiInfo objectForKey:@"ssid"];
            
            // Validate the gateway IP and BSSID
            if ((ssid == nil && ssid.length == 0)) {
                
                // Return NA for WiFi
                anomalyString = [anomalyString stringByAppendingString:@"_WIFI:NOSSID"];
                
            }
            else{
                
                NSNumber *wifiSignal = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getWifiSignal];
                
                // Check if we have a signal reading
                if([wifiSignal intValue] == 0){
                    
                    // Return just the SSID
                    NSString *ssidString = [NSString stringWithFormat:@"_WIFI:%@",ssid];
                    anomalyString = [anomalyString stringByAppendingString:ssidString];
                }
                else{
                    
                    // Divide into blocksizes
                    int blocksize=0;
                    
                    // If no location data use sensitive
                    if(locationAvailable==NO){
                        
                        blocksize = [[[payload objectAtIndex:0] objectForKey:@"wifiSignalBlocksizeNoLocation"] floatValue];
                        
                    } //else use liberal
                    else{
                        
                        blocksize = [[[payload objectAtIndex:0] objectForKey:@"wifiSignalBlocksizeWithLocation"] floatValue];
                    }
                    
                    int blockOfWiFi = round(abs([wifiSignal intValue]) / blocksize);
                    
                    
                    anomalyString = [anomalyString stringByAppendingString:[NSString stringWithFormat:@"_WIFI:%@_%i",ssid,blockOfWiFi]];
                    
                    
                }

                
            }
            
            
            
        }
            
    }
        
        
    
    
    

    // ** MAGNETIC FIELD **
    
    // First  get accel parameters to apply as weights
    
    // Use the API which does not require motion authorization if there was an error in motion (i.e., not authorized)
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets] accelMotionDNEStatus] == 0 ) {
        
        
        // Use custom mechanism for increased accuracy (the non-motion API is designed for GUIs not user auth)
        NSArray *gryoRads = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getAccelRadsInfo];
        
        float xAverage;
        float yAverage;
        float zAverage;
        
        float xTotal = 0.0;
        float yTotal = 0.0;
        float zTotal = 0.0;
        
        float count=0;
        
        for (NSDictionary *sample in gryoRads) {
            
            count++;
            xTotal = xTotal + [[sample objectForKey:@"x"] floatValue];
            yTotal = yTotal + [[sample objectForKey:@"y"] floatValue];
            zTotal = zTotal + [[sample objectForKey:@"z"] floatValue];
            
        }
        

            xAverage = xTotal / count;
            yAverage = yTotal / count;
            zAverage = zTotal / count;
        
    }

    
    // ** MAGNETIC FIELD **

    if(locationAvailable==NO){
        int magneticBlockSize = [[[payload objectAtIndex:0] objectForKey:@"magneticBlockSize"] intValue];
        
        if ([[Sentegrity_TrustFactor_Datasets sharedDatasets] magneticHeadingDNEStatus] == 0 ){
            
            NSArray *headings;
            headings = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getMagneticHeadingsInfo];
            
            
            // Check motion dataset has something
            if(headings != nil ) {
                
                float x = 0.0;
                float y = 0.0;
                float z = 0.0;
                float heading = 0.0;
                
                float magnitudeAverage = 0.0;
                float magnitudeTotal = 0.0;
                float magnitude = 0.0;
                
                float counter = 0.0;
                
                // Run through all the sample we got prior to stopping motion
                for (NSDictionary *sample in headings) {
                    
                    // Get the calibrated magnetometer data
                    heading = [[sample objectForKey:@"heading"] floatValue];
                    x = [[sample objectForKey:@"x"] floatValue];
                    y = [[sample objectForKey:@"y"] floatValue];
                    z = [[sample objectForKey:@"z"] floatValue];
                    
                    // Calculate totl magnetic field regardless of position for each measurement
                    magnitude = sqrt (pow(x,2)+
                                      pow(y,2)+
                                      pow(z,2));
                    
                    //magnitude = sqrt (pow(z,2));
                    
                    magnitudeTotal = magnitudeTotal + magnitude;
                    
                    counter++;
                    
                    
                }
                
                
                // compute average across all samples taken
                magnitudeAverage = magnitudeTotal/counter;
                
                int blockOfMagnetic = ceilf(fabsf(magnitudeAverage)/magneticBlockSize);
                // round to the nearest n:  x_rounded = ((x + n/2)/n)*n;
                // round to nearest X
                //int rounded = floor((magnitudeAverage+(roundingSensitivity/2))/roundingSensitivity)*roundingSensitivity;
                
                NSString *magnitudeString = [NSString stringWithFormat:@"_MAGNET:%d",blockOfMagnetic];
                
                anomalyString = [anomalyString stringByAppendingString:magnitudeString];
                
            }
        }

    }


    
    // The magnetomter reading is used in an attempt to calculate a unique field for the user's current location
    /*
    int magneticBlockSize = 0;
    
    if(locationAvailable == NO){
        
       magneticBlockSize = [[[payload objectAtIndex:0] objectForKey:@"magneticBlockSizeNoLocation"] intValue];
        
    } else {
        
        magneticBlockSize = [[[payload objectAtIndex:0] objectForKey:@"magneticBlockSizeWithLocation"] intValue];
    }
    
        NSArray *headings;
        
        // Check if error was determined when magnetic was started, if so don't use magnetic
        if ([[Sentegrity_TrustFactor_Datasets sharedDatasets] headingsMotionDNEStatus] == 0 ){
            
            // Attempt to get magnetomter headings data
            headings = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getHeadingsInfo];
            
            // Check headings dataset has something
            if (headings != nil ) {
                
                float x = 0.0;
                float y = 0.0;
                float z = 0.0;
                
                float magnitudeAverage = 0.0;
                float magnitudeTotal = 0.0;
                float magnitude = 0.0;
                
                float counter = 0.0;
                
                // Run through all the sample we got prior to stopping the measurement and average them
                for (NSDictionary *sample in headings) {
                    
                    // Get the calibrated magnetometer data
                    x = [[sample objectForKey:@"x"] floatValue];
                    y = [[sample objectForKey:@"y"] floatValue];
                    z = [[sample objectForKey:@"z"] floatValue];
                    
                    // Calculate total magnetic field regardless of position for each measurement, it should not matter what direction or position the device is in, we need a way to account for this
                    
                    magnitude = sqrt (pow(x,2)+
                                      pow(y,2)+
                                      pow(z,2));
                    
                    magnitudeTotal = magnitudeTotal + magnitude;
                    
                    counter++;
                    
                }
                
                // Compute average across all samples taken
                magnitudeAverage = magnitudeTotal/counter;
                
                // Instead of using the raw value we "smooth" it by dividing by a block size to create "buckets" of ranges for a magnetic field
                
                int blockOfMagnetic = ceilf(fabsf(magnitudeAverage)/magneticBlockSize);
                
                NSString *magnitudeString = [NSString stringWithFormat:@"_M%d",blockOfMagnetic];
                
                // Add to the anomaly string
                anomalyString = [anomalyString stringByAppendingString:magnitudeString];
            }
            
        }
*/
     
     
    // ** SCREEN BRIGHTNESS **
    
    //Screen level is given as a float 0.1-1
    float screenLevel = [[UIScreen mainScreen] brightness];
    
    float brightnessBlockSize=0;
    
    
    // If no location data use sensitive
    if(locationAvailable==NO){
        
        brightnessBlockSize = [[[payload objectAtIndex:0] objectForKey:@"brightnessBlocksizeNoLocation"] floatValue];
        
    } //else use liberal
    else{
        
        brightnessBlockSize = [[[payload objectAtIndex:0] objectForKey:@"brightnessBlocksizeWithLocation"] floatValue];
    }
    
    // With a blocksize of .25 or 4 we get block 0-.25,.25-.5,.5-.75,.75-1
    // We add 1 to the blockOfBrightness after dividing to get a 1-4 block instead of 0-3
    
    
    // Prevents 0/.25 = 0
    if(screenLevel < 0.1){
        screenLevel = 0.1;
    }
    
    int blockOfBrightness = round(screenLevel / (1/brightnessBlockSize));
    
    anomalyString = [anomalyString stringByAppendingString:[NSString stringWithFormat:@"_LIGHT:%d", blockOfBrightness]];
    
    
    // ** CELLUAR SIGNAL STRENGTH **
    
    // If no location data use sensitive
    
    int celluarBlockSize;
    if(locationAvailable==NO){
        
        celluarBlockSize = [[[payload objectAtIndex:0] objectForKey:@"cellSignalBlocksizeNoLocation"] floatValue];
        
    } //else use liberal
    else{
        
        celluarBlockSize = [[[payload objectAtIndex:0] objectForKey:@"cellSignalBlocksizeWithLocation"] floatValue];
    }
    
    NSNumber *signal = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getCelluarSignalRaw];
    NSString *celluar;
    
    // Probably in airplane mode or no signal
    if(signal==nil || !signal){
        
        // First check airplanbe mode
        NSNumber *enabled = [[Sentegrity_TrustFactor_Datasets sharedDatasets] isAirplaneMode];
        
        // Check the array
        if (!enabled || enabled == nil) {
            
            celluar = @"_CELL:NOSIGNAL";
        }
        else{
            
            // Is airplane enabled?
            if(enabled.intValue == 1){
                celluar = @"_CELL:AIRPLANE";
            }
            else{
                
                celluar = @"_CELL:NOSIGNAL";
                
            }
            
        }
        
        
    }
    else{
        //int blockOfSignal = (([signal intValue] + blocksize/2)/blocksize)*blocksize;
        int blockOfSignal = round(abs([signal intValue]) / celluarBlockSize);
        celluar = [NSString stringWithFormat:@"_CELL:%d",blockOfSignal];
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
