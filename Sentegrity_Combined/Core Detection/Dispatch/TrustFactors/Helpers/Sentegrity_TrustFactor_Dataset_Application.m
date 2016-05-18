 //
//  Sentegrity_TrustFactor_Dataset_Application.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Dataset_Application.h"
#include <objc/runtime.h>

//
// Private headers
//
#import "LSApplicationWorkspace.h"
#import "LSApplicationProxy.h"

@implementation App_Info : NSObject

// USES PRIVATE API
+ (NSArray *)getUserAppInfo {
    
        // Get the list of processes and all information about them
        @try {
            
            //App types:
            // $_LSUserApplicationType
            // $_LSInternalApplicationType
            // $_LSSystemApplicationType
            
            _ApplicationType appType = $_LSUserApplicationType;
            
            //This originally objc_getClass() LSApplicationWorkspace
            //I broke up the string and added (__bridge void *) but now the API call returns nothing
            
            NSString *appClass = [NSString stringWithFormat:@"%@%@%@", @"LSA", @"pplication", @"Workspace"];
            NSArray* apps = [[NSClassFromString(appClass) defaultWorkspace] applicationsOfType:appType];
            
            apps = [apps filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LSApplicationProxy *evaluatedObject, NSDictionary *bindings)
                {
                        return [evaluatedObject localizedShortName].length > 0;
                }]];
            
            NSMutableArray* userApps = [NSMutableArray array];

            for (LSApplicationProxy* application in apps)
            {
                
                // Create an array of the objects
                NSArray *ItemArray = [NSArray arrayWithObjects:[application localizedShortName],[application bundleIdentifier], [application bundleVersion], nil];
    
                // Create an array of keys
                NSArray *KeyArray = [NSArray arrayWithObjects:@"name", @"bundleID", @"bundleVersion", nil];
                
                // Create the dictionary
                NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                
                // Add the objects to the array
                [userApps addObject:dict];

            }
            
            return userApps;
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
}

@end