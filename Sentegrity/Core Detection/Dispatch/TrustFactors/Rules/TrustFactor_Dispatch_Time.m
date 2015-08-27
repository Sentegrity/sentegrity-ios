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

+ (Sentegrity_TrustFactor_Output_Object *)unknownAccessTime:(NSArray *)payload {
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![self validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    //day of week
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    
    NSInteger dayOfWeek = [comps weekday];
    NSInteger hourOfDay = [components hour];
    NSInteger minutes = [components minute];
    
    //round up if needed
    if(minutes > 30){
        hourOfDay = hourOfDay+1;
    }
    
    
    NSInteger blockOfDay=0;
    
    NSInteger blocksize = [[[payload objectAtIndex:0] objectForKey:@"blocksize"] integerValue];
    //part of day
    if(blocksize>0){
        blockOfDay = floor(hourOfDay / (24/blocksize))+1;
    }
    else{
        // No blocksize
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create assertion
    [outputArray addObject: [NSString stringWithFormat:@"D%ld-H%ld",(long)dayOfWeek,(long)blockOfDay]];
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

+ (Sentegrity_TrustFactor_Output_Object *)unknownLight:(NSArray *)payload {
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![self validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    //day of week
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    
    NSInteger hourOfDay = [components hour];
    NSInteger minutes = [components minute];
    
    //round up if needed
    if(minutes > 30){
        hourOfDay = hourOfDay+1;
    }
    
    // Calculate block of screen brightness
    
    //Screen level is given as a float 0.1-1
    float screenLevel = [[UIScreen mainScreen] brightness];
    
    // With a blocksize of .25 or 4 we get block 0-.25,.25-.5,.5-.75,.75-1
    // We add 1 to the blockOfBrightness after dividing to get a 1-4 block instead of 0-3

    float blocksizeInt = [[[payload objectAtIndex:0] objectForKey:@"brightnessBlocksize"] floatValue];
    
    //Convert blocksize int to float (e.g., 4 = .25)
    float brightnessBlockSize = 1/blocksizeInt;
    
    int blockOfBrightness=0;
    
    //block of brightness
    if(brightnessBlockSize>0){
        blockOfBrightness = floor(screenLevel / brightnessBlockSize)+1;
    }
    else{
        // No blocksize
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
   // Pair it with hour block of day
    NSInteger blockOfDay=0;
    
    NSInteger hourBlockSize = [[[payload objectAtIndex:0] objectForKey:@"hourBlocksize"] integerValue];
    //part of day
    if(hourBlockSize>0){
        blockOfDay = floor(hourOfDay / (24/hourBlockSize))+1;
    }
    else{
        // No blocksize
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
    
    // Create assertion
    [outputArray addObject: [NSString stringWithFormat:@"H%ld-%d",(long)blockOfDay,blockOfBrightness]];
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}






@end
