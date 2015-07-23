//
//  TrustFactor_Dispatch_Activity.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Motion.h"

@implementation TrustFactor_Dispatch_Motion


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
    
    // Get motion dataset
    NSArray *motion;
    
    // If the handler already determined a problem
    if ([self motionDNEStatus] != 0 ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[self motionDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    else{ //try to get dataset
        
        motion = [self motionInfo];
        
        // Check motion dataset again
        if (!motion || motion == nil || motion.count < 3) {
            
            [trustFactorOutputObject setStatusCode:DNEStatus_error];
            // Return with the blank output object
            return trustFactorOutputObject;
        }
        

    }

    

    // Rounding from policy
    NSInteger decimalPlaces = [[[payload objectAtIndex:0] objectForKey:@"rounding"] integerValue];
    
    // Rounded motion
    NSString *motionTuple = [NSString stringWithFormat:@"%.*f,%.*f,%.*f",decimalPlaces,[[motion objectAtIndex:0] floatValue],decimalPlaces,[[motion objectAtIndex:1] floatValue],decimalPlaces,[[motion objectAtIndex:2]floatValue]];
    
    [outputArray addObject:motionTuple];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}


@end