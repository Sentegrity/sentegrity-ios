//
//  Sentegrity_Parser.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Sentegrity parser analyzes the plist given and puts it into our policy.
 *
 */

#import <Foundation/Foundation.h>
#import "Sentegrity_Policy.h"
#import "Sentegrity_Assertion_Store.h"

@interface Sentegrity_Parser : NSObject

// Parse a policy plist with a valid path
- (Sentegrity_Policy *)parsePolicyPlistWithPath:(NSURL *)filePathURL withError:(NSError **)error;

// Parse a policy json with a valid path
- (Sentegrity_Policy *)parsePolicyJSONWithPath:(NSURL *)filePathURL withError:(NSError **)error;

// Parse Assertion Store with a valid path
- (Sentegrity_Assertion_Store *)parseAssertionStoreWithPath:(NSURL *)assertionStorePathURL withError:(NSError **)error;

@end
