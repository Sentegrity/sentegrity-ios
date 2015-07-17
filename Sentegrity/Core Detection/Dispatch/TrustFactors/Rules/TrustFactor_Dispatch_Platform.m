//  TrustFactor_Dispatch_Platform.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Platform.h"
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation TrustFactor_Dispatch_Platform


// 23
+ (Sentegrity_TrustFactor_Output_Object *)vulnerableVersion:(NSArray *)payload {
    
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
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    NSString* currentVersion =  [[UIDevice currentDevice] systemVersion] ;
    
    if (!currentVersion) {
        // NO VERSION
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check blacklist
    for (NSString *badVersions in payload) {
        if([badVersions containsString:@"-"]){ //range of version numbers
            NSArray* range = [badVersions componentsSeparatedByString:@"-"];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO([range objectAtIndex:0]) && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO([range objectAtIndex:1])) {
                [outputArray addObject:currentVersion];
                break;
            }
        }
        else if([badVersions containsString:@"*"]){ //wild card version number
            NSArray* range = [badVersions componentsSeparatedByString:@"*"];
            // Check for version match
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO([range objectAtIndex:0])) {
                [outputArray addObject:currentVersion];
                break;
            }
        }
        else{ //specific version
            if (SYSTEM_VERSION_EQUAL_TO(badVersions)) {
                [outputArray addObject:currentVersion];
                break;
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}



// 28
+ (Sentegrity_TrustFactor_Output_Object *)versionAllowed:(NSArray *)payload {
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
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    NSString* currentVersion =  [[UIDevice currentDevice] systemVersion] ;
    
    if (!currentVersion) {
        // NO VERSION
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    //Check whitelist
    BOOL allowed=NO;
    for (NSString *allowedVersions in payload) {
        if([allowedVersions containsString:@"-"]){ //range of version numbers
            NSArray* range = [allowedVersions componentsSeparatedByString:@"-"];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO([range objectAtIndex:0]) && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO([range objectAtIndex:1])) {
                allowed=YES;
                break;
            }
        }
        else if([allowedVersions containsString:@"*"]){ //wild card version number
            NSArray* range = [allowedVersions componentsSeparatedByString:@"*"];
            // Check for version match
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO([range objectAtIndex:0])) {
                allowed=YES;
                break;
            }
        }
        else{ //specific version
            if (SYSTEM_VERSION_EQUAL_TO(allowedVersions)) {
                allowed=YES;
                break;
            }
        }
    }
    
    if(!allowed){ //version not allowed
        [outputArray addObject:currentVersion];
    }
    
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}


// 37
+ (Sentegrity_TrustFactor_Output_Object *)unknownPowerLevel:(NSArray *)payload {
    
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
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    UIDevice *Device = [UIDevice currentDevice];
    
    Device.batteryMonitoringEnabled = YES;
    
    float batteryLevel = 0.0;
    
    float batteryCharge = [Device batteryLevel];
    
    if (batteryCharge > 0.0f) {
        batteryLevel = batteryCharge * 100;
    } else {
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    NSInteger blockOfPower;
    
    NSInteger blocksize = [[[payload objectAtIndex:0] objectForKey:@"blocksize"] integerValue];
    //part of day
    if(blocksize>0){
        blockOfPower = floor(batteryLevel / (100/blocksize))+1;
    }
    else{
        // No blocksize
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    [outputArray addObject:[NSString stringWithFormat:@"B%ld",blockOfPower]];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}


// 38
+ (Sentegrity_TrustFactor_Output_Object *)shortUptime:(NSArray *)payload {
    
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
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    NSTimeInterval uptime = [[NSProcessInfo processInfo] systemUptime];
    
    
    if (!uptime) {
        
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    int secondsInHour = 3600;
    double hoursUp = uptime/secondsInHour;
    
    // less than desired uptime
    if(hoursUp < [[payload objectAtIndex:0] integerValue])
    {
        [outputArray addObject:[NSNumber numberWithInt:hoursUp]];
    }
    
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
    
    
    UIDevice *Device = [UIDevice currentDevice];
    
    Device.batteryMonitoringEnabled = YES;
    
    // Check the battery state
    if ([Device batteryState] == UIDeviceBatteryStateCharging || [Device batteryState] == UIDeviceBatteryStateFull) {
        // Device is charging
        [outputArray addObject:[NSNumber numberWithLong:UIDeviceBatteryStateCharging]];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// 38
+ (Sentegrity_TrustFactor_Output_Object *)backupEnabled:(NSArray *)payload {
    
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
    
    BOOL backupEnabled=NO;
    
    //is backup procs found?
    // Get the current processes
    NSArray *currentProcesses = [self processInfo];
    
    // Current process name
    NSString *procName;
    
    // Check the array
    if (!currentProcesses || currentProcesses == nil || currentProcesses.count < 1) {
        // Current Processes array is EMPTY
        
        // Set the DNE status code to UNAVAILABLE
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the process information
    for (NSDictionary *processData in currentProcesses) {
        
        // Get the current process name
        procName = [processData objectForKey:@"Name"];
        
        // Iterate through payload names and look for matching processes
        for (NSString *backupProcs in payload) {
            
            // Check if the process name is equal to the current process being viewed
            if([backupProcs isEqualToString:procName]) {
                backupEnabled=YES;
            }
        }
    }
    
    // Make sure a correct Ubiquity Container Identifier is passed
    NSURL *ubiquityURL = [[NSFileManager defaultManager]
                          URLForUbiquityContainerIdentifier:@"ABCDEFGHI0.com.acme.MyApp"];
    
    //is iCloud enabled
    if(ubiquityURL){
        backupEnabled=YES;
    }
    
    
    if(backupEnabled){
        [outputArray addObject:@"backupEnabled"];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}


+ (Sentegrity_TrustFactor_Output_Object *)passcodeSet:(NSArray *)payload {
    
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
    
    
    //only supported on iOS 8
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        
        if (&kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly != NULL) {
            
            static NSData *password = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                password = [NSKeyedArchiver archivedDataWithRootObject:NSStringFromSelector(_cmd)];
            });
            
            NSDictionary *query = @{
                                    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecAttrService: @"UIDevice-PasscodeStatus_KeychainService",
                                    (__bridge id)kSecAttrAccount: @"UIDevice-PasscodeStatus_KeychainAccount",
                                    (__bridge id)kSecReturnData: @YES,
                                    };
            
            CFErrorRef sacError = NULL;
            SecAccessControlRef sacObject;
            sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kNilOptions, &sacError);
            
            // unable to create the access control item.
            if (sacObject == NULL || sacError != NULL) {
                [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
                
                // Set the trustfactor output to the output array (regardless if empty)
                [trustFactorOutputObject setOutput:outputArray];
                
                // Return the trustfactor output object
                return trustFactorOutputObject;
            }
            
            
            NSMutableDictionary *setQuery = [query mutableCopy];
            [setQuery setObject:password forKey:(__bridge id)kSecValueData];
            [setQuery setObject:(__bridge id)sacObject forKey:(__bridge id)kSecAttrAccessControl];
            
            OSStatus status;
            status = SecItemAdd((__bridge CFDictionaryRef)setQuery, NULL);
            
            // if it failed to add the item.
            if (status == errSecDecode) {
                [outputArray addObject:[NSNumber numberWithInt:status]];
            }
            
            status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
            
            // it managed to retrieve data successfully
            if (status == errSecSuccess) {
                //enabled
            }
            else
            {
                // not sure what happened, returning unknown
                [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
            
                // Set the trustfactor output to the output array (regardless if empty)
                [trustFactorOutputObject setOutput:outputArray];
            
                // Return the trustfactor output object
                return trustFactorOutputObject;
            
            }
        
        }
    }
    else{
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Set the trustfactor output to the output array (regardless if empty)
        [trustFactorOutputObject setOutput:outputArray];
        
        // Return the trustfactor output object
        return trustFactorOutputObject;
    }
    
    [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;

}

@end