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

#pragma mark - Activate

- (void)activateProtectModePolicyWithError:(NSError **)error;

- (void)activateProtectModeUserWithError:(NSError **)error;

- (void)activateProtectModeWipeWithError:(NSError **)error;


#pragma mark - Deactivation

- (BOOL)deactivateProtectModePolicyWithPIN:(NSString *)policyPIN withError:(NSError **)error;

- (BOOL)deactivateProtectModeUserWithPIN:(NSString *)userPIN withError:(NSError **)error;

#pragma mark - Setters

- (void)setTrustFactorsToWhitelist:(NSArray *)trustFactorsToWhitelist;

- (void)setPolicy:(Sentegrity_Policy *)policy;

#pragma mark - Whitelisting

- (BOOL)whitelistAttributingTrustFactorOutputObjectsWithError:(NSError **)error;

@end
