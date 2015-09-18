//
//  TrustFactor_Dispatch_NetStat.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Netstat.h"
#import "ActiveConnection.h"

@implementation TrustFactor_Dispatch_Netstat


// 3
+ (Sentegrity_TrustFactor_Output_Object *)badDst:(NSArray *)payload {

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
    
    // Get the current netstat data
    NSArray *connections = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getNetstatInfo];
    
    // Check the array
    if (!connections || connections == nil || connections.count < 1) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Run through all the connection dictionaries
    for (ActiveConnection *connection in connections) {
        
        // Skip if this is a listening socket or local
        if([connection.status isEqualToString:@"LISTEN"] || [connection.remoteHost isEqualToString:@"localhost"] )
            continue;

        
        // Iterate through payload names and look for matching processes
        for (NSString *badDstIP in payload) {
            
            // Check if the domain of the connection equal one in payload
            if([connection.remoteHost hasSuffix:badDstIP]) {
                
                // make sure we don't add more than one instance of destination
                if (![outputArray containsObject:connection.remoteHost]){
                    
                    // Add the destination to the output array
                    [outputArray addObject:connection.remoteHost];
                }
            }
        }
    }

    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;

}




// 9
+ (Sentegrity_TrustFactor_Output_Object *)priviledgedPort:(NSArray *)payload {
    
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
    
    // Get the current netstat data
    NSArray *connections = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getNetstatInfo];
    
    // Check the array
    if (!connections || connections == nil || connections.count < 1) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Run through all the connection dictionaries
    for (ActiveConnection *connection in connections) {
        
        // Skip if this is NOT a listening socket
        if(![connection.status isEqualToString:@"LISTEN"])
            continue;
        
        
        // Iterate through source ports and look for matching ports
        for (NSNumber *badSrcPort in payload) {
            
            // Check if the current port is equal to bad port
            if([connection.localPort intValue] == [badSrcPort intValue]) {
                
                // make sure we don't add more than one instance of the port
                if (![outputArray containsObject:connection.localPort ]){
                    
                    // Add the port to the output array
                    [outputArray addObject:connection.localPort];
                }
            }
        }
    }
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



// 13
+ (Sentegrity_TrustFactor_Output_Object *)newService:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the current netstat data
    NSArray *connections = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getNetstatInfo];
    
    // Check the array
    if (!connections || connections == nil || connections.count < 1) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    

    
    // Run through all the connection dictionaries
    for (ActiveConnection *connection in connections) {
        
        // Skip if this is NOT a listening socket
        if(![connection.status isEqualToString:@"LISTEN"])
            continue;
        
        
        // make sure we don't add more than one instance of the port
        if (![outputArray containsObject:connection.localPort]){
            
            // Add the port to the output array
            [outputArray addObject:connection.localPort];
        }
    }
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

+ (Sentegrity_TrustFactor_Output_Object *)dataExfiltration:(NSArray *)payload {
    
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
    
    // Get the current netstat data
    NSDictionary *dataXfer = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getDataXferInfo];
    
    // Check the dictionary
    if (!dataXfer || dataXfer == nil) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get uptime in seconds
    long uptime=0;
    uptime = (long)[[NSProcessInfo processInfo] systemUptime];
    
    if (uptime==0) {
        
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // second, 3600 = hour, 86400 = day
    int timeInterval=0;
    timeInterval = [[[payload objectAtIndex:0] objectForKey:@"secondsInterval"] intValue];
    
    // Check payload item prior to division
    if(timeInterval==0){
        //not been up long enough to be measured
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // per interval data transfer max in MB
    int dataMax=0;
    dataMax = [[[payload objectAtIndex:0] objectForKey:@"maxSentMB"] intValue];
    
    // Check payload item prior to division
    if(dataMax==0){
        //not been up long enough to be measured
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    int timeSlots = 0;
    timeSlots = round(uptime/timeInterval);
    
    if (timeSlots < 1){
        //not been up long enough to be measured
        

        // Don't set an error let it generate default and not trigger
        //[trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get total data xfer sent in MB
    int dataSent = [[dataXfer objectForKey:@"WiFiSent"] intValue] + [[dataXfer objectForKey:@"WANSent"] intValue] + [[dataXfer objectForKey:@"TUNSent"] intValue];
    
    // Calculate xfer per timeslot
    int dataSentPerTimeSlot = ceil(dataSent/timeSlots);
    
    // Check if we even occupy one timeslot
    if (dataSentPerTimeSlot < 1){
        //not been up long enough to be measured
        
        
        // Don't set an error let it generate default and not trigger
        //[trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Compare dataSentPerTimeSlot to maxData allowed
    
    if(dataSentPerTimeSlot > dataMax){
        
        [outputArray addObject:@"exfil"];
        
    }
  
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}


+ (Sentegrity_TrustFactor_Output_Object *)unencryptedTraffic:(NSArray *)payload {
    
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
    
    // Get the current netstat data
    NSArray *connections = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getNetstatInfo];
    
    // Check the array
    if (!connections || connections == nil || connections.count < 1) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Run through all the connection dictionaries
    for (ActiveConnection *connection in connections) {
        
        // Skip if this is not a current connection
        if([connection.remoteHost isEqualToString:@"localhost"])
            continue;
        
        // if its 443 don't even look
        if([connection.remotePort intValue] == 443)
            continue;
        
        // Iterate through payload names and look for matching processes
        for (NSNumber *badDstPort in payload) {
            
            // Check if the domain of the connection equal one in payload
            if([connection.remotePort intValue] == [badDstPort intValue]) {
                // make sure we don't add more than one instance of the connection
                if (![outputArray containsObject:connection.remoteHost]){
                    
                    // Add the process to the output array
                    [outputArray addObject:connection.remoteHost];
                }
            }
        }
    }
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}






@end
