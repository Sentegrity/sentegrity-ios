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
#import "Sentegrity_Classification.h"
#import "Sentegrity_Subclassification.h"
#import "Sentegrity_TrustFactor_Dispatcher.h"
#import "Sentegrity_Assertion_Storage.h"

// Categories
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"

@interface CoreDetection(Private)

// Parse policy
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath isDefaultPolicy:(BOOL)isDefault withError:(NSError **)error;

// Protect Mode Analysis Callback
- (void)protectModeAnalysisResponse:(BOOL)success withDevice:(BOOL)deviceTrusted withSystem:(BOOL)systemTrusted withUser:(BOOL)userTrusted andComputation:(NSArray *)computationOutput error:(NSError *)error;

@end

@implementation CoreDetection

@synthesize defaultPolicyURLPath;

#pragma mark - Protect Mode Analysis

// Callback block definition
void (^protectModeAnalysisBlockCallBack)(BOOL success, BOOL deviceTrusted, BOOL systemTrusted, BOOL userTrusted, NSArray *computationOutput, NSError *error);

// Protect Mode Analysis
- (void)performProtectModeAnalysisWithPolicy:(Sentegrity_Policy *)policy withTimeout:(int)timeOut withCallback:(protectModeAnalysisBlock)callback {
    // Set the callback block to be the block definition
    protectModeAnalysisBlockCallBack = callback;
    
    // Create the error to use
    NSError *error = nil;
    
    // Make sure policy.trustFactors are set
    if (!policy || policy.trustFactors.count < 1 || !policy.trustFactors) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No TrustFactors found to analyze" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorsSetToAnalyze userInfo:errorDetails];
        
        // Don't return anything
        [self protectModeAnalysisResponse:NO withDevice:NO withSystem:NO withUser:NO andComputation:nil error:error];
        return;
    }
    
    //TODO: Beta2 do something with the timeout and do more error checking
    
    // Perform the entire Core Detection Process
    
    // Generate the trustfactor assertions
    NSArray *assertions = [self performTrustFactorAnalysis:policy withError:&error];
    
    // Check for valid assertions
    if (!assertions || assertions == nil || assertions.count < 1) {
        // Don't return anything
        [self protectModeAnalysisResponse:NO withDevice:NO withSystem:NO withUser:NO andComputation:nil error:error];
        return;
    }
    
    // Generate the assertion objects
    NSArray *assertionObjects = [self compareBaselineAssertions:assertions forPolicy:policy withError:&error];
    
    // Check for valid assertion objects
    if (!assertionObjects || assertionObjects == nil || assertionObjects.count < 1) {
        // Don't return anything
        NSLog(@"No Assertion Objects Received");
        [self protectModeAnalysisResponse:NO withDevice:NO withSystem:NO withUser:NO andComputation:nil error:error];
        return;
    }
    
    // Do the analysis of the assertion outputs
    Sentegrity_TrustScore_Computation *computation = [self performTrustFactorComputationForPolicy:policy withTrustFactorAssertions:assertions andAssertionObjects:assertionObjects withError:&error];
    
    // Check if the system, user, and device are trusted
    BOOL systemTrusted, userTrusted, deviceTrusted;
    
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
    [self protectModeAnalysisResponse:YES withDevice:deviceTrusted withSystem:systemTrusted withUser:userTrusted andComputation:computation.classificationInformation error:error];
    
}

// Callback function for protect mode analysis
- (void)protectModeAnalysisResponse:(BOOL)success withDevice:(BOOL)deviceTrusted withSystem:(BOOL)systemTrusted withUser:(BOOL)userTrusted andComputation:(NSArray *)computationOutput error:(NSError *)error {
    // Block callback
    protectModeAnalysisBlockCallBack(success, deviceTrusted, systemTrusted, userTrusted, computationOutput, error);
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

// Perform TrustFactor analysis
- (NSArray *)performTrustFactorAnalysis:(Sentegrity_Policy *)policy withError:(NSError **)error {
    // Make sure policy.trustFactors are set
    if (!policy || policy.trustFactors.count < 1 || !policy.trustFactors) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No TrustFactors found to analyze" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorsSetToAnalyze userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Perform the analysis
    return [Sentegrity_TrustFactor_Dispatcher generateTrustFactorAssertions:policy.trustFactors withError:error];
}

// Get the assertion store (if any) for the policy
- (Sentegrity_Assertion_Store *)getAssertionStoreForPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
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
    if ([[Sentegrity_Assertion_Storage sharedStorage] getListOfStores:error].count > 0) {
        
        // Check if the policy is the default policy
        if (policy.isDefault) {
            // Find the global store
            store = [[Sentegrity_Assertion_Storage sharedStorage] getGlobalStore:&exists withError:error];
        } else {
            // Find the store by the name
            store = [[Sentegrity_Assertion_Storage sharedStorage] getLocalStoreWithSecurityToken:policy.policyID.stringValue doesExist:&exists withError:error];
        }
    }
    
    // Store doesn't exist, create it
    if ((!store || store == nil) && !exists) {
        // Set the store
        store = [[Sentegrity_Assertion_Storage sharedStorage] setLocalStore:nil forSecurityToken:policy.policyID.stringValue overwrite:NO withError:error];
    }
    
    // Return the store
    return store;
}

// Compare Baseline Assertions for Default Policy
- (NSArray *)compareBaselineAssertions:(NSArray *)assertions forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    // Check if we received assertions
    if (!assertions || assertions.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
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
    
    // TODO: Find a better way to compare global assertions vs local assertions
    // Current Method:
    // 1.  Get both the local store for the policy and the global store for the policy
    // 2.  Run through all the assertions and see which store they belong in (local/global)
    // 3.  Compare the assertion with what's in the store
    // 4.  If nothing is returned - because the assertion doesn't exist yet, add the assertion into the store
    // 5.  Otherwise, if the comparison returns, replace the assertion with the compared assertion

    // Get our assertion store, if we have one
    Sentegrity_Assertion_Store *store = [self getAssertionStoreForPolicy:policy withError:error];
    NSLog(@"Assertion Objects1: %d", assertions.count);
    
    // Check if the store exists
    if (!store || store == nil) {
        // Store doesn't exist, fail
        return nil;
    }
    
    NSLog(@"Assertion Objects: %ld", assertions.count);
    
    // Create a bool to check if it exists
    BOOL exists = NO;
    
    // Get the global store, if we have one
    Sentegrity_Assertion_Store *globalStore = [[Sentegrity_Assertion_Storage sharedStorage] getGlobalStore:&exists withError:error];
    
    // Check if the store exists
    if (!globalStore || globalStore == nil || !exists) {
        // Store doesn't exist yet, create the store
        
        // Create the store for the first time
        globalStore = [[Sentegrity_Assertion_Storage sharedStorage] setGlobalStore:nil overwrite:NO withError:error];
        
        // Check if we've failed again
        if (!globalStore || globalStore == nil) {
            // Return nil
            return nil;
        }
    }
    
    // Create the mutable array to hold the assertion objects
    NSMutableArray *assertionObjects = [NSMutableArray arrayWithCapacity:assertions.count];
    
    // Run through all the assertions and determine if they're local or system assertions - to determine which store they go into
    for (Sentegrity_Assertion *assertion in assertions) {
        
        // Check if the assertion is valid
        if (!assertion || assertion == nil) {
            // Error out, no assertions were able to be added
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Invalid assertion passed to add" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidAssertionsProvided userInfo:errorDetails];
            
            // Don't return anything
            return nil;
        }
        
        // Check which store the assertion should be passed to
        if ([assertion.trustFactor.local boolValue]) {
            // Add this assertion to the local store
            
            // Now set the store's assertion values
            Sentegrity_Assertion_Store_Assertion_Object *assertionAdded = [store compareAssertionInStore:assertion withError:error];
            
            // Make sure the assertions were added
            if (!assertionAdded || assertionAdded == nil) {
                // Unable to compare, probably doesn't exist.  Let's just add it manually
                Sentegrity_Assertion_Store_Assertion_Object *assertionToAdd = [store createAssertionObjectFromAssertion:assertion withError:error];
                if (![store addAssertionIntoStore:assertionToAdd withError:error]) {
                    // Error out, no assertions were able to be added
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"No assertion added to local store" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                // Add the assertion object to the array
                [assertionObjects addObject:assertionToAdd];
                
            } else {
                // Comparison was made, now let's set it
                if (![store setAssertion:assertionAdded withError:error]) {
                    // Error out, no assertions were able to be set
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"No assertion set to the local store" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                // Add the assertion object to the array
                [assertionObjects addObject:assertionAdded];
                
            }
        } else {
            // Add this assertion to the global store
            
            // Now set the store's assertion values
            Sentegrity_Assertion_Store_Assertion_Object *assertionAdded = [globalStore compareAssertionInStore:assertion withError:error];
            
            // Make sure the assertions were added
            if (!assertionAdded || assertionAdded == nil) {
                // Unable to compare, probably doesn't exist.  Let's just add it manually
                Sentegrity_Assertion_Store_Assertion_Object *assertionToAdd = [globalStore createAssertionObjectFromAssertion:assertion withError:error];
                if (![globalStore addAssertionIntoStore:assertionToAdd withError:error]) {
                    // Error out, no assertions were able to be added
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"No assertion added to globalStore store" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                // Add the assertion object to the array
                [assertionObjects addObject:assertionToAdd];
                
            } else {
                // Comparison was made, now let's set it
                if (![globalStore setAssertion:assertionAdded withError:error]) {
                    // Error out, no assertions were able to be set
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"No assertion set to the globalStore store" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                // Add the assertion object to the array
                [assertionObjects addObject:assertionAdded];
                
            }
        }
    }
    
    // Save the stores
    store = [[Sentegrity_Assertion_Storage sharedStorage] setLocalStore:store forSecurityToken:policy.policyID.stringValue overwrite:YES withError:error];
    globalStore = [[Sentegrity_Assertion_Storage sharedStorage] setGlobalStore:globalStore overwrite:YES withError:error];
    
    // Give back the assertion objects array of assertion objects
    return assertionObjects;
}

// Get the policy and do the comparison/return results
- (Sentegrity_TrustScore_Computation *)performTrustFactorComputationForPolicy:(Sentegrity_Policy *)policy withTrustFactorAssertions:(NSArray *)trustFactorAssertions andAssertionObjects:(NSArray *)assertionObjects withError:(NSError **)error {
    
    // Make sure we got a policy
    if (!policy || policy == nil || policy.policyID < 0) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No policy provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoPolicyProvided userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Validate trustfactors in the policy
    if (!trustFactorAssertions || trustFactorAssertions == nil || trustFactorAssertions.count < 1) {
        // Error out, no assertion objects set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions found to compute" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Validate trustfactors in the policy
    if (!assertionObjects || assertionObjects == nil || assertionObjects.count < 1) {
        // Error out, no assertion objects set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion objects found to compute" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidAssertionsProvided userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Get the computation
    Sentegrity_TrustScore_Computation *computation = [Sentegrity_TrustScore_Computation performTrustFactorComputationWithPolicy:policy withTrustFactorAssertions:trustFactorAssertions andAssertionObjects:assertionObjects withError:error];
    
    // Validate the computation
    if (!computation || computation == nil) {
        // Error out, unable to get a computation
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No computation received" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoComputationReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Return the computation
    return computation;
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
