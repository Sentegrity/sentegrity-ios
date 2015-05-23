//
//  ProtectMode.m
//  SenTest
//
//  Created by Jason Sinchak on 5/23/15.
//


#import <Foundation/Foundation.h>
#import "Sentegrity_TrustScore_Computation.h"
#import "Sentegrity_Baseline_Analysis.h"

@interface ProtectMode : NSObject

// Analyze untrusted results
+ (void)analyzeResults:(Sentegrity_TrustScore_Computation *)computationResults withBaseline:(Sentegrity_Baseline_Analysis *)baselineAnalysisResults;

@end
