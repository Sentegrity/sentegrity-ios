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
+ (Sentegrity_TrustFactor_Output_Object *)knownBad:(NSArray *)payload {
    
    //CREATE RETURN OBJECT
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    //SET REUSABLE DATA ACQUISITION METHOD
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    //CREATE OUTPUT ARRAY
    NSMutableArray *badFiles = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    
    // Run through all the files in the array
    for (NSString *path in payload) {
        // Checking if they exist
        if ([fileMan fileExistsAtPath:path]) {
           
            // If the bad file exists, mark it in the array
            [badFiles addObject:path];

        }
    }
    
   
    //SET OUTPUT (regardless if empty)
    [trustFactorOutputObject setOutput:badFiles];
    
    //OVERRIDE STATUS CODE (default = DNEStatus_ok)

    
    //RETURN
    return trustFactorOutputObject;
}

// 10
+ (Sentegrity_TrustFactor_Output_Object *)sizeChange:(NSArray *)payload {
    return 0;
}
@end
