//
//  CoreDetection.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "CoreDetection.h"
#import "Sentegrity_TrustFactor_Datasets.h"

@interface CoreDetection(Private)

/*!
 *  Parse the policy
 *
 *  @param policyPath Policy Path URL to be parsed
 *  @param error      Error information
 *
 *  @return Policy Object
 */
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath withError:(NSError **)error;

/**
 *  Protect Mode Analysis callback
 *
 *  See: CoreDetectionBlock
 */
- (void)coreDetectionResponse:(BOOL)success withComputationResults:(Sentegrity_TrustScore_Computation *)computationResults andError:(NSError **)error;

@end

@implementation CoreDetection

/*!
 *  Callback block definition
 */
void (^coreDetectionBlockCallBack)(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error);

#pragma mark - Protect Mode Analysis

// Get the last computation results
- (Sentegrity_TrustScore_Computation *)getLastComputationResults {
    
    // Get the last computation result from the instance variable
    return _computationResults;
}

// Start Core Detection
- (void)performCoreDetectionWithPolicy:(Sentegrity_Policy *)policy withTimeout:(int)timeOut withCallback:(coreDetectionBlock)callback {
    
    // Create the error to use
    NSError *error = nil;
    
    // Validate the policy
    if (!policy || policy == nil) {
        
        // No valid policy provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An invalid policy was provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid policy", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:sentegrityDomain code:SANoPolicyProvided userInfo:errorDetails];
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    // Set the policy to the current
    [self setCurrentPolicy:policy];
    
    // Validate the callback
    if (!callback || callback == nil) {
        
        // No valid callback provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An invalid callback block was provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid callback block", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:sentegrityDomain code:SANoCallbackBlockProvided userInfo:errorDetails];
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    // Set the callback block to be the block definition
    coreDetectionBlockCallBack = callback;
    
    // Validate the policy.trustFactors
    if (!policy || policy.trustFactors.count < 1 || !policy.trustFactors) {
        
        // No valid trustfactors found to analyze
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactors found to analyze", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please provide a policy with valid TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:sentegrityDomain code:SANoTrustFactorsSetToAnalyze userInfo:errorDetails];
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }

    
    /* Start the TrustFactor Dispatcher */
    
    // Executes the TrustFactors and gets the output objects
    NSArray *trustFactorOutputObjects = [Sentegrity_TrustFactor_Dispatcher performTrustFactorAnalysis:policy.trustFactors withError:&error];
    
    // Check for valid trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        
        // Invalid TrustFactor Output Objects
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactorOutputObjects returned from dispatch", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Double check provided TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:sentegrityDomain code:SANoTrustFactorOutputObjectsFromDispatcher userInfo:errorDetails];
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }

    /* Perform Baseline Analysis (get stored trustfactor objects, perform learning, and compare) */
    
    // Retrieve storedTrustFactorObjects & attach to trustFactorOutputObjects
    NSArray *updatedTrustFactorOutputObjects = [Sentegrity_Baseline_Analysis performBaselineAnalysisUsing:trustFactorOutputObjects forPolicy:policy withError:&error];
    
    // Check that we have objects for computation
    if (!updatedTrustFactorOutputObjects || updatedTrustFactorOutputObjects == nil) {
        
        // Invalid TrustFactor output objects after baseline analysis
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No trustFactorOutputObjects available for computation", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Double check provided TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:sentegrityDomain code:SANoTrustFactorOutputObjectsForComputation userInfo:errorDetails];
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    /* Perform TrustScore Computation (generates scores) */
    
    // Get the computation results
    Sentegrity_TrustScore_Computation *computationResults = [Sentegrity_TrustScore_Computation performTrustFactorComputationWithPolicy:policy withTrustFactorOutputObjects:updatedTrustFactorOutputObjects withError:&error];
    
    // Validate the computation results
    if (!computationResults || computationResults == nil) {
        
        // Invalid analysis, bad computation results
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No computation object returned, error during computation", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs for details", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:sentegrityDomain code:SAErrorDuringComputation userInfo:errorDetails];
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    // Set last computation results
    [self setComputationResults:computationResults];
    
    // Return through the block callback
    [self coreDetectionResponse:YES withComputationResults:computationResults andError:&error];
    
}

// Callback function for core detection
- (void)coreDetectionResponse:(BOOL)success withComputationResults:(Sentegrity_TrustScore_Computation *)computationResults andError:(NSError **)error {
    
    // Block callback
    if (coreDetectionBlockCallBack) {
        // Call the Core Detection Block Callabck
        coreDetectionBlockCallBack(success, computationResults, error);
        
    } else {
        
        // Block callback is nil (something is really wrong)
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Core Detection Response Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An invalid callback block was provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid callback block", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:sentegrityDomain code:SANoCallbackBlockProvided userInfo:errorDetails];
        
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
        // Default values get set here
        _currentPolicy = nil;
        _computationResults = nil;
    }
    return self;
}

#pragma mark - Main Methods

// Parse policy
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath withError:(NSError **)error {
    
    // Validate the policy path provided
    if (!policyPath || policyPath == nil || ![[NSFileManager defaultManager] fileExistsAtPath:[policyPath path]]) {
        // Invalid policy path provided
        
        // Block callback is nil (something is really wrong)
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Parse Policy Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An invalid policy path was provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid policy path", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:sentegrityDomain code:SAInvalidPolicyPath userInfo:errorDetails];
    }
    
    // Start by creating the parser
    Sentegrity_Parser *parser = [[Sentegrity_Parser alloc] init];
    
    // Get the policy
    Sentegrity_Policy *policy = [parser parsePolicyJSONWithPath:policyPath withError:error];
    
    // Validate the policy
    if ((!policy || policy == nil) && *error != nil) {
        
        // Unable to parse the policy, but passing the error up
        return policy;
        
    } else if ((!policy || policy == nil) && *error == nil) {
        
        // Policy came back empty, and so did the error
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Parse Policy Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to parse policy, unknown error", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid policy path and valid policy", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnKnownError userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Return the policy
    return policy;
}

@end
