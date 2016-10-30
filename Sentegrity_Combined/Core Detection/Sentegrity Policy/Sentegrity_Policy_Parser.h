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
// Get the policy file
- (Sentegrity_Policy *)getPolicy:(NSError **)error;

/* Setter */
// Set new policy file to be ready for next run
- (BOOL)saveNewPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error;

/* Helper */
// Parse a policy jsonObject
- (Sentegrity_Policy *)parsePolicyJSONobject:(NSDictionary *) jsonParsed withError:(NSError **)error;

// manually get policy from the bundle
- (Sentegrity_Policy *)loadPolicyFromMainBundle:(NSError **) error;

@end
