//
//  Sentegrity_Assertion_Store+Helper.h
//  Sentegrity
//
//  Created by Kramer on 10/12/15.
//  Copyright © 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_Assertion_Store.h"

@interface Sentegrity_Assertion_Store (Helper)

#pragma mark - Helper Methods

/**
 *  Creates a stored TrustFactor Object from a TrustFactor Output
 *
 *  @param trustFactorOutputObject TrustFactor Output Object
 *  @param error                   Error
 *
 *  @return Sentegrity Stored TrustFactor Object
 */
- (Sentegrity_Stored_TrustFactor_Object *)createStoredTrustFactorObjectFromTrustFactorOutput:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error;

/**
 *  Get a stored TrustFactor Object by a factorID
 *
 *  @param factorID The Factor ID of the TrustFactor
 *  @param exists   Whether it exists or not
 *  @param error    Error
 *
 *  @return Returns the Stored TrustFactor Object if it exists
 */
- (Sentegrity_Stored_TrustFactor_Object *)getStoredTrustFactorObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error;

@end
