//
//  ProtectMode.m
//  SenTest
//
//  Created by Jason Sinchak on 5/23/15.
//


#import <Foundation/Foundation.h>
#import "Sentegrity_TrustScore_Computation.h"
#import "Sentegrity_Baseline_Analysis.h"
#import "ProtectMode.h"
#import <UIKit/UIKit.h>

@interface ProtectMode : NSObject

// Singleton instance
+ (id)sharedProtectMode;

#pragma mark - Analysis
// Analyze computation and baseline results
- (BOOL)analyzeResults:(Sentegrity_TrustScore_Computation *)computationResults withBaseline:(Sentegrity_Baseline_Analysis *)baselineAnalysisResults withPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error;

#pragma mark - Deactivation

- (BOOL)deactivateProtectModePolicyWithPIN:(NSString *)policyPIN withError:(NSError **)error;

- (BOOL)deactivateProtectModeUserWithPIN:(NSString *)userPIN withError:(NSError **)error;


#pragma mark - Properties

@property (nonatomic, retain) Sentegrity_Policy *currentPolicy;

@property (nonatomic, retain) NSMutableArray *trustFactorsToWhitelist;

@end
