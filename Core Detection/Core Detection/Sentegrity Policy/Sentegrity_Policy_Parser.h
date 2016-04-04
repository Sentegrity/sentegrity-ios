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

@interface Sentegrity_Policy_Parser : NSObject

// Singleton instance
+ (id)sharedPolicy;

@property (atomic,retain) Sentegrity_Policy *currentPolicy;

/* Getter */
// Get the startup file
- (Sentegrity_Policy *)getPolicy:(NSError **)error;

/* Helper */
// Parse a policy json with a valid path
- (Sentegrity_Policy *)parsePolicyJSONWithError:(NSError **)error;


@end
