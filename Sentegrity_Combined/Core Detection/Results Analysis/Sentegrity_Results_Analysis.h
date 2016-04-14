//
//  Sentegrity_TrustScore_Computation.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Policy.h"

// Transparent Authentication
#import "TransparentAuthentication.h"

#import "Sentegrity_TrustScore_Computation.h"

@class Sentegrity_TrustScore_Computation;


@interface Sentegrity_Results_Analysis : NSObject

+ (Sentegrity_TrustScore_Computation *)analyzeResultsForComputation:(Sentegrity_TrustScore_Computation *)computationResults WithPolicy:(Sentegrity_Policy *)policy WithError:(NSError **)error;


@end
