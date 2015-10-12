//
//  CoreDetection.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Core Detection is the main class of Sentegrity (accessed by singleton) that combines all information about gathered by the checks, including: parsing the policy, running the policy, computing the output, and providing output about the checks.
 */

#import <Foundation/Foundation.h>

// Policy
#import "Sentegrity_Policy.h"

// TrustScore Computation
#import "Sentegrity_TrustScore_Computation.h"

@interface CoreDetection : NSObject

/*!
 *  Shared Instance of Core Detection - Singleton pattern to avoid running multiple concurrent checks
 *
 *  @return CoreDetection
 */
+ (id)sharedDetection;

#pragma mark - Parsing

/*!
 *  Parse a policy with a specified path
 *
 *  @param policyPath Provide the URL file path to be parsed
 *  @param error      Send an NSError to receive an error value
 *
 *  @return A Policy Object
 */
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath withError:(NSError **)error;

#pragma mark - Core Detection

/*!
 *  CoreDetectionBlock is used as the callback block for CoreDetection
 *
 *  @param success            Identifies whether Core Detection succeeded in computing the results or not
 *  @param computationResults TrustScoreComputation object that gives more information about the computation results
 *  @param error              Error gives more information about the computation and what happened during computation
 */
typedef void (^coreDetectionBlock)(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error);

/*!
 *  Perform Core Detection with a policy object and get the block callback when it completes
 *
 *  @param policy   Sentegrity Policy Object that contains information about the policy
 *  @param timeOut  Timeout specifies the amount of time the computation will run before quitting
 *  @param callback CoreDetectionBlock
 */
// TODO: Change the way errors are passed
- (void)performCoreDetectionWithPolicy:(Sentegrity_Policy *)policy withTimeout:(int)timeOut withCallback:(coreDetectionBlock)callback;

/**
 *  Get the last computation results
 *
 *  @return TrustScoreComputation object
 */
- (Sentegrity_TrustScore_Computation *)getLastComputationResults;

#pragma mark - Properties

/**
 *  Get/set the current policy being parsed
 */
@property (atomic, retain) Sentegrity_Policy *currentPolicy;

/**
 *  Get/set the current computation results
 */
@property (atomic, retain) Sentegrity_TrustScore_Computation *computationResults;

@end
