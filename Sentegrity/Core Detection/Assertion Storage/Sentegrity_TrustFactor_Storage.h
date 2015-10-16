//
//  Sentegrity_Assertion_Storage.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Assertion_Store.h"

@interface Sentegrity_TrustFactor_Storage : NSObject

//TODO: Best way to identify applications to name the local store

// Singleton instance
+ (id)sharedStorage;

// Get the global store
- (Sentegrity_Assertion_Store *)getGlobalStore:(BOOL *)exists withError:(NSError **)error;

// Set the global store
- (Sentegrity_Assertion_Store *)setGlobalStore:(Sentegrity_Assertion_Store *)store withError:(NSError **)error;

// Get the local store
- (Sentegrity_Assertion_Store *)getLocalStore:(BOOL *)exists withAppID:(NSString *)appID withError:(NSError **)error;

// Set the local store
- (Sentegrity_Assertion_Store *)setLocalStore:(Sentegrity_Assertion_Store *)store withAppID:(NSString *)appID withError:(NSError **)error;

// Store Path
@property (atomic,strong) NSString *storePath;

@end
