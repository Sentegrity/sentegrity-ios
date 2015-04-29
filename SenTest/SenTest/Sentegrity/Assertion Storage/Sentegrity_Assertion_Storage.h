//
//  Sentegrity_Assertion_Storage.h
//  SenTest
//
//  Created by Kramer on 2/25/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Assertion_Store.h"

@interface Sentegrity_Assertion_Storage : NSObject

@property (nonatomic,retain) NSURL *assertionStoragePath;

//TODO: Best way to identify applications to name the local store

// Singleton instance
+ (id)sharedStorage;

// Get the global store
- (Sentegrity_Assertion_Store *)getGlobalStore:(BOOL *)exists withError:(NSError **)error;

// Set the global store
- (Sentegrity_Assertion_Store *)setGlobalStore:(Sentegrity_Assertion_Store *)store overwrite:(BOOL)overWrite withError:(NSError **)error;

// Get a local store by name
- (Sentegrity_Assertion_Store *)getLocalStoreWithSecurityToken:(NSString *)securityToken doesExist:(BOOL *)exists withError:(NSError **)error;

// Set a store value - Returns the existing store (even if you overwrite it)
- (Sentegrity_Assertion_Store *)setLocalStore:(Sentegrity_Assertion_Store *)store forSecurityToken:(NSString *)securityToken overwrite:(BOOL)overWrite withError:(NSError **)error;

// Get a list of stores
- (NSArray *)getListOfStores:(NSError **)error;

@end
