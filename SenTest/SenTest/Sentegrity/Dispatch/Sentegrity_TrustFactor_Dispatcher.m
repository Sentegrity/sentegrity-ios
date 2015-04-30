//
//  Sentegrity_TrustFactor_Dispatcher.m
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

// TODO: Fix the way NSError's are passed back between running multiple trustfactors and just one
// TODO: Fix the way TrustFactors are identified (currently by name in a large if statement)

#import "Sentegrity_TrustFactor_Dispatcher.h"
#import "Sentegrity_TrustFactor.h"

@implementation Sentegrity_TrustFactor_Dispatcher

// Run an array of trustfactors and generate candidate assertions
+ (NSArray *)performTrustFactorAnalysis:(NSArray *)trustFactors withError:(NSError **)error {
    
    // Make an array to pass back
    NSMutableArray *processedTrustFactorArray = [NSMutableArray arrayWithCapacity:trustFactors.count];
    
    // First, check if the array is valid
    if (trustFactors.count < 1 || !trustFactors) {
        // Error out, no trustfactors received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No TrustFactors received" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorsReceived userInfo:errorDetails];
    }
    
    // Next, run through the array of trustFactors to be executed
    for (Sentegrity_TrustFactor *trustFactor in trustFactors) {
        
        // Run the TrustFactor and populate output object
        Sentegrity_TrustFactor_Output *trustFactorOutput = [self executeTrustFactor:trustFactor withError:error];
        
        // Add the trustFactorOutput object to the output array
        [processedTrustFactorArray addObject:trustFactorOutput];
    }
    
    // Return the output array
    return [NSArray arrayWithArray:processedTrustFactorArray];
}

+ (Sentegrity_TrustFactor_Output *)executeTrustFactor:(Sentegrity_TrustFactor *)trustFactor withError:(NSError **)error {
    
    // run the trustfactor implementation and get candidate assertion
    Sentegrity_TrustFactor_Output *trustFactorOutput = [self executeTrustFactorImplementationWithName:trustFactor.name withPayload:trustFactor.payload andError:error];
    
    // Validate trustfactor output
    if (!trustFactorOutput) {
        // Error out, no assertion generated
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion generated" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionGenerated userInfo:errorDetails];
        
        // Create an assertion with just the trustfactor in it
        trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
        [trustFactorOutput setTrustFactor:trustFactor];
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    // Add the trustfactor object to the trustFactorOutput object as a link
    [trustFactorOutput setTrustFactor:trustFactor];
    
    // Return the output object
    return trustFactorOutput;
}

// Run a TrustFactor by its name with a given payload
+ (Sentegrity_TrustFactor_Output *)executeTrustFactorImplementationWithName:(NSString *)name withPayload:(NSArray *)payload andError:(NSError **)error {
    

    
    // Examine all the names and run the respective checks
    if ([name isEqualToString:kRoutinebadFiles]) {

        // Run the bad files check
        return [TrustFactor_Dispatch_File badFiles:payload];
        
    } else if ([name isEqualToString:kRoutinefileSizeChange]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_File fileSizeChange:payload];
        
    } else if ([name isEqualToString:kRoutinebadProcesses]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Process badProcesses:payload];
        
    } else if ([name isEqualToString:kRoutinenewRootProcess]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Process newRootProcess:payload];
        
    } else if ([name isEqualToString:kRoutinebadProcessPath]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Process badProcessPath:payload];
        
    } else if ([name isEqualToString:kRoutinehighRiskApp]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Process highRiskApp:payload];
        
    } else if ([name isEqualToString:kRoutinebadNetDst]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Netstat badNetDst:payload];
        
    } else if ([name isEqualToString:kRoutinepriviledgedNetServices]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Netstat priviledgedNetServices:payload];
        
    } else if ([name isEqualToString:kRoutinenewNetService]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Netstat newNetService:payload];
        
    } else if ([name isEqualToString:kRoutineunencryptedTraffic]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Netstat unencryptedTraffic:payload];
        
    } else if ([name isEqualToString:kRoutinesandboxVerification]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Sandbox sandboxVerification:payload];
        
    } else if ([name isEqualToString:kRoutinebadURIHandlers]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Http badURIHandlers:payload];
        
    } else if ([name isEqualToString:kRoutinesubscribeTamper]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Subscriber subscribeTamper:payload];
        
    } else if ([name isEqualToString:kRoutinevulnerableSubscriber]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Subscriber vulnerableSubscriber:payload];
        
    } else if ([name isEqualToString:kRoutinepolicyTamper]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_CoreDetection policyTamper:payload];
        
    } else if ([name isEqualToString:kRoutinesystemProtectMode]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_CoreDetection systemProtectMode:payload];
        
    } else if ([name isEqualToString:kRoutineuserProtectMode]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_CoreDetection userProtectMode:payload];
        
    } else if ([name isEqualToString:kRoutineselfTamper]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Sentegrity selfTamper:payload];
        
    } else if ([name isEqualToString:kRoutinesentegrityVersion]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Sentegrity sentegrityVersion:payload];
        
    } else if ([name isEqualToString:kRoutineapSoho]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Wifi apSoho:payload];
        
    } else if ([name isEqualToString:kRoutineapHotspotter]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Wifi apHotspotter:payload];
        
    } else if ([name isEqualToString:kRoutinewifiEncType]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Wifi wifiEncType:payload];
        
    } else if ([name isEqualToString:kRoutinessidAllowed]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Wifi ssidAllowed:payload];
        
    } else if ([name isEqualToString:kRoutinevulnerablePlatform]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Platform vulnerablePlatform:payload];
        
    } else if ([name isEqualToString:kRoutineplatformVersionAllowed]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Platform platformVersionAllowed:payload];
        
    } else if ([name isEqualToString:kRoutinepowerPercent]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Platform powerPercent:payload];
        
    } else if ([name isEqualToString:kRoutineshortUptime]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Platform shortUptime:payload];
        
    } else if ([name isEqualToString:kRoutinetimeAllowed]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Time timeAllowed:payload];
        
    } else if ([name isEqualToString:kRoutineaccessTime]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Time accessTime:payload];
        
    } else if ([name isEqualToString:kRoutinelocationAllowed]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Location locationAllowed:payload];
        
    } else if ([name isEqualToString:kRoutinelocation]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Location location:payload];
        
    } else if ([name isEqualToString:kRoutinedeviceMovement]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Sensor deviceMovement:payload];
        
    } else if ([name isEqualToString:kRoutinedevicePosition]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Sensor devicePosition:payload];
        
    } else if ([name isEqualToString:kRoutinebluetoothPaired]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Bluetooth bluetoothPaired:payload];
        
    } else if ([name isEqualToString:kRoutinebluetoothLEScan]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Bluetooth bluetoothLEScan:payload];
        
    } else if ([name isEqualToString:kRoutineupnpScan]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Scan upnpScan:payload];
        
    } else if ([name isEqualToString:kRoutinebonjourScan]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Scan bonjourScan:payload];
        
    } else if ([name isEqualToString:kRoutineactivity]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Activity activity:payload];
        
    } else if ([name isEqualToString:kRoutinevpnUp]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Route vpnUp:payload];
        
    } else if ([name isEqualToString:kRoutinenoRoute]) {
        
        // Run the file size change check
        return [TrustFactor_Dispatch_Route noRoute:payload];
        
    } else {
        
        // No check recognized, error out
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No valid TrustFactor found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidTrustFactorName userInfo:errorDetails];
        
    }
    
    // Return nothing
    return nil;
}

@end
