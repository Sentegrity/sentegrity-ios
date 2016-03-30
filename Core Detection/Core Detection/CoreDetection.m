//
//  CoreDetection.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "CoreDetection.h"

// TrustFactor Datasets
#import "Sentegrity_TrustFactor_Datasets.h"

// Constants
#import "Sentegrity_Constants.h"

// Parser
#import "Sentegrity_Policy_Parser.h"

// TrustFactor Dispatcher
#import "Sentegrity_TrustFactor_Dispatcher.h"

// Baseline Analysis
#import "Sentegrity_Baseline_Analysis.h"

// Startup
#import "Sentegrity_Startup_Store.h"

@interface CoreDetection(Private)

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

// Start Core Detection
- (void)performCoreDetectionWithCallback:(coreDetectionBlock)callback {
    
    // Create the error to use
    NSError *error = nil;
    
    // Validate the callback
    if (!callback || callback == nil) {
        
        // No valid callback provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An invalid callback block was provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid callback block", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SANoCallbackBlockProvided userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    // Set the callback block to be the block definition
    coreDetectionBlockCallBack = callback;
    
    // Get the policy
    Sentegrity_Policy * policy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
    
    // Validate the policy.trustFactors
    if (!policy || policy.trustFactors.count < 1 || !policy.trustFactors) {
        
        // No valid trustfactors found to analyze
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactors found to analyze", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please provide a policy with valid TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SANoTrustFactorsSetToAnalyze userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }

    // Get the startup store
    
    // Get our startup file
    
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        // Check if there are any errors
        if (error || error != nil) {
            
            // Unable to get startup file!
            
            // Log Error
            NSLog(@"Failed to get startup file: %@", error.debugDescription);
            

        }
        
        // Error out, no trustFactorOutputObject were able to be added
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get startup file: %@", errorDetails);
        
    }
    
    // Set the current state of Core Detection
    [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Starting Core Detection"];
    
    /* Start the TrustFactor Dispatcher */

    // Executes the TrustFactors and gets the output objects
    NSArray *trustFactorOutputObjects = [Sentegrity_TrustFactor_Dispatcher performTrustFactorAnalysis:policy.trustFactors withTimeout:[policy.timeout doubleValue] andError:&error];
    
    // Check for valid trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        
        // Invalid TrustFactor Output Objects
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactorOutputObjects returned from dispatch", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Double check provided TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SANoTrustFactorOutputObjectsFromDispatcher userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }

    /* Perform Baseline Analysis (get stored trustfactor objects, perform learning, and compare) */
    
    // Set the current state of Core Detection
    [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Performing baseline analysis"];
    
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
        error = [NSError errorWithDomain:coreDetectionDomain code:SANoTrustFactorOutputObjectsForComputation userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    /* Perform TrustScore Computation (generates scores) */
    // Set the current state of Core Detection
    [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Performing computation"];
    
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
        error = [NSError errorWithDomain:coreDetectionDomain code:SAErrorDuringComputation userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    /* Perform Results Analysis */
    
    // This largely sets the violationActionCodes and authenticationActionCodes
    
    [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Performing results analysis"];
    
    // Get the computation results
    computationResults = [Sentegrity_Results_Analysis analyzeResultsForComputation:computationResults WithPolicy:policy WithError:&error];
    
    // Validate the computation results
    if (!computationResults || computationResults == nil) {
        
        // Invalid analysis, bad computation results
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No results analysis object returned, error during result analysis", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs for details", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SAErrorDuringComputation userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    /* Perform Transparent Authentication */
    
    // If transparent auth is enabled
    if(policy.transparentAuthEnabled.integerValue==1 && computationResults.shouldAttemptTransparentAuthentication==YES){
        
        [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Performing transparent authentication"];
        
        // Get the computation results
        computationResults = [[TransparentAuthentication sharedTransparentAuth] attemptTransparentAuthenticationForComputation:computationResults withPolicy:policy withError:&error];
        
        // Validate the computation results
        if (!computationResults || computationResults == nil) {
            
            // Invalid analysis, bad computation results
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No computation object returned, error during transparent authentication", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs for details", nil)
                                           };
            
            // Set the error
            error = [NSError errorWithDomain:coreDetectionDomain code:SAErrorDuringComputation userInfo:errorDetails];
            
            // Log it
            NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
            
            // Don't return anything except the error
            [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
            
            // Return
            return;
        }

    }
    
    
    // Sanity check that we have all the action codes we need
    if (computationResults.postAuthenticationAction==0 || computationResults.preAuthenticationAction==0 ||computationResults.coreDetectionResult==0) {
        
        // Invalid analysis, bad computation results
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Missing one or more action codes", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs for details", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SAErrorDuringComputation userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }

    
    // Set last computation results to be stored in core detection for use by functions that need it after core detection has alreay compelted
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
        *error = [NSError errorWithDomain:coreDetectionDomain code:SANoCallbackBlockProvided userInfo:errorDetails];
        
        // Log it
        NSLog(@"Core Detection Response Failed: %@", errorDetails);
        
    }
}

#pragma mark Singleton and init methods

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
        _computationResults = nil;
    }
    return self;
}

#pragma mark - Main Methods


// Get the last computation results
- (Sentegrity_TrustScore_Computation *)getLastComputationResults {
    
    // Get the last computation result from the instance variable
    return _computationResults;
}

@end
