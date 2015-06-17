//
//  TrustFactor_Dispatch_File.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_File.h"
#import <sys/stat.h>

@implementation TrustFactor_Dispatch_File

// 1 - knownBad files check
+ (Sentegrity_TrustFactor_Output_Object *)knownBad:(NSArray *)payload {
    
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
    
    // Get the filemanager singleton
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    // Run through all the files in the payload
    for (NSString *path in payload) {
        
        // Check if they exist
        if ([fileMan fileExistsAtPath:path]) {
           
            // If the bad file exists, mark it in the array
            [outputArray addObject:path];

        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// 10 - fileSize check
+ (Sentegrity_TrustFactor_Output_Object *)sizeChange:(NSArray *)payload {
    
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
    
    // Get the filemanager singleton
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    // Create the output array
    NSMutableArray *fileSizes = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Run through all the files in the payload
    for (NSString *path in payload) {
        
        // Check if they exist
        if ([fileMan fileExistsAtPath:path]) {
            // Found the file
            
            // Create an error object
            NSError *error;
            
            // Get the filesize (in bytes) of the given file
            unsigned long long fileSize = [[fileMan attributesOfItemAtPath:path error:&error] fileSize];
            
            // Check if there was an error
            if (error || error != nil) {
                // Error
                
                // TODO: Remove log statements
                // Log it
                NSLog(@"Error found in TrustFactor: sizeChange, Error: %@", error.localizedDescription);
                
                // Set the output status code to bad
                [trustFactorOutputObject setStatusCode:DNEStatus_error];
            } else {
                // No error
                
                // Add the file size to the output array
                [fileSizes addObject:[NSNumber numberWithUnsignedLongLong:fileSize]];
            }
            
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:fileSizes];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

//for future use
+ (BOOL)doFstabSize {
    struct stat sb;
    stat("/etc/fstab", &sb);
    long long size = sb.st_size;
    if (size == 80){
        return NO;
    }
    return YES;
    
}

@end
