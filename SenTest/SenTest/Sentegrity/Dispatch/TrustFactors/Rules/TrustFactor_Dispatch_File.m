//
//  TrustFactor_Dispatch_File.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_File.h"

@implementation TrustFactor_Dispatch_File

// 1 badFiles function - checking for existence of bad files, if files exist, fail, and returning either 1 or 0 and the files that failed
+ (Sentegrity_TrustFactor_Output *)badFiles:(NSArray *)files {
    
    // Validate the files array
    if (!files || files.count < 1 || files == nil) {
        
        // Invalid input
        
        // Create our return output
        Sentegrity_TrustFactor_Output *trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
        [trustFactorOutput setExecuted:NO];
        [trustFactorOutput setStatusCode:DNEStatus_error];
        [trustFactorOutput setRunDate:[NSDate date]];
        
        //JS-Beta2: We need to add a set for the "assertion" attribute and new method call, a method that creates the assertion by taking the output (badfiles here) and returns the hashed value
        
        // Return nothing
        return trustFactorOutput;
    }
    
    // Create array variable
    NSMutableArray *badFiles = [[NSMutableArray alloc] initWithCapacity:files.count];
    
    // Create int variable
    NSNumber *returnValue = [[NSNumber alloc] initWithInt:0];
    
    // Check for existence of bad files with NSFileManager
    
    // Get the singleton instance of the filemanager
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    // Run through all the files in the array
    for (NSString *path in files) {
        // Checking if they exist
        if ([fileMan fileExistsAtPath:path]) {
           
            // If the bad file exists, mark it in the array
            [badFiles addObject:path];
            // Set the return value to 1
            returnValue = [NSNumber numberWithInt:1];
        }
    }
    
    // Create our return output
    Sentegrity_TrustFactor_Output *trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
    [trustFactorOutput setReturnResult:returnValue];
    [trustFactorOutput setOutput:badFiles];
    [trustFactorOutput setExecuted:YES];
    [trustFactorOutput setStatusCode:DNEStatus_ok];
    [trustFactorOutput setRunDate:[NSDate date]];
    
    //JS-Beta2: We need to add a set for the "assertion" attribute and new method call, a method that creates the assertion by taking the output (badfiles here) and returns the hashed value
    
    // Return nothing
    return trustFactorOutput;
}

// 10
+ (Sentegrity_TrustFactor_Output *)fileSizeChange:(NSArray *)filesizes {
    return 0;
}
@end
