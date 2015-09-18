//
//  TrustFactor_Dispatch_Time.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Time.h"

@implementation TrustFactor_Dispatch_Time




// Not implemented in default policy
//+ (Sentegrity_TrustFactor_Output_Object *)allowedAccessTime:(NSArray *)payload {
//    return 0;
//}

+ (Sentegrity_TrustFactor_Output_Object *)accessTime:(NSArray *)payload {
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
    
    
    //NSString *timeString = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getTimeDateStringWithHourBlockSize:[[[payload objectAtIndex:0] objectForKey:@"hoursInBlock"] integerValue] withDayOfWeek:YES];
    NSString *time = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getTimeDateStringWithHourBlockSize:[[[payload objectAtIndex:0] objectForKey:@"hoursInBlock"] integerValue] withDayOfWeek:YES];
    
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
    
    
    // Create assertion
    [outputArray addObject:[time stringByAppendingFormat:@"_LIGHT_%d",blockOfBrightness]];
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

/*
 
 OLD
 
 
+ (Sentegrity_TrustFactor_Output_Object *)timeHour:(NSArray *)payload {
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
    
    NSString *hourBlock = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getTimeDateStringWithHourBlockSize:[[[payload objectAtIndex:0] objectForKey:@"hoursInBlock"] integerValue] withDayOfWeek:NO];
    
    // Create assertion
    [outputArray addObject: hourBlock];
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

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
