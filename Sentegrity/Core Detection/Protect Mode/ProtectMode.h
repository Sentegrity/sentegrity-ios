//
//  ProtectMode.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Protect Mode activates the different protect modes and sets trustfactors to whitelist
 */

#import <Foundation/Foundation.h>

// Sentegrity Policy
#import "Sentegrity_Policy.h"

@interface ProtectMode : NSObject

#pragma mark - Activate

/*!
 *  Activate Protect Mode Policy
 */
- (void)activateProtectModePolicy;

/*!
 *  Activate Protect Mode user
 */
- (void)activateProtectModeUser;

/*!
 *  Activate Protect mode Wipe
 */
- (void)activateProtectModeWipe;


#pragma mark - Deactivation

/*!
 *  Deactivate Protect Mode Policy with a pin
 *
 *  @param policyPIN PIN input for the policy
 *
 *  @return Whether the protect mode was deactivated or not
 */
- (BOOL)deactivateProtectModePolicyWithPIN:(NSString *)policyPIN andError:(NSError **)error;

/*!
 *  Deactivate Protect Mode Users with a pin
 *
 *  @param userPIN PIN input by the user
 *
 *  @return Whether the protect mode was deactived or not
 */
- (BOOL)deactivateProtectModeUserWithPIN:(NSString *)userPIN andError:(NSError **)error;

#pragma mark - Whitelisting

/*!
 *  WhiteList the attributing trustfactor output objects
 *
 *  @return Whether the trustfactors were whitelisted or not
 */
- (BOOL)whitelistAttributingTrustFactorOutputObjectsWithError:(NSError **)error;

#pragma mark - Special Init

/*!
 *  Initialize with a policy and trustfactors
 *
 *  @param policy                  Policy
 *  @param trustFactorsToWhitelist TrustFactors to whitelist
 *
 *  @return instance of ProtectMode
 */
- (id)initWithPolicy:(Sentegrity_Policy *)policy andTrustFactorsToWhitelist:(NSArray *)trustFactorsToWhitelist;

#pragma mark - Properties

/**
 *  Policy
 */
@property (atomic, retain) Sentegrity_Policy *policy;

/*!
 *  TrustFactors to whitelist
 */
@property (atomic, retain) NSArray *trustFactorsToWhitelist;


@end
