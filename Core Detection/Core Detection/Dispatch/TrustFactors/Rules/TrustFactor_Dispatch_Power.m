//  TrustFactor_Dispatch_Platform.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Power.h"
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation TrustFactor_Dispatch_Power

// 37
+ (Sentegrity_TrustFactor_Output_Object *)powerLevelTime:(NSArray *)payload {
    
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
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    
    // Get the associated power level
    UIDevice *Device = [UIDevice currentDevice];
    
    Device.batteryMonitoringEnabled = YES;
    
    float batteryLevel = 0.0;
    
    float batteryCharge = [Device batteryLevel];
    
    // Can't get battery level on simulator so spoof it
#if TARGET_IPHONE_SIMULATOR
    batteryCharge = 0.5;
#endif
    
    if (batteryCharge > 0.0f) {
        batteryLevel = batteryCharge * 100;
    } else {
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    NSInteger powerBlocksize = [[[payload objectAtIndex:0] objectForKey:@"powerInBlock"] integerValue];
    
    int blockOfPower = ceilf(batteryLevel / (float)powerBlocksize);
    
    NSString *blockOfDay = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getTimeDateStringWithHourBlockSize:[[[payload objectAtIndex:0] objectForKey:@"hoursInBlock"] integerValue] withDayOfWeek:NO];
    
    // Create assertion
    [outputArray addObject: [blockOfDay stringByAppendingString: [NSString stringWithFormat:@"-P%d",blockOfPower]]];
    
    //[outputArray addObject:[NSString stringWithFormat:@"P%d",blockOfPower]];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// 38
+ (Sentegrity_TrustFactor_Output_Object *)pluggedIn:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    NSString *state= [[Sentegrity_TrustFactor_Datasets sharedDatasets] getBatteryState];
    
    if([state isEqualToString:@"pluggedFull"]){
        [outputArray addObject:state];
        
    }else if([state isEqualToString:@"pluggedCharging"]){
        
        //Only trigger if its plugged in and charging but has a high battery level
        UIDevice *Device = [UIDevice currentDevice];
        
        Device.batteryMonitoringEnabled = YES;
        
        // Can't get battery level on simulator so spoof it
        #if TARGET_IPHONE_SIMULATOR
        //batteryCharge = 0.8;
        #endif
        
        if ([Device batteryLevel] > 0.5f) {
            [outputArray addObject:state];
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

+ (Sentegrity_TrustFactor_Output_Object *)batteryState:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    NSString *state= [[Sentegrity_TrustFactor_Datasets sharedDatasets] getBatteryState];
    
    if([state isEqualToString:@"pluggedCharging"]){
        [outputArray addObject:state];
    }
    
    // Create assertion
    [outputArray addObject: state];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end