//  TrustFactor_Dispatch_Configuration.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "TrustFactor_Dispatch_Configuration.h"
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation TrustFactor_Dispatch_Configuration


// Is iCloud enabled?
+ (Sentegrity_TrustFactor_Output_Object *)backupEnabled:(NSArray *)payload {
    
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
    
    
    // Is iCloud enabled
    if([[NSFileManager defaultManager] ubiquityIdentityToken] != nil){
        [outputArray addObject:@"backupEnabled"];
    }
    
    NSDictionary* status = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getStatusBar];
    NSNumber* isSyncing = [status valueForKey:@"isBackingUp"];
    
    
    if([isSyncing intValue]==1){
        [outputArray addObject:@"backupInProgress"];
    }

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// Does the user use a passcode?
+ (Sentegrity_TrustFactor_Output_Object *)passcodeSet:(NSArray *)payload {
    
    // Create the trustfactor output object
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    //only supported on iOS 8
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        
        static NSData *password = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            password = [NSKeyedArchiver archivedDataWithRootObject:NSStringFromSelector(_cmd)];
        });
        
        NSDictionary *query = @{
                                (__bridge id <NSCopying>)kSecClass: (__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecAttrService: @"UIDevice-PasscodeStatus_KeychainService",
                                (__bridge id)kSecAttrAccount: @"UIDevice-PasscodeStatus_KeychainAccount",
                                (__bridge id)kSecReturnData: @YES,
                                };
        
        CFErrorRef sacError = NULL;
        SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kNilOptions, &sacError);
        
        // Unable to create the access control item.
        if (sacObject == NULL || sacError != NULL) {
            
            // Set status code to unavailable
            [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
            
            // Set the trustfactor output to the output array (regardless if empty)
            [trustFactorOutputObject setOutput:outputArray];
            
            // Return the trustfactor output object
            return trustFactorOutputObject;
        }
        
        NSMutableDictionary *setQuery = [query mutableCopy];
        setQuery[(__bridge id) kSecValueData] = password;
        setQuery[(__bridge id) kSecAttrAccessControl] = (__bridge id) sacObject;
        
        OSStatus status;
        status = SecItemAdd((__bridge CFDictionaryRef)setQuery, NULL);
        
        // if we have the object, release it.
        if (sacObject) {
            CFRelease(sacObject);
            sacObject = NULL;
        }
        
        // if it failed to add the item.
        if (status == errSecDecode) {
            [outputArray addObject:@"passcodeNotSet"];
        }
        else{ //try copy
            
            status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
            
            // it managed to retrieve data successfully
            if (status != errSecSuccess) {
                [outputArray addObject:@"passcodeNotSet"];
            }

            
        }
        
        
    } else {
        
        // Set status code to unavailable
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Set the trustfactor output to the output array (regardless if empty)
        [trustFactorOutputObject setOutput:outputArray];
        
        // Return the trustfactor output object
        return trustFactorOutputObject;
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

@end