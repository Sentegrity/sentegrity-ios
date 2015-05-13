//
//  Sentegrity_TrustFactor_Dispatcher.m
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

// TODO: Fix the way NSError's are passed back between running multiple trustfactors and just one
#import "Sentegrity_TrustFactor_Dispatcher.h"
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_Constants.h"

// Pod for hashing
#import "NSString+Hashes.h"

// Import the objc runtime to get class by name
#import <objc/objc-runtime.h>

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
    Sentegrity_TrustFactor_Output *trustFactorOutput = [self runTrustFactorWithDispatch:trustFactor.dispatch andImplementation:trustFactor.implementation withPayload:trustFactor.payload andError:error];
    
    // Validate trustfactor output
    if (!trustFactorOutput || trustFactorOutput == nil) {
        // Error out, no assertion generated
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion generated" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionGenerated userInfo:errorDetails];
        
        // Create an assertion with just the trustfactor in it
        trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
        [trustFactorOutput setTrustFactor:trustFactor];
        // Set that it did not run
        [trustFactorOutput setExecuted:NO];
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    // Add the trustfactor object to the trustFactorOutput object as a link
    [trustFactorOutput setTrustFactor:trustFactor];
    
    //BETA2: Create the assertions as hashed output
    // Check if the trustfactor ran successfully
    if (trustFactorOutput.statusCode == DNEStatus_ok) {

    }
    
    
    // Return the output object
    return trustFactorOutput;
}

// Run a TrustFactor by its name with a given payload
+ (Sentegrity_TrustFactor_Output *)runTrustFactorWithDispatch:(NSString *)dispatch andImplementation:(NSString *)implementation withPayload:(NSArray *)payload andError:(NSError **)error {
    
    // Validate the dispatch and implementation
    if (!dispatch || dispatch.length < 1 || dispatch == nil || !implementation || implementation.length < 1 || implementation == nil) {
        
        // No dispatch or implementation name received, error out
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No dispatch or implementation names received" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoImplementationOrDispatchReceived userInfo:errorDetails];
        
        // Create an assertion with just the trustfactor in it
        Sentegrity_TrustFactor_Output *trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
        // Set that it did not run
        [trustFactorOutput setExecuted:NO];
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    // Get the class dynamically
    NSString *className = [NSString stringWithFormat:kTrustFactorDispatch, dispatch];
    Class dispatchClass = NSClassFromString(className);

    // Validate the class
    if (!dispatchClass || dispatchClass == nil) {
        // No dispatch class found, error out
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No valid dispatch class found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoDispatchClassFound userInfo:errorDetails];
        
        // Create an assertion with just the trustfactor in it
        Sentegrity_TrustFactor_Output *trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
        // Set that it did not run
        [trustFactorOutput setExecuted:NO];
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    // Get the selector dynamically
    SEL implementationSelector = NSSelectorFromString(implementation);

    // Validate the selector
    if (!implementationSelector || implementationSelector == nil) {
        // No implementation selector found, error out
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No valid implementation selector found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoImplementationSelectorFound userInfo:errorDetails];
        
        // Create an assertion with just the trustfactor in it
        Sentegrity_TrustFactor_Output *trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
        // Set that it did not run
        [trustFactorOutput setExecuted:NO];
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_unsupported];
        
        // Return the assertion
        return trustFactorOutput;
    }
    // Check if the dispatch class responds to the selector for the dispatch name
    if ([dispatchClass respondsToSelector:NSSelectorFromString(implementation)]) {
        // Call the method
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [dispatchClass performSelector:implementationSelector withObject:payload];
#pragma clang diagnostic pop
    } else {
        // No check recognized, error out
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No valid TrustFactor found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidTrustFactorName userInfo:errorDetails];
        
        // Create an assertion with just the trustfactor in it
        Sentegrity_TrustFactor_Output *trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
        // Set that it did not run
        [trustFactorOutput setExecuted:NO];
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_unsupported];
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    // Return nothing
    return nil;
}

@end
