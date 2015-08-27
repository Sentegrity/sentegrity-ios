//
//  TrustFactor_Dispatch_Sandbox.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Sandbox.h"
#import <sys/stat.h>

@implementation TrustFactor_Dispatch_Sandbox

// 8 - Sandbox API Verification and Kernel Configurations - Basically Jailbreak Checks
+ (Sentegrity_TrustFactor_Output_Object *)integrity:(NSArray *)payload {
    
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
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Get the current process environment info
    NSDictionary *environmentInfo = [[NSProcessInfo processInfo] environment];

    // Check if we're not sandboxed
    if ([environmentInfo objectForKey:@"APP_SANDBOX_CONTAINER_ID"] != nil) {
        
        [outputArray addObject:[@"APP_SANDBOX_CONTAINER_ID_Found" stringByAppendingString:[[environmentInfo objectForKey:@"APP_SANDBOX_CONTAINER_ID"] stringValue]]];
    }
    
    // Check if DYLD_INSERT_LIBRARY path is available (JBs only)
    if ([environmentInfo objectForKey:@"DYLD_INSERT_LIBRARIES"]) {
        // Check if the environment info responds to stringvalue selectors
        if ([[environmentInfo objectForKey:@"DYLD_INSERT_LIBRARIES"] respondsToSelector:@selector(stringValue)]) {
            // Add it to the array
            [outputArray addObject:[@"DYLD_INSERT_LIBRARIES_Found" stringByAppendingString:[[environmentInfo objectForKey:@"DYLD_INSERT_LIBRARIES"] stringValue]]];
        }
    }

    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    // Check for shell
    if (system(0)) { //returned 1 therefore device is JB'ed
        [outputArray addObject:@"systemCmdWorks"];
    }
    #pragma GCC diagnostic pop
    
    // Check for fork
    if (fork() >= 0) { /* If the fork succeeded, we're jailbroken */
            [outputArray addObject:@"forkCmdWorks"];
    }

    // Check for sym links
    struct stat s;
    for (NSString *file in payload) {
        if (!lstat([file cStringUsingEncoding:NSASCIIStringEncoding], &s)) {
            if (s.st_mode & S_IFLNK) [outputArray addObject:[@"symlink_" stringByAppendingString:file]];
        }

    }
    
    NSError *error;
    
    [[NSString stringWithFormat:@"test"] writeToFile:@"/private/cache.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (nil == error){
        [outputArray addObject:@"writeRestrictedFile"];
    }
    else{
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/test_jb.txt" error:nil];
    }

    FILE *file = fopen("/bin/ssh", "r");
    
    if (file){
        [outputArray addObject:@"readRestrictedFile"];
    }

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];

    // Return the trustfactor output object
    return trustFactorOutputObject;
}

//helper functions






@end
