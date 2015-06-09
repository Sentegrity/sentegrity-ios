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
        [errorDetails setValue:@"No TrustFactors received for dispatch" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorsReceived userInfo:errorDetails];
    }
    
    // Next, run through the array of trustFactors to be executed
    for (Sentegrity_TrustFactor *trustFactor in trustFactors) {
        
        // Run the TrustFactor and populate output object
        Sentegrity_TrustFactor_Output_Object *trustFactorOutputObjects = [self executeTrustFactor:trustFactor withError:error];
        
        //add trustfactor to trustFactorOutput object
        
        trustFactorOutputObjects.trustFactor = trustFactor;
        // Add the trustFactorOutput object to the output array
        [processedTrustFactorArray addObject:trustFactorOutputObjects];
    
    }
    
    // Return the output array
    return [NSArray arrayWithArray:processedTrustFactorArray];
}

+ (Sentegrity_TrustFactor_Output_Object *)executeTrustFactor:(Sentegrity_TrustFactor *)trustFactor withError:(NSError **)error {
    
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject; 
    
    /* Validate payload prior
    if (trustFactor.payload.count<1) {
        // Error out, no payload
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:[@"No trustFactor payload, cannot run trustfactor" stringByAppendingString:trustFactor.name] forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectGenerated userInfo:errorDetails];
        
        // Create an trustFactorOutputObject with just the error
        trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutputObject;
    }
    */
    
    //try to run implementation
    
    @try {
        // run the trustfactor implementation and get trustFactorOutputObject
        trustFactorOutputObject = [self runTrustFactorWithDispatch:trustFactor.dispatch andImplementation:trustFactor.implementation withPayload:trustFactor.payload andError:error];
    }
    @catch (NSException *exception) {
        
        // Something happened inside the implementation
        // Reset our object and set the DNE Status Code to error
        trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:[@"Error executing TrustFactor implementation for:" stringByAppendingString:trustFactor.name] forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectGenerated userInfo:errorDetails];
        
        return trustFactorOutputObject;
        
    }

    
    // Validate trustFactorOutputObject
    if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
        // Error out, no trustFactorOutputObject generated
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:[@"No trustFactorOutputObject generated for trustfactor" stringByAppendingString:trustFactor.name] forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectGenerated userInfo:errorDetails];
        
        // Create an trustFactorOutputObject with just the error
        trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutputObject;
    }

    
   //if this is a normal rule, output array should ALWAYS contain something, add default output if it doesnt
    if(trustFactor.inverse.intValue==0)
    {
        if(trustFactorOutputObject.output.count<1)
        {
            //output has nothing, implementation must not have found what it was looking for (generally a good thing)
            //set the default output
            [trustFactorOutputObject.output insertObject:kDefaultTrustFactorOutput atIndex:0];
        }
        
        //generate assertions for each output
        [trustFactorOutputObject generateAssertionsFromOutput];
    }
    else //inverse rule, output DOES NOT have contain anything
    {
        //only attempt to generate assertions if non-empty, otherwise leave empty and set status
        if(trustFactorOutputObject.output.count>0)
        {
            //set the default output
            [trustFactorOutputObject generateAssertionsFromOutput];
        }
        else{
             [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        }
        
    }
   

    // Return the output object
    return trustFactorOutputObject;
}

// Run a TrustFactor by its name with a given payload
+ (Sentegrity_TrustFactor_Output_Object *)runTrustFactorWithDispatch:(NSString *)dispatch andImplementation:(NSString *)implementation withPayload:(NSArray *)payload andError:(NSError **)error {
    
    // Validate the dispatch and implementation
    if (!dispatch || dispatch.length < 1 || dispatch == nil || !implementation || implementation.length < 1 || implementation == nil) {
        
        // No dispatch or implementation name received, error out
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No dispatch or implementation names received" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoImplementationOrDispatchReceived userInfo:errorDetails];
        
        // Create an trustFactorOutputObject with just the error in it
        Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
        // Set the DNE Status Code
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutputObject;
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
        
        // Create an assertion with just the error in it
        Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
        // Set the DNE Status Code
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutputObject;
    }
    
    // Get the selector dynamically
    SEL implementationSelector = NSSelectorFromString(implementation);

    // Validate the selector
    if (!implementationSelector || implementationSelector == nil) {
        // No implementation selector found, error out
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No valid implementation selector found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoImplementationSelectorFound userInfo:errorDetails];
        
        // Create an assertion with just the error in it
        Sentegrity_TrustFactor_Output_Object *trustFactorOutput = [[Sentegrity_TrustFactor_Output_Object alloc] init];
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_unsupported];
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    
    //NSLog([NSString stringWithFormat:@"%@ %@ %@", @"Trying to run:", dispatchClass, implementation]);
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
        
        // Create an assertion with just the error in it
        Sentegrity_TrustFactor_Output_Object *trustFactorOutput = [[Sentegrity_TrustFactor_Output_Object alloc] init];
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_unsupported];
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    // Return nothing
    return nil;
}

@end
