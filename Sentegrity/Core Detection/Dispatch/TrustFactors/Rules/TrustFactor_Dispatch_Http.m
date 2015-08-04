//
//  TrustFactor_Dispatch_Http.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Http.h"
#import <UIKit/UIKit.h>

@implementation TrustFactor_Dispatch_Http

// Check for bad url handlers
+ (Sentegrity_TrustFactor_Output_Object *)maliciousApps:(NSArray *)payload {
    
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
    
    // Run through the payload
    for (NSString *urlString in payload) {
        
        // Create a fake url for the current payload string
        NSURL *fakeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", urlString]];
        
        // Return whether or not the fake url item exists
        if ([[UIApplication sharedApplication] canOpenURL:fakeURL]) {
            // Exists
            
            // make sure we don't add more than one instance of the proc
            if (![outputArray containsObject:[fakeURL path]]){
                // Add the process to the output array
                [outputArray addObject:[fakeURL absoluteString]];
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



@end
