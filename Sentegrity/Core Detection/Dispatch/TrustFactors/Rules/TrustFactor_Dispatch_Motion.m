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
    
    
     // Check if error was already determined when motion was started
    if ([self motionDNEStatus] != 0 ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[self motionDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Attempt to get motion data
    motion = [self motionInfo];
        
    // Check motion dataset again
    if (!motion || motion == nil || motion.count < 3) {
            
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Rounding from policy
    int roundingPlace = [[[payload objectAtIndex:0] objectForKey:@"rounding"] intValue];
    
    // Average from policy ?
    int maxSampleSize = [[[payload objectAtIndex:0] objectForKey:@"maxSampleSize"] intValue];

    if (maxSampleSize == 0 || roundingPlace == 0){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Total of all samples based on x/y/z
    float xTotal = 0.0;
    float yTotal = 0.0;
    float zTotal = 0.0;
    
    // Averages calculated across all samples
    float xAverage = 0.0;
    float yAverage = 0.0;
    float zAverage = 0.0;
    
    int counter = 1;
    
    // Run through all the sample we got prior to stopping motion
    for (NSDictionary *sample in motion) {
        
        // Get the current process name
        NSNumber *x = [sample objectForKey:@"x"];
        NSNumber *y = [sample objectForKey:@"y"];
        NSNumber *z = [sample objectForKey:@"z"];
        
        xTotal = xTotal + [x floatValue];
        yTotal = yTotal + [y floatValue];
        zTotal = zTotal + [z floatValue];
        
        // We hit our max sample size
        if(counter == maxSampleSize){
            break;
        }
        counter = counter + 1;
        
    }
    
    // Calculate averages
    xAverage = xTotal/counter;
    yAverage = yTotal/counter;
    zAverage = zTotal/counter;
    
    NSString *motionX = [NSString stringWithFormat:@"%.*f",roundingPlace,xAverage];
    //NSString *motionY = [NSString stringWithFormat:@"%.*f",roundingPlace,yAverage];
    NSString *motionZ = [NSString stringWithFormat:@"%.*f",roundingPlace,zAverage];
        

    // Get orientation, depending on portrait vs. landscape use Z or X
    UIDevice *device = [UIDevice currentDevice];
    UIDeviceOrientation orientation = device.orientation;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
           [outputArray addObject:motionZ];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
           [outputArray addObject:motionZ];
            break;
        case UIDeviceOrientationLandscapeLeft:
           [outputArray addObject:motionX];
            break;
        case UIDeviceOrientationLandscapeRight:
           [outputArray addObject:motionX];
            break;
        case UIDeviceOrientationFaceUp:
           [outputArray addObject:motionZ];
            break;
        case UIDeviceOrientationFaceDown:
           [outputArray addObject:motionZ];
            break;
        case UIDeviceOrientationUnknown:
            //Error
            [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
            return trustFactorOutputObject;
            break;
        default:
            //Error
            [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
            return trustFactorOutputObject;
            break;
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



+ (Sentegrity_TrustFactor_Output_Object *)orientation:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
  
    // Get orientation
    UIDevice *device = [UIDevice currentDevice];
    UIDeviceOrientation orientation = device.orientation;
    
    NSString *orientationString;

    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationString =  @"Portrait";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientationString =  @"Portrait_Upside_Down";
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientationString =  @"Landscape_Left";
            break;
        case UIDeviceOrientationLandscapeRight:
            orientationString =  @"Landscape_Right";
            break;
        case UIDeviceOrientationFaceUp:
            orientationString =  @"Face_Up";
            break;
        case UIDeviceOrientationFaceDown:
            orientationString =  @"Face_Down";
            break;
        case UIDeviceOrientationUnknown:
            //Error
            [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
            return trustFactorOutputObject;
            break;
        default:
            //Error
            [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
            return trustFactorOutputObject;
            break;
    }
    
    
    [outputArray addObject:orientationString];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



@end