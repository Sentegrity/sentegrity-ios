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
    if (![self validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the current netstat data
    NSArray *connections = [self netstatInfo];
    
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
        
        // Skip if this is a listening socket
        if([[connection objectForKey:@"state"] isEqualToString:@"LISTEN"])
            continue;
                
        // Get the current destination IP
        dstIP = [connection objectForKey:@"dst_ip"];
        
        // Iterate through payload names and look for matching processes
        for (NSString *badDstIP in payload) {
            
            // Check if the process name is equal to the current process being viewed
            if([badDstIP isEqualToString:dstIP]) {
                
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
    if (![self validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the current netstat data
    NSArray *connections = [self netstatInfo];
    
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
    NSArray *connections = [self netstatInfo];
    
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




@end
