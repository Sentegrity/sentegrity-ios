//
//  TrustFactor_Dispatch_NetStat.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Netstat.h"

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
    
    // Destination IP
    NSString *dstIP;
    
    // Run through all the connection dictionaries
    for (NSDictionary *connection in connections) {
        
        // Skip if this is a listening socket or local
        if([[connection objectForKey:@"state"] isEqualToString:@"LISTEN"] || [[connection objectForKey:@"dst_ip"] isEqualToString:@"localhost"] )
            continue;

        
        // Get the current destination IP
        dstIP = [connection objectForKey:@"dst_ip"];
        
        // Iterate through payload names and look for matching processes
        for (NSString *badDstIP in payload) {
            
            // Check if the domain of the connection equal one in payload
            if([dstIP hasSuffix:badDstIP]) {
                
                // make sure we don't add more than one instance of the proc
                if (![outputArray containsObject:dstIP]){
                    
                    // Add the process to the output array
                    [outputArray addObject:dstIP];
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
    
    // Source port
    NSString *srcPort;
    
    // Run through all the connection dictionaries
    for (NSDictionary *connection in connections) {
        
        // Skip if this is NOT a listening socket
        if(![[connection objectForKey:@"state"] isEqualToString:@"LISTEN"])
            continue;
        
        // Get the current src port
        srcPort = [connection objectForKey:@"src_port"];
        
        // Iterate through source ports and look for matching ports
        for (NSString *badSrcPort in payload) {
            
            // Check if the current port is equal to bad port
            if([srcPort isEqualToString:badSrcPort]) {
                
                // make sure we don't add more than one instance of the port
                if (![outputArray containsObject:srcPort]){
                    
                    // Add the port to the output array
                    [outputArray addObject:srcPort];
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
    
    // Source port
    NSString *srcPort;
    
    // Run through all the connection dictionaries
    for (NSDictionary *connection in connections) {
        
        // Skip if this is NOT a listening socket
        if(![[connection objectForKey:@"state"] isEqualToString:@"LISTEN"])
            continue;
        
        // Get the current src port
        srcPort = [connection objectForKey:@"src_port"];
        
        // make sure we don't add more than one instance of the port
        if (![outputArray containsObject:srcPort]){
            
            // Add the port to the output array
            [outputArray addObject:srcPort];
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
    
    // Get uptime
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
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get total data xfer sent in MB
    int dataSent = [[dataXfer objectForKey:@"WiFiSent"] intValue] + [[dataXfer objectForKey:@"WANSent"] intValue] + [[dataXfer objectForKey:@"TUNSent"] intValue];
    
    // Calculate xfer per timeslot
    int dataSentPerTimeSlot = round(dataSent/timeSlots);
    
    // Check if we even occupy one timeslot
    if (dataSentPerTimeSlot < 1){
        //not been up long enough to be measured
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
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

// For demo only
+ (Sentegrity_TrustFactor_Output_Object *)unencryptedTraffic:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Trigger it
    [outputArray addObject:@"101.54.21.117"];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

+ (Sentegrity_TrustFactor_Output_Object *)unencryptedTrafficOrig:(NSArray *)payload {
    
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
    
    // Destination IP
    NSString *dstIP;
    NSString *dstPort;
    
    // Run through all the connection dictionaries
    for (NSDictionary *connection in connections) {
        
        // Skip if this is not a current connection
        if(!([[connection objectForKey:@"state"] isEqualToString:@"ESTABLISHED"] || [[connection objectForKey:@"state"] isEqualToString:@"CLOSE_WAIT"]) || [[connection objectForKey:@"dst_ip"] isEqualToString:@"localhost"])
            continue;
        
        
        // Get the current destination IP
        dstIP = [connection objectForKey:@"dst_ip"];
        
        // Get the current destination port
        dstPort = [connection objectForKey:@"dst_port"];
        
        // if its 443 don't even look
        if([dstPort isEqualToString:@"443"])
            continue;
        
        // Iterate through payload names and look for matching processes
        for (NSString *badDstPort in payload) {
            
            // Check if the domain of the connection equal one in payload
            if([dstPort isEqualToString:badDstPort]) {
                // make sure we don't add more than one instance of the port
                if (![outputArray containsObject:badDstPort]){
                    
                    // Add the process to the output array
                    [outputArray addObject:dstIP];
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
