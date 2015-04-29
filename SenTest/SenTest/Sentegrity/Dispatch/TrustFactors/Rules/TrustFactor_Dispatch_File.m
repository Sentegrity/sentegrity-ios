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
    
    // Create our return assertion
    Sentegrity_TrustFactor_Output *assertion = [[Sentegrity_TrustFactor_Output alloc] init];
    [assertion setReturnResult:returnValue];
    [assertion setOutput:badFiles];
    [assertion setRan:YES];
    [assertion setRunDate:[NSDate date]];
    
    // Return nothing
    return assertion;
}

// 10
+ (Sentegrity_TrustFactor_Output *)fileSizeChange:(NSArray *)filesizes {
    return 0;
}
@end
