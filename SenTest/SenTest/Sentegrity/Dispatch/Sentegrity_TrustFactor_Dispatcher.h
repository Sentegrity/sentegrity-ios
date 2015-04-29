//
//  Sentegrity_TrustFactor_Dispatcher.h
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

// Assertions
#import "Sentegrity_Assertion.h"

// TrustFactors
#import "TrustFactor_Dispatch_Activity.h"
#import "TrustFactor_Dispatch_Bluetooth.h"
#import "TrustFactor_Dispatch_CoreDetection.h"
#import "TrustFactor_Dispatch_File.h"
#import "TrustFactor_Dispatch_Http.h"
#import "TrustFactor_Dispatch_Location.h"
#import "TrustFactor_Dispatch_Netstat.h"
#import "TrustFactor_Dispatch_Platform.h"
#import "TrustFactor_Dispatch_Process.h"
#import "TrustFactor_Dispatch_Route.h"
#import "TrustFactor_Dispatch_Sandbox.h"
#import "TrustFactor_Dispatch_Scan.h"
#import "TrustFactor_Dispatch_Sensor.h"
#import "TrustFactor_Dispatch_Sentegrity.h"
#import "TrustFactor_Dispatch_Subscriber.h"
#import "TrustFactor_Dispatch_Time.h"
#import "TrustFactor_Dispatch_Wifi.h"

@interface Sentegrity_TrustFactor_Dispatcher : NSObject

// TODO: BETA2 Set a time limit and execute DNE's

// Run an array of trustfactors
+ (NSArray *)generateTrustFactorAssertions:(NSArray *)trustFactors withError:(NSError **)error;

// Generate the output from a single TrustFactor
+ (Sentegrity_Assertion *)performTrustFactor:(Sentegrity_TrustFactor *)trustFactor withError:(NSError **)error;

// Run an individual trustfactor with just the name and the payload (returned assertion will not be able to identify the trustfactor that was run)
+ (Sentegrity_Assertion *)runTrustFactorWithName:(NSString *)name withPayload:(NSArray *)payload andError:(NSError **)error;

@end
