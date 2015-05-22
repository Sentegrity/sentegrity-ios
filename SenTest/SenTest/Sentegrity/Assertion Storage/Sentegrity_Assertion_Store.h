//
//  Sentegrity_Assertion_Store.h
//  SenTest
//
//  Created by Kramer on 2/25/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Stored_TrustFactor_Object.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface Sentegrity_Assertion_Store : NSObject

// App ID
@property (nonatomic,strong) NSString *appID;

// Assertion Objects
@property (nonatomic,strong) NSArray *storedTrustFactorObjects;

#pragma mark - Add
// Add an array of new storedTrustFactorObjects to the store
- (BOOL)addStoredTrustFactorObjects:(NSArray *)storedTrustFactorObjects withError:(NSError **)error;

// add a single storedTrustFactorObject into the store
- (BOOL)addStoredTrustFactorObject:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error;

#pragma mark - Replace

// Replace an array of storedTrustFactorObjects  in the store
- (BOOL)setStoredTrustFactorObjects:(NSArray *)storedTrustFactorObjects withError:(NSError **)error;

// Replace a single storedTrustFactorObject in the store
- (BOOL)setStoredTrustFactorObject:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error;

#pragma mark - Compare

// Compare provided assertions with assertion objects in the store - Provides back all assertions after comparison - if no matching assertion object is found in the store, a new one is created
//- (NSArray *)compareStoredTrustFactorObjectsInStoreWithTrustFactorOutputObjects:(NSArray *)trustFactorOutputObjects withError:(NSError **)error; // CORE FUNCTIONALITY

// Compare provided assertion with assertion object in the store - Provides back a list of changed - if no matching assertion object is found in the store, a new one is created
//- (Sentegrity_Stored_TrustFactor_Object *)findMatchingStoredTrustFactorObjectInStore:(Sentegrity_TrustFactor_Output *)assertion withError:(NSError **)error; // CORE FUNCTIONALITY

#pragma mark - Remove

// Remove provided storedTrustFactorObject  from the store - returns whether it passed or failed
- (BOOL)removeStoredTrustFactorObject:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error;

// Remove array of storedTrustFactorObjects  from the store - returns whether it passed or failed
- (BOOL)removeStoredTrustFactorObjects:(NSArray *)storedTrustFactorObjects withError:(NSError **)error;

#pragma mark - Helper Methods

// Create a new storedTrustFactorObject from TrustFactorOutputObject
- (Sentegrity_Stored_TrustFactor_Object *)createStoredTrustFactorObjectFromTrustFactorOutput:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error;

// Get an storedTrustFactorObject by a factorID
- (Sentegrity_Stored_TrustFactor_Object *)getStoredTrustFactorObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error;


@end
