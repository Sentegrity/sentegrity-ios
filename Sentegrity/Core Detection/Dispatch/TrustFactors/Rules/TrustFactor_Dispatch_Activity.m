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
    

    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the user's activity history
    NSArray *previousActivities;
    
    
    // Check if error was already determined when activity was started
    if ([[Sentegrity_TrustFactor_Datasets sharedDatasets] activityDNEStatus] != 0 ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[Sentegrity_TrustFactor_Datasets sharedDatasets] activityDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    } else {
        // No known errors occured previously, try to get dataset and check our object
        
        previousActivities = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getPreviousActivityInfo];
        
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
                stillCount = stillCount + 1;
            }else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
                movingCount = movingCount + 1;
            }else if (actItem.automotive == 1){
                movingFastcount = movingFastcount + 1;
            }
            else{
                unknownCount = unknownCount + 1;
            }

            
        }
        
        // Medium confidence
        //if(actItem.confidence == 1){
        
           // if (actItem.stationary == 1){
           //     stillCount = stillCount + 0.5;
           // }else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
           //     movingCount = movingCount + 0.5;
           // }else if (actItem.automotive == 1){
           //     movingFastcount = movingFastcount + 0.5;
           // }
           // else{
           //     unknownCount = unknownCount + 0.5;
           // }
            

       // }
        
        // Low confidence
        //if(actItem.confidence == 0){

            //if (actItem.stationary == 1){
            //    stillCount = stillCount + 0.5;
           // }else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
            //    movingCount = movingCount + 0.5;
           // }else if (actItem.automotive == 1){
            //    movingFastcount = movingFastcount + 0.5;
            //}
           // else{
           //     unknownCount = unknownCount + 0.5;
           // }
            
            
        //}
        
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
    
    //NSLog(@"Previous activity result: %@", lastActivity);
    
    // Hours partitioned across 24, adjust accordingly but it does impact multiple rules
    // Hour block from policy

    NSString *blockOfDay = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getTimeDateStringWithHourBlockSize:[[[payload objectAtIndex:0] objectForKey:@"hoursInBlock"] integerValue] withDayOfWeek:NO];
    
    NSString *activityString =  [blockOfDay stringByAppendingString:[NSString stringWithFormat:@"-%@",lastActivity]];
    
    // Merge with activity and hour
    [outputArray addObject:activityString];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



@end
