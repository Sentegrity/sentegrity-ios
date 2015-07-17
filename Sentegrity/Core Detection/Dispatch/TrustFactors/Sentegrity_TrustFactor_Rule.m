//
//  TrustFactor_Dispatch.m
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"
#import "Sentegrity_TrustFactor_Dataset_Routes.h"
#import "Sentegrity_TrustFactor_Dataset_Process.h"

// This class is designed to cache the results of datasets between the TrustFactor_Dispatch_[Rule] and Sentegrity_TrustFactor_Dataset_[Category]

@implementation Sentegrity_TrustFactor_Rule


// Validate the given payload
+ (BOOL)validatePayload:(NSArray *)payload {
    
    // Check if the payload is empty
    if (!payload || payload == nil || payload.count < 1) {
        return NO;
    }
    
    // Return Valid
    return YES;
}

// PROCESS: Process info
static NSArray* processData;
+ (NSArray *)processInfo {
    
    if(!processData || processData==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            processData = [Process_Info getProcessInfo];
            return routeData;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }

    }
    else //already populated
    {
        return processData;
    }
}

// PROCESS: Process PID
static NSNumber *ourPID;
+ (NSNumber *)getOurPID {
      // Get the PID 
      @try {
          
          ourPID = [Process_Info getOurPID];
          return ourPID;
          
      }
      @catch (NSException * ex) {
          // Error
          return nil;
      }
}



// Route Data
static NSArray* routeData;
+ (NSArray *)routeInfo {
    
    if(!routeData || routeData==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            routeData = [Route_Info getRoutes];
            return routeData;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
    }
    else //already populated
    {
        return routeData;
    }
}

// WiFi router address
static NSString* wiFiRouterAddress;
+ (NSString *)wiFiRouterAddress {
    
    if(!wiFiRouterAddress || wiFiRouterAddress==nil) //dataset not populated
    {
        // Get the router address
        @try {
            
            wiFiRouterAddress = [Route_Info wiFiRouterAddress];
            return wiFiRouterAddress;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
    }
    else //already populated
    {
        return wiFiRouterAddress;
    }
}

@end

