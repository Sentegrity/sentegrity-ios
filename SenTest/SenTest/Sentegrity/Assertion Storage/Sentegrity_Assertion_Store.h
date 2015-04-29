//
//  Sentegrity_Assertion_Store.h
//  SenTest
//
//  Created by Kramer on 2/25/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Assertion_Stored_Assertion_Object.h"
#import "Sentegrity_TrustFactor_Output.h"

@interface Sentegrity_Assertion_Store : NSObject

// Security Token
@property (nonatomic,strong) NSString *securityToken;

// Assertion Objects
@property (nonatomic,strong) NSArray *assertions;

#pragma mark - Add

// Add an array of new assertions to the store - Skips existing assertions - Assertions must be formatted as assertion_objects
- (BOOL)addAssertionsIntoStore:(NSArray *)assertions withError:(NSError **)error;

// Add new assertion into the store - Skips existing assertions
- (BOOL)addAssertionIntoStore:(Sentegrity_Assertion_Stored_Assertion_Object *)assertion withError:(NSError **)error;

#pragma mark - Replace

// Replace an array of assertion objects in the store
- (BOOL)setAssertions:(NSArray *)assertions withError:(NSError **)error;

// Replace an assertion object in the store
- (BOOL)setAssertion:(Sentegrity_Assertion_Stored_Assertion_Object *)assertion withError:(NSError **)error;

#pragma mark - Compare

// Compare provided assertions with assertion objects in the store - Provides back all assertions after comparison - if no matching assertion object is found in the store, a new one is created
- (NSArray *)compareAssertionsInStoreWithAssertions:(NSArray *)assertions withError:(NSError **)error; // CORE FUNCTIONALITY

// Compare provided assertion with assertion object in the store - Provides back a list of changed - if no matching assertion object is found in the store, a new one is created
- (Sentegrity_Assertion_Stored_Assertion_Object *)findMatchingStoredAssertionInStore:(Sentegrity_TrustFactor_Output *)assertion withError:(NSError **)error; // CORE FUNCTIONALITY

#pragma mark - Remove

// Remove provided assertion object from the store - returns whether it passed or failed
- (BOOL)removeAssertion:(Sentegrity_Assertion_Stored_Assertion_Object *)assertion withError:(NSError **)error;

// Remove provided assertion objects from the store - returns whether it passed or failed
- (BOOL)removeAssertions:(NSArray *)assertions withError:(NSError **)error;

#pragma mark - Helper Methods

// Create a new assertion object from a generated trustfactor assertion
- (Sentegrity_Assertion_Stored_Assertion_Object *)createAssertionObjectFromTrustFactorOutput:(Sentegrity_TrustFactor_Output *)assertion withError:(NSError **)error;

// Get an assertion object by its factorID
- (Sentegrity_Assertion_Stored_Assertion_Object *)getAssertionObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error;

@end
