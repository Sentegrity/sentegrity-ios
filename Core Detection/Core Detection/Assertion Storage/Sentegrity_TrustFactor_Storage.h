//
//  Sentegrity_Assertion_Storage.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Assertion_Store.h"

@interface Sentegrity_TrustFactor_Storage : NSObject

// Singleton instance
+ (id)sharedStorage;

@property (atomic,retain) Sentegrity_Assertion_Store *currentStore;

// Get the assertion store
- (Sentegrity_Assertion_Store *)getAssertionStoreWithError:(NSError **)error;

// Set the asertion store
- (void)setAssertionStoreWithError:(NSError **)error;

// Store Path
@property (atomic,strong) NSString *storePath;

@end
