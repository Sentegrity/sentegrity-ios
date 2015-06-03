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
@property (nonatomic,strong) NSMutableArray *storedTrustFactorObjects;

#pragma mark - Add
// Add an array of new storedTrustFactorObjects to the store
- (BOOL)addMultipleObjectsToStore:(NSArray *)storedTrustFactorObjects withError:(NSError **)error;

// add a single storedTrustFactorObject into the store
- (BOOL)addSingleObjectToStore:(Sentegrity_Stored_TrustFactor_Object *)newStoredTrustFactorObject withError:(NSError **)error;

#pragma mark - Replace

// Replace an array of storedTrustFactorObjects  in the store
- (BOOL)replaceMultipleObjectsInStore:(NSArray *)existingStoredTrustFactorObjects withError:(NSError **)error;

// Replace a single storedTrustFactorObject in the store
- (BOOL)replaceSingleObjectInStore:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error;

#pragma mark - Remove

// Remove provided storedTrustFactorObject  from the store - returns whether it passed or failed
- (BOOL)removeSingleObjectFromStore:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error;

// Remove array of storedTrustFactorObjects  from the store - returns whether it passed or failed
- (BOOL)removeMultipleObjectsFromStore:(NSArray *)storedTrustFactorObjects withError:(NSError **)error;

#pragma mark - Helper Methods

// Create a new storedTrustFactorObject from TrustFactorOutputObject
- (Sentegrity_Stored_TrustFactor_Object *)createStoredTrustFactorObjectFromTrustFactorOutput:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error;

// Get an storedTrustFactorObject by a factorID
- (Sentegrity_Stored_TrustFactor_Object *)getStoredTrustFactorObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error;


@end
