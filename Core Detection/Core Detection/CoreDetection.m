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
#import "Sentegrity_Parser.h"

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
- (void)performCoreDetectionWithPolicy:(Sentegrity_Policy *)policy withCallback:(coreDetectionBlock)callback {
    
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
        error = [NSError errorWithDomain:coreDetectionDomain code:SACoreDetectionNoPolicyProvided userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
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
    
    // Set the current state of Core Detection
    [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Starting Core Detection"];
    
    /* Start the TrustFactor Dispatcher */
    // TODO: Add Timeout
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
    
    // Set last computation results
    [self setComputationResults:computationResults];
    
    // Return through the block callback
    [self coreDetectionResponse:YES withComputationResults:computationResults andError:&error];
    
}

// Callback function for core detection
- (void)coreDetectionResponse:(BOOL)success withComputationResults:(Sentegrity_TrustScore_Computation *)computationResults andError:(NSError **)error {
    
    // Save the output to the startup file (run history)
    
    // Get our startup file
    NSError *startupError;
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupFile:&startupError];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        // Check if there are any errors
        if (startupError || startupError != nil) {
            
            // Unable to get startup file!
            
            // Log Error
            NSLog(@"Failed to get startup file: %@", startupError.debugDescription);
            
            // Set the error
            *error = startupError;
            
        }
        
        // Error out, no trustFactorOutputObject were able to be added
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get startup file: %@", errorDetails);
        
    }
    
    // Create a run history
    Sentegrity_History *runHistoryObject = [[Sentegrity_History alloc] init];
    [runHistoryObject setDeviceScore:computationResults.systemScore];
    [runHistoryObject setTrustScore:computationResults.deviceScore];
    [runHistoryObject setUserScore:computationResults.userScore];
    [runHistoryObject setDeviceIssues:computationResults.systemGUIIssues];
    [runHistoryObject setTimestamp:[NSDate date]];
    [runHistoryObject setProtectModeAction:computationResults.protectModeAction];
    [runHistoryObject setUserIssues:computationResults.userGUIIssues];
    
    // Check if the startup file already has an array of history objects
    if (!startup.runHistory || startup.runHistory.count < 1) {
        
        // Create a new array
        NSArray *historyArray = [NSArray arrayWithObject:runHistoryObject];
        
        // Set the array to the startup file
        [startup setRunHistory:historyArray];
        
    } else {
        
        // Startup History is an array with objects in it already
        NSArray *historyArray = [[startup runHistory] arrayByAddingObject:runHistoryObject];
        
        // Set the array to the startup file
        [startup setRunHistory:historyArray];
        
    }
    
    // Save the updates to the startup file
    [[Sentegrity_Startup_Store sharedStartupStore] setStartupFile:startup withError:&startupError];
    
    // Check for errors
    if (startupError || startupError != nil) {
        
        // Unable to set startup file!
        
        // Log Error
        NSLog(@"Failed to set startup file: %@", startupError.debugDescription);
        
        // Set the error
        *error = startupError;
        
    }
    
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
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidPolicyPath userInfo:errorDetails];
        
        // Log it
        NSLog(@"Parse Policy Failed: %@", errorDetails);
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
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnknownError userInfo:errorDetails];
        
        // Log it
        NSLog(@"Parse Poilicy Failed: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Return the policy
    return policy;
}

// Get the last computation results
- (Sentegrity_TrustScore_Computation *)getLastComputationResults {
    
    // Get the last computation result from the instance variable
    return _computationResults;
}

@end
