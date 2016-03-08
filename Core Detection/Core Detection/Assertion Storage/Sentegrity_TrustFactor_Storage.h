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

// Get the assertion store
- (Sentegrity_Assertion_Store *)getAssertionStore:(BOOL *)exists withAppID:(NSString *)appID withError:(NSError **)error;

// Set the asertion store
- (Sentegrity_Assertion_Store *)setAssertionStore:(Sentegrity_Assertion_Store *)store withAppID:(NSString *)appID withError:(NSError **)error;

// Store Path
@property (atomic,strong) NSString *storePath;

@end
