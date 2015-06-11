//
//  TrustFactor_Dispatch_Sandbox.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Sandbox.h"

@implementation TrustFactor_Dispatch_Sandbox

// 8 - Sandbox API Verification and Kernel Configurations - Basically Jailbreak Checks
+ (Sentegrity_TrustFactor_Output_Object *)apiVerification:(NSArray *)payload {
    
    // TODO: Fork() Check
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Get the current process environment info
    NSDictionary *environmentInfo = [[NSProcessInfo processInfo] environment];
    if ([environmentInfo objectForKey:@"APP_SANDBOX_CONTAINER_ID"] != nil) {
        // Sandboxed
        [outputArray addObject:[[environmentInfo objectForKey:@"APP_SANDBOX_CONTAINER_ID"] stringValue]];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end
