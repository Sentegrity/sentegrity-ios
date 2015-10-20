//
//  Sentegrity_TrustFactor_Dispatcher.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  The TrustFactor Dispatcher calls the appropriate function and implementation routine for a provided rule.
 */

#import <Foundation/Foundation.h>

// Assertions
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface Sentegrity_TrustFactor_Dispatcher : NSObject

// TODO: BETA2 Set a time limit and execute DNE's

// Run an array of trustfactors
+ (NSArray *)performTrustFactorAnalysis:(NSArray *)trustFactors withError:(NSError **)error;

// Generate the output from a single TrustFactor
+ (Sentegrity_TrustFactor_Output_Object *)executeTrustFactor:(Sentegrity_TrustFactor *)trustFactor withError:(NSError **)error;

// Run an individual trustfactor with just the name and the payload (returned assertion will not be able to identify the trustfactor that was run)
+ (Sentegrity_TrustFactor_Output_Object *)runTrustFactorWithDispatch:(NSString *)dispatch andImplementation:(NSString *)implementation withPayload:(NSArray *)payload andError:(NSError **)error;

@end
