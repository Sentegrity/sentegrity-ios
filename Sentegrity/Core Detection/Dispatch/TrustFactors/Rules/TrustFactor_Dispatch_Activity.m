//
//  TrustFactor_Dispatch_Activity.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Activity.h"

@implementation TrustFactor_Dispatch_Activity



// 39
+ (Sentegrity_TrustFactor_Output_Object *)previous:(NSArray *)payload {
    
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
    
    // Get the user's activity history
    NSArray *previousActivities;
    
    
    // Check if error was already determined when activity was started
    if ([self activityDNEStatus] != 0 ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[self activityDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    } else {
        // No known errors occured previously, try to get dataset and check our object
        
        previousActivities = [self previousActivitiesInfo];
        
        // Check activity dataset again
        if (!previousActivities || previousActivities == nil || previousActivities.count < 1) {
            
            [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
            
            // Return with the blank output object
            return trustFactorOutputObject;
        }
    }
    
    
    float stillCount = 0;
    float movingCount = 0;
    float movingFastcount = 0;
    float unknownCount = 0;
    NSString *lastActivity;
    
    // Check each category for hit since lots of activities are returned in most cases
    for (CMMotionActivity *actItem in previousActivities)
    {
        
        // High confidence
        if(actItem.confidence == 2){
            
            if (actItem.stationary == 1){
                stillCount = stillCount + 2;
            }else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
                movingCount = movingCount + 2;
            }else if (actItem.automotive == 1){
                movingFastcount = movingFastcount + 2;
            }
            else{
                unknownCount = unknownCount + 2;
            }

            
        }
        
        // Medium confidence
        if(actItem.confidence == 1){
            
            if (actItem.stationary == 1){
                stillCount++;
            }else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
                movingCount++;
            }else if (actItem.automotive == 1){
                movingFastcount++;
            }
            else{
                unknownCount++;
            }
            

        }
        
        // Low confidence
        if(actItem.confidence == 0){
            
            if (actItem.stationary == 1){
                stillCount = stillCount + 0.5;
            }else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
                movingCount = movingCount + 0.5;
            }else if (actItem.automotive == 1){
                movingFastcount = movingFastcount + 0.5;
            }
            else{
                unknownCount = unknownCount + 0.5;
            }
            
            
        }
        
       // NSLog(@"Got a PREVIOUS core motion update");
        //NSLog(@"Previous activity date is %f",actItem.timestamp);
        //NSLog(@"Previous activity confidence from a scale of 0 to 2 - 2 being best- is: %ld",actItem.confidence);
        //NSLog(@"Previous activity type is unknown: %i",actItem.unknown);
        //NSLog(@"Previous activity type is stationary: %i",actItem.stationary);
        //NSLog(@"Previous activity type is walking: %i",actItem.walking);
        //NSLog(@"Previous activity type is running: %i",actItem.running);
        //NSLog(@"Previous activity type is cycling: %i",actItem.cycling);
        //NSLog(@"Previous activity type is automotive: %i",actItem.automotive);
    }
    
    if(stillCount >= movingCount && stillCount >= movingFastcount && stillCount >= unknownCount){
        lastActivity = @"still";
    }else if(movingCount > stillCount && movingCount > movingFastcount && movingCount > unknownCount) {
        lastActivity = @"moving";
    }else if(movingFastcount > stillCount && movingFastcount > movingCount && movingFastcount > unknownCount){
        lastActivity = @"movingFast";
    }else{
        lastActivity=@"unknown";
    }
    
    NSLog(@"Previous activity result: %@", lastActivity);
    

    
    // Profile against hour of day
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    NSInteger hourOfDay = [components hour];
    NSInteger minutes = [components minute];
    
    
    //round up if needed
    if(minutes > 30){
        hourOfDay = hourOfDay+1;
    }
    
    
    
    // Hours partitioned across 24, adjust accordingly but it does impact multiple rules
    // Hour block from policy
    int hourBlockSize = [[[payload objectAtIndex:0] objectForKey:@"hourBlockSize"] intValue];
    
    // Block of day
    NSInteger blockOfDay = floor(hourOfDay / (24/hourBlockSize))+1;
    
    NSString *dateString =  [NSString stringWithFormat:@"H%ld_",(long)blockOfDay];
    
    // Merge with activity and hour
    [outputArray addObject:[dateString stringByAppendingString:lastActivity]];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

// 39
+ (Sentegrity_TrustFactor_Output_Object *)current:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];


    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    
    // Get the user's current activity
    CMMotionActivity *currentActivity;
    
    
    // Check if error was already determined when activity was started
    if ([self activityDNEStatus] != 0 ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[self activityDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    } else {
        // No known errors occured previously, try to get dataset and check our object
        
        currentActivity = [self currentActivityInfo];
        
        // Check activity dataset again
        if (!currentActivity || currentActivity == nil) {
            
            [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
            
            // Return with the blank output object
            return trustFactorOutputObject;
        }
    }
    
    NSString *activity;
    // If we're confident then take it and don't look at the others returned
    if(currentActivity.confidence == 2){
        
        if (currentActivity.stationary == 1){
            activity = @"still";
        }
        else if (currentActivity.cycling == 1 || currentActivity.walking == 1 || currentActivity.running ==1 || currentActivity.automotive==1){
            activity = @"moving";
        }
        else{
            activity = @"unknown";
        }
        
    }else{
        activity = @"unknown";
    }
    
    //NSLog(@"Got a PREVIOUS core motion update");
    //NSLog(@"Previous activity date is %f",currentActivity.timestamp);
    //NSLog(@"Previous activity confidence from a scale of 0 to 2 - 2 being best- is: %ld",currentActivity.confidence);
    //NSLog(@"Previous activity type is unknown: %i",currentActivity.unknown);
    //NSLog(@"Previous activity type is stationary: %i",currentActivity.stationary);
    //NSLog(@"Previous activity type is walking: %i",currentActivity.walking);
    //NSLog(@"Previous activity type is running: %i",currentActivity.running);
    //NSLog(@"Previous activity type is cycling: %i",currentActivity.cycling);
    //NSLog(@"Previous activity type is automotive: %i",currentActivity.automotive);
    
    NSLog(@"Current activity result: %@", activity);
    [outputArray addObject:activity];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



@end
