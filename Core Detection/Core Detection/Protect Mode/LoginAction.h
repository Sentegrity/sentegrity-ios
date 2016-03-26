//
//  ProtectMode.h
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

@interface LoginAction : NSObject

/*!
 *  Deactivate Protect Mode Action using the provided input
 *
 *  @param action specifies what to do
 *
 *  @return Whether the protect mode was deactived or not
 */

// Deactivate Protect Mode User with user pin
+ (NSInteger)attemptLoginWithViolationActionCode:(NSInteger)violationCode withAuthenticationCode:(NSInteger)authenticationCode withUserInput:(NSString *)Userinput andError:(NSError **)error;

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
