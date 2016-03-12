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

/**
 *  Run an array of trustfactors
 *
 *  @param trustFactors TrustFactors to run
 *  @param timeout      Timeout period (how long it has to run)
 *  @param error        Error
 *
 *  @return Returns an array of trustfactor assertions (output)
 */
+ (NSArray *)performTrustFactorAnalysis:(NSArray *)trustFactors withTimeout:(NSTimeInterval)timeout andError:(NSError **)error;

// Generate the output from a single TrustFactor
+ (Sentegrity_TrustFactor_Output_Object *)executeTrustFactor:(Sentegrity_TrustFactor *)trustFactor withDeviceSalt: (NSString *) deviceSalt withError:(NSError **)error;

// Run an individual trustfactor with just the name and the payload (returned assertion will not be able to identify the trustfactor that was run)
+ (Sentegrity_TrustFactor_Output_Object *)runTrustFactorWithDispatch:(NSString *)dispatch andImplementation:(NSString *)implementation withPayload:(NSArray *)payload andError:(NSError **)error;

@end
