//
//  Sentegrity_Baseline_Analysis.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Baseline Analysis - Determines which rules have "triggered" based on current and stored assertions.
 */
#import <Foundation/Foundation.h>
#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_Policy.h"

@interface Sentegrity_Baseline_Analysis : NSObject

// TrustFactorOutputObject eligable for protectMode whitelisting
@property (nonatomic) NSMutableArray *trustFactorOutputObjectsForProtectMode;

/*!
 *  Perform baseline analysis with given TrustFactor objects.
 *
 *  @param trustFactorOutputObjects
 *  @param policy                   The policy used for baseline analysis
 *  @param error                    Send an NSError to recieve an error value
 *
 *  @return An array with analysis
 */
+ (NSArray *)performBaselineAnalysisUsing:(NSArray *)trustFactorOutputObjects forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error;

@end
