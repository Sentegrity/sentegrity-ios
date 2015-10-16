//
//  Sentegrity_Assertion.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  TrustFactor Output Object - output from the TrustFactors stored here
 */

#import <Foundation/Foundation.h>

// TrustFactor
#import "Sentegrity_TrustFactor.h"

// Store TrustFactor
#import "Sentegrity_Stored_TrustFactor_Object.h"

// Constants (DNE_STATUSCODE)
#import "Sentegrity_Constants.h"

@interface Sentegrity_TrustFactor_Output_Object : NSObject

#pragma mark - Properties

/*!
 *  Policy TrustFactor
 */
@property (atomic,retain) Sentegrity_TrustFactor *trustFactor;

/*!
 *  Parsed Stored TrustFactor Object data
 */
@property (atomic,retain) Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject;

/*!
 *  Sentegrity_Stored_Assertion objects to whitelist if protect mode is deactivated
 */
@property (atomic,retain) NSArray *assertionObjectsToWhitelist;

/*!
 *  Output Array
 */
@property (atomic,retain) NSArray *output;

/*!
 *  Sentegrity_Store_Assertion objects created from output
 */
@property (atomic,retain) NSArray *assertionObjects;

/*!
 *  DNEStatusCode
 */
@property (atomic) DNEStatusCode statusCode;

/*!
 *  Set during baseline analysis and checked during computation
 */
@property (atomic) BOOL triggered;

/*!
 *  Set during baseline analysis and checked during computation
 */
@property (atomic) BOOL whitelist;

#pragma mark - Methods

/*!
 *  Generate the default assertion object
 *
 * @return The default Stored Assertion
 */
- (Sentegrity_Stored_Assertion *)defaultAssertionObject;

/**
 *  Set the assertion objects from the output
 *
 *  @param Assertion output
 *
 *  @return BOOL value that lets you know if it was set
 */
- (BOOL)setAssertionObjectsFromOutput:(NSArray *)output;

@end
