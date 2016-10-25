//
//  TransparentAuthentication.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Transparent authentication converts TrustFactors to encryption keys when the device is trusted
 */

#import <Foundation/Foundation.h>

// Sentegrity constants
#import "Sentegrity_Constants.h"

// Sentegrity Policy
#import "Sentegrity_Policy.h"
#import "Sentegrity_TrustScore_Computation.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

// Startup
#import "Sentegrity_Startup.h"
#import "Sentegrity_Startup_Store.h"

// Crypto
#import "Sentegrity_Crypto.h"

// TrustFactor dataset functions
#import "Sentegrity_TrustFactor_Datasets.h"

// Computation
#import "Sentegrity_TrustScore_Computation.h"
#import "CoreDetection.h"

@class Sentegrity_TrustScore_Computation;

@interface TransparentAuthentication : NSObject

// Singleton instance
+ (id)sharedTransparentAuth;

/*!
 *  Attempts transparent authentication and returns True if an existing match was found and false if none was found
 */
- (Sentegrity_TrustScore_Computation *)attemptTransparentAuthenticationForComputation:(Sentegrity_TrustScore_Computation *)computationResults withPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error;


/*!
 *  Analyzes the eligible transparent auth objects and prioritizes the best authenticators to avoid making weak or uncommon keys
 */
- (BOOL)analyzeEligibleTransparentAuthObjects:(Sentegrity_TrustScore_Computation *)computationResults withPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error;


@end
