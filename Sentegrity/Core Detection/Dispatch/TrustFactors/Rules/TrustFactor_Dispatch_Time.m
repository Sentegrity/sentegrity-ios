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
    NSInteger dayOfWeek = [comps weekday];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
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
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger dayOfWeek = [comps weekday];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    NSInteger hourOfDay = [components hour];
    NSInteger minutes = [components minute];
    
    //round up if needed
    if(minutes > 30){
        hourOfDay = hourOfDay+1;
    }
    
    
    NSInteger blockOfDay=0;
    
    NSInteger blocksize = [[[payload objectAtIndex:0] objectForKey:@"blocksize"] integerValue];
    
    NSString *screenBrightness =  [NSString stringWithFormat:@"D%ld-H%ld-%.1f",(long)dayOfWeek,(long)blockOfDay,[[UIScreen mainScreen] brightness]];
    
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
    [outputArray addObject: screenBrightness];
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}






@end
