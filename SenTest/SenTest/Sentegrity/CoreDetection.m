//
//  CoreDetection.m
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved. 
//

#import "CoreDetection.h"
#import "Sentegrity_Constants.h"
#import "Sentegrity_Parser.h"
#import "Sentegrity_Policy.h"
#import "Sentegrity_TrustFactor.h"
//#import "Sentegrity_Classification.h"
//#import "Sentegrity_Subclassification.h"
#import "Sentegrity_TrustFactor_Dispatcher.h"
#import "Sentegrity_TrustFactor_Storage.h"

// Categories
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"

@interface CoreDetection(Private)

// Parse policy
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath isDefaultPolicy:(BOOL)isDefault withError:(NSError **)error;

// Protect Mode Analysis Callback
- (void)coreDetectionResponse:(BOOL)success withDevice:(BOOL)deviceTrusted withSystem:(BOOL)systemTrusted withUser:(BOOL)userTrusted andComputation:(NSArray *)computationOutput error:(NSError *)error;

@end

@implementation CoreDetection

@synthesize defaultPolicyURLPath;

#pragma mark - Protect Mode Analysis

// Callback block definition
void (^coreDetectionBlockCallBack)(BOOL success, BOOL deviceTrusted, BOOL systemTrusted, BOOL userTrusted, NSArray *computationOutput, NSError *error);

// Start Core Detection
- (void)performCoreDetectionWithPolicy:(Sentegrity_Policy *)policy withTimeout:(int)timeOut withCallback:(coreDetectionBlock)callback {
    
    // Set the callback block to be the block definition
    coreDetectionBlockCallBack = callback;
    
    // Create the error to use
    NSError *error = nil;
    
    // Make sure policy.trustFactors are set
    if (!policy || policy.trustFactors.count < 1 || !policy.trustFactors) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No TrustFactors found to analyze" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorsSetToAnalyze userInfo:errorDetails];
        
        // Don't return anything
        [self coreDetectionResponse:NO withDevice:NO withSystem:NO withUser:NO andComputation:nil error:error];
        return;
    }
    
    // Perform the entire Core Detection Process
    
    // start dispatcher
    NSArray *trustFactorOutputObjects = [Sentegrity_TrustFactor_Dispatcher performTrustFactorAnalysis:policy.trustFactors withError:&error];
    
    // Check for valid trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        // Don't return anything
        [self coreDetectionResponse:NO withDevice:NO withSystem:NO withUser:NO andComputation:nil error:error];
        return;
    }

    // Retrieve storedTrustFactorObjects
    NSArray *storedTrustFactorObjects = [self retrieveStoredTrustFactorObjects:trustFactorOutputObjects forPolicy:policy withError:&error];
    
    // Check for valid storedTrustFactorObjects
    if (!storedTrustFactorObjects || storedTrustFactorObjects == nil || storedTrustFactorObjects.count < 1) {
        // Don't return anything
        NSLog(@"No Stored TrustFactor Objects Received");
        [self coreDetectionResponse:NO withDevice:NO withSystem:NO withUser:NO andComputation:nil error:error];
        return;
    }
    
    // Perform baseline analysis and computation together

    // Get the computation
    Sentegrity_TrustScore_Computation *computation = [Sentegrity_TrustScore_Computation performTrustFactorComputationWithPolicy:policy withTrustFactorOutputObjects:trustFactorOutputObjects andStoredTrustFactorObjects:storedTrustFactorObjects withError:&error];
    
    // Validate the computation
    if (!computation || computation == nil) {
        // Error out, unable to get a computation
        NSLog(@"Computation error");
        [self coreDetectionResponse:NO withDevice:NO withSystem:NO withUser:NO andComputation:nil error:error];
        return;
    }

    
    // Check if the system, user, and device are trusted
    BOOL systemTrusted, userTrusted, deviceTrusted;
    NSLog(@"System Threshold: %ld User Threshold: %ld", policy.systemThreshold.integerValue, policy.userThreshold.integerValue);
    // Check the system
    if (computation.systemScore < policy.systemThreshold.integerValue) {
        // System is not trusted
        systemTrusted = NO;
    } else {
        // System is trusted
        systemTrusted = YES;
    }
    
    // Check the user
    if (computation.userScore < policy.userThreshold.integerValue) {
        // User is not trusted
        userTrusted = NO;
    } else {
        // User is trusted
        userTrusted = YES;
    }
    
    // Check the device
    if (!systemTrusted || !userTrusted) {
        // Device is not trusted
        deviceTrusted = NO;
    } else {
        // Device is trusted
        deviceTrusted = YES;
    }
    
    // Return through the block callback
    [self coreDetectionResponse:YES withDevice:deviceTrusted withSystem:systemTrusted withUser:userTrusted andComputation:computation.triggered error:error];
    
}

// Callback function for core detection
- (void)coreDetectionResponse:(BOOL)success withDevice:(BOOL)deviceTrusted withSystem:(BOOL)systemTrusted withUser:(BOOL)userTrusted andComputation:(NSArray *)computationOutput error:(NSError *)error {
    // Block callback
    coreDetectionBlockCallBack(success, deviceTrusted, systemTrusted, userTrusted, computationOutput, error);
}

#pragma mark Singleton Methods

// Singleton shared instance
+ (id)sharedDetection {
    static CoreDetection *sharedMyDetection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyDetection = [[self alloc] init];
    });
    return sharedMyDetection;
}

// Init (Defaults)
- (id)init {
    if (self = [super init]) {
        // Set defaults here if need be
        [self setDefaultPolicyURLPath:nil];
    }
    return self;
}

#pragma mark - Outside methods

// Parse Default Policy
- (Sentegrity_Policy *)parseDefaultPolicy:(NSError **)error {
    return [self parsePolicy:defaultPolicyURLPath isDefaultPolicy:YES withError:error];
}

// Parse a Custom Policy
- (Sentegrity_Policy *)parseCustomPolicy:(NSURL *)customPolicyPath withError:(NSError **)error {
    return [self parsePolicy:customPolicyPath isDefaultPolicy:NO withError:error];
}


// Get the assertion store (if any) for the policy
- (Sentegrity_Assertion_Store *)getLocalAssertionStoreForPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    // Make sure we got a policy
    if (!policy || policy.policyID < 0) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No policy provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoPolicyProvided userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Create the store
    Sentegrity_Assertion_Store *store;
    
    // Create a bool to check if it exists
    BOOL exists = NO;
    
    // Check with the assertion storage to see if we have one for the policy
    if ([[Sentegrity_TrustFactor_Storage sharedStorage] getListOfStores:error].count > 0) {
        
            // Find the local store by the name
            store = [[Sentegrity_TrustFactor_Storage sharedStorage] getLocalStoreWithAppID:policy.appID.stringValue doesExist:&exists withError:error];
        
    }
    
    // Store doesn't exist, create it
    if ((!store || store == nil) && !exists) {
        // Set the store
        store = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:nil forAppID:policy.appID.stringValue overwrite:NO withError:error];
    }
    
    // Return the store
    return store;
}

// Retrieve stored assertions
- (NSArray *)retrieveStoredTrustFactorObjects:(NSArray *)trustFactorOutputObjectArray forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    // Check if we received trustFactorOutputObjects
    if (!trustFactorOutputObjectArray || trustFactorOutputObjectArray.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Make sure we got a policy
    if (!policy || policy.policyID < 0) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No policy provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoPolicyProvided userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    

    // Attempt to get our local assertion store, if does not exist it gets created
    Sentegrity_Assertion_Store *localStore = [self getLocalAssertionStoreForPolicy:policy withError:error];
    
    // Create a bool to check if global store exists
    BOOL exists = NO;
    
    // Get the global store singleton
    Sentegrity_Assertion_Store *globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getGlobalStore:&exists withError:error];
    
    // Check if the global store exists (should, unless is the first ever run)
    if (!globalStore || globalStore == nil || !exists) {
        // Store doesn't exist yet, create the store
        
        // Create the store for the first time
        globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] setGlobalStore:nil overwrite:NO withError:error];
        
        // Check if we've failed again
        if (!globalStore || globalStore == nil) {
            // Return nil
            return nil;
        }
    }
    
    // Create the mutable array to hold the storedTrustFactoObjects for each trustFactorOutputObject
    NSMutableArray *storedTrustFactorObjects = [NSMutableArray arrayWithCapacity:trustFactorOutputObjectArray.count];
    
    // Run through all the trustFactorOutput objects and determine if they're local or global TrustFactors to determine the store used
    for (Sentegrity_TrustFactor_Output *trustFactorOutputObject in trustFactorOutputObjectArray) {
        
        // Check if the TrustFactor is valid to start with
        if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
            // Error out, no trustFactorOutputObject were able to be added
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Invalid trustFactorOutputObject passed" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStoredTrustFactorObjectsProvided userInfo:errorDetails];
            
            // Don't return anything
            return nil;
        }
        
        //*********** TrustFactor belongs to the local store ***********
        
        if ([trustFactorOutputObject.trustFactor.local boolValue]) {
   
            // Find the matching stored assertion object for the trustfactor in the local store
            Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
            
            //object to add
            Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObjectModified = [[Sentegrity_Stored_TrustFactor_Object alloc] init];
            
            // If could not find in the local store create it
            if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
                
                storedTrustFactorObject = [localStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                
                //since its new check if it can be set to learned already
                storedTrustFactorObjectModified = [storedTrustFactorObject checkLearningAndUpdate:trustFactorOutputObject withError:error];
                
                //add the new storedTrustFactorObject to the local store
                if (![localStore addStoredTrustFactorObject:storedTrustFactorObjectModified withError:error]) {
                    // Error out, no storedTrustFactorObjects were able to be added
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"No storedTrustFactorObjects addeded to local store" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                
                // Add the stored trustfactor object to the array
                [storedTrustFactorObjects addObject:storedTrustFactorObjectModified];
                
            }
            else // check revision & learning
            {
                
                //revisions do not match
                if (![storedTrustFactorObject revisionsMatch:trustFactorOutputObject withError:error]) {
                    
                    //create a new object in the local store
                    storedTrustFactorObject = [localStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                    
                    //since its new check if it can be set to learned already and update run counts, etc
                    storedTrustFactorObjectModified = [storedTrustFactorObject checkLearningAndUpdate:trustFactorOutputObject withError:error];
                    
                    //replace existing in the local store
                    if (![localStore setStoredTrustFactorObject:storedTrustFactorObjectModified withError:error]) {
                        // Error out, no storedTrustFactorOutputObjects were able to be added
                        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                        [errorDetails setValue:@"No storedTrustFactorOutputObjects addeded to local store" forKey:NSLocalizedDescriptionKey];
                        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                        
                        // Don't return anything
                        return nil;
                    }
                    
                    //update our working array
                    [storedTrustFactorObjects addObject:storedTrustFactorObjectModified];
                }
                else //storedTrustFactorObject exists and the revisions matched, just check learning
                {
                    //if its not learned yet, make updates and replace
                    if (!storedTrustFactorObject.learned)
                    {
                        storedTrustFactorObjectModified = [storedTrustFactorObject checkLearningAndUpdate:trustFactorOutputObject withError:error];
                        
                        //replace existing in local store
                        if (![localStore setStoredTrustFactorObject:storedTrustFactorObjectModified withError:error]) {
                                // Error out, no storeTrustFactorObjects were able to be set
                                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                                [errorDetails setValue:@"No storeTrustFactorObjects set to the local store" forKey:NSLocalizedDescriptionKey];
                                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                    
                                // Don't return anything
                                return nil;
                        }
                        
                        //update our working array
                        [storedTrustFactorObjects addObject:storedTrustFactorObjectModified];
                
                    }
                    
                    //this trustfactor is a perfect match and is already learned
                    [storedTrustFactorObjects addObject:storedTrustFactorObject];
                }
                
             }
            

        //*********** TrustFactor belongs to the global store ***********
        } else {
    
            // Find the matching stored assertion object for the trustfactor in the global store
            Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [globalStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
            
            //object to add
            Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObjectModified = [[Sentegrity_Stored_TrustFactor_Object alloc] init];
            
            // If could not find in the global store create it
            if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
                
                storedTrustFactorObject = [globalStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                
                //since its new check if it can be set to learned already
                storedTrustFactorObjectModified = [storedTrustFactorObject checkLearningAndUpdate:trustFactorOutputObject withError:error];
                
                //add the new storedTrustFactorObject to the global store
                if (![globalStore addStoredTrustFactorObject:storedTrustFactorObjectModified withError:error]) {
                    // Error out, no storedTrustFactorObjects were able to be added
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"No storedTrustFactorObjects addeded to global store" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                
                // Add the stored trustfactor object to the array
                [storedTrustFactorObjects addObject:storedTrustFactorObjectModified];
                
            }
            else // check revision & learning
            {
                
                //revisions do not match
                if (![storedTrustFactorObject revisionsMatch:trustFactorOutputObject withError:error]) {
                    
                    //create a new object in the global store
                    storedTrustFactorObject = [globalStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                    
                    //since its new check if it can be set to learned already and update run counts, etc
                    storedTrustFactorObjectModified = [storedTrustFactorObject checkLearningAndUpdate:trustFactorOutputObject withError:error];
                    
                    //replace existing in the global store
                    if (![globalStore setStoredTrustFactorObject:storedTrustFactorObjectModified withError:error]) {
                        // Error out, no storedTrustFactorOutputObjects were able to be added
                        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                        [errorDetails setValue:@"No storedTrustFactorOutputObjects addeded to global store" forKey:NSLocalizedDescriptionKey];
                        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                        
                        // Don't return anything
                        return nil;
                    }
                    
                    //update our working array
                    [storedTrustFactorObjects addObject:storedTrustFactorObjectModified];
                }
                else //storedTrustFactorObject exists and the revisions matched, just check learning
                {
                    //if its not learned yet, make updates and replace
                    if (!storedTrustFactorObject.learned)
                    {
                        storedTrustFactorObjectModified = [storedTrustFactorObject checkLearningAndUpdate:trustFactorOutputObject withError:error];
                        
                        //replace existing in global store
                        if (![globalStore setStoredTrustFactorObject:storedTrustFactorObjectModified withError:error]) {
                            // Error out, no storeTrustFactorObjects were able to be set
                            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                            [errorDetails setValue:@"No storeTrustFactorObjects set to the global store" forKey:NSLocalizedDescriptionKey];
                            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                            
                            // Don't return anything
                            return nil;
                        }
                        
                        //update our working array
                        [storedTrustFactorObjects addObject:storedTrustFactorObjectModified];
                        
                    }
                    
                    //this trustfactor is a perfect match and is already learned
                    [storedTrustFactorObjects addObject:storedTrustFactorObject];
                }
                
            }
        }
    }


    // Save the stores as no more changes are required
    localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore forAppID:policy.appID.stringValue overwrite:YES withError:error];
    globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] setGlobalStore:globalStore overwrite:YES withError:error];
    
    // Give back the assertion objects array of working storedTrustFactorObjects objects
    return storedTrustFactorObjects;
}



#pragma mark - Main Methods

// Parse policy
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath isDefaultPolicy:(BOOL)isDefault withError:(NSError **)error {
    // Start by creating the parser
    Sentegrity_Parser *parser = [[Sentegrity_Parser alloc] init];
    
    // Get the policy
    Sentegrity_Policy *policy;
    
    // Parse the policy with the parser
    if ([policyPath.pathExtension isEqualToString:@"plist"]) {
        // Parse plist
        policy = [parser parsePolicyPlistWithPath:policyPath withError:error];
    } else if ([policyPath.pathExtension isEqualToString:@"json"]) {
        // Parse json
        policy = [parser parsePolicyJSONWithPath:policyPath withError:error];
    }
    
    // Error check the policy
    if (!policy && *error != nil) {
        // Error!
        return policy;
    } else if (!policy && *error == nil) {
        // Unknown Error (something is really wrong)
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Unable to parse policy, unknown error" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUknownError userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Set if the policy is the default policy or not
    [policy setIsDefault:isDefault];
    
    // Return the policy
    return policy;
}

#pragma mark - Setters

// Check if the user wants to set it
- (void)setDefaultPolicyURLPath:(NSURL *)adefaultPolicyURLPath {
    // Set it to the supplied path
    if (adefaultPolicyURLPath || adefaultPolicyURLPath != nil) {
        defaultPolicyURLPath = adefaultPolicyURLPath;
        // Return
        return;
    }
    
    // Otherwise, set the path to the documents directory, if it exists, or the resource bundle
    
    // Search for the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the documents directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Get the default policy plist path from the documents directory
    NSString *defaultPolicyDocumentsPath = [documentsDirectory stringByAppendingPathComponent:@"Default_Policy.plist"];
    
    // Get the default policy plist path from the resources
    NSString *defaultPolicyPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Default_Policy.plist"];
    
    // Make sure it exists and set it
    if ([[NSFileManager defaultManager] fileExistsAtPath:defaultPolicyDocumentsPath]) {
        
        // Default policy exists in the documents directory, use this one
        defaultPolicyURLPath = [[NSURL alloc] initFileURLWithPath:defaultPolicyDocumentsPath];
        
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:defaultPolicyPath]) {
        
        // No default policy found in the documents directory, use the one included with the application
        defaultPolicyURLPath = [[NSURL alloc] initFileURLWithPath:defaultPolicyPath];
        
    }
}

@end
