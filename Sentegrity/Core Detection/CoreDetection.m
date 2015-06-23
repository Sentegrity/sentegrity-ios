//
//  CoreDetection.m
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved. 
//

#import "CoreDetection.h"


@interface CoreDetection(Private)

// Parse policy
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath withError:(NSError **)error;

// Protect Mode Analysis Callback
- (void)coreDetectionResponse:(BOOL)success withComputationResults:(Sentegrity_TrustScore_Computation *)computationResults andError:(NSError **)error;

@end

@implementation CoreDetection

#pragma mark - Protect Mode Analysis

// Callback block definition
void (^coreDetectionBlockCallBack)(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error);

// Start Core Detection
- (void)performCoreDetectionWithPolicy:(Sentegrity_Policy *)policy withTimeout:(int)timeOut withCallback:(coreDetectionBlock)callback {
    
    //set the policy to the current
    [self setCurrentPolicy:policy];
    
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
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        return;
    }
    
    // Start Dispatcher (executes trustfactors and populates output objects)
    
    NSArray *trustFactorOutputObjects = [Sentegrity_TrustFactor_Dispatcher performTrustFactorAnalysis:policy.trustFactors withError:&error];
    
    // Check for valid trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        // Error out, no trustfactors output
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No TrustFactorOutputObjects returned from dispatch" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorsSetToAnalyze userInfo:errorDetails];
        
        // Don't return anything
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        return;
    }

    // Perform Baseline Analysis (get stored trustfactor objects, perform learning, and compare)
    
    // Retrieve storedTrustFactorObjects & attach to trustFactorOutputObjects
    NSArray *updatedTrustFactorOutputObjects = [Sentegrity_Baseline_Analysis performBaselineAnalysisUsing:trustFactorOutputObjects forPolicy:policy withError:&error];
    
    // Check that we have objects for computation
    if (!updatedTrustFactorOutputObjects || updatedTrustFactorOutputObjects == nil) {
        // Error out, no trustfactors for computation
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No trustFactorOutputObjects available for computation" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsForComputation userInfo:errorDetails];

        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        return;
    }
    
    // Perform TrustScore Computation (generates scores)
    Sentegrity_TrustScore_Computation *computationResults = [Sentegrity_TrustScore_Computation performTrustFactorComputationWithPolicy:policy withTrustFactorOutputObjects:updatedTrustFactorOutputObjects withError:&error];
    
    // Validate the computation
    if (!computationResults || computationResults == nil) {
        // Error out, no computation object
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No computation object returned, error during computation" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Sentegrity" code:SAErrorDuringComputation userInfo:errorDetails];
        
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        return;
    }
    
    // Return through the block callback
    [self coreDetectionResponse:YES withComputationResults:computationResults andError:&error];
    
}

// Callback function for core detection
- (void)coreDetectionResponse:(BOOL)success withComputationResults:(Sentegrity_TrustScore_Computation *)computationResults andError:(NSError **)error {
    // Block callback
    if (coreDetectionBlockCallBack) {
        coreDetectionBlockCallBack(success, computationResults, error);
    } else {
        // Block callback is nil (something is really wrong)
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Unable to provide Core Detection Response, block callback is nil" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUknownError userInfo:errorDetails];
    }
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
        [self setCurrentPolicy:nil];
    }
    return self;
}

#pragma mark - Main Methods

// Parse policy
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath withError:(NSError **)error {
    // Start by creating the parser
    Sentegrity_Parser *parser = [[Sentegrity_Parser alloc] init];
    
    // Get the policy
    Sentegrity_Policy *policy;
    policy = [parser parsePolicyJSONWithPath:policyPath withError:error];
    
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
    
    // Return the policy
    return policy;
}

@end
