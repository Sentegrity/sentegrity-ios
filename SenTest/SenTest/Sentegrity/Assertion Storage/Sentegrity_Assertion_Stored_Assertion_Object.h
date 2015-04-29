//
//  Sentegrity_Assertion_Store_Assertion_Object.h
//  SenTest
//
//  Created by Kramer on 3/1/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Assertion_Store_Assertion_Object_Stored_Value.h"
#import "Sentegrity_TrustFactor_Output.h"

@interface Sentegrity_Assertion_Stored_Assertion_Object : NSObject

// Unique Identifier
@property (nonatomic,retain) NSNumber *factorID;
// Revision Number
@property (nonatomic,retain) NSNumber *revision;
// History - How many to learn from
@property (nonatomic,retain) NSNumber *history;
// Learning mode allowed
@property BOOL learned;
// First run date
@property (nonatomic,retain) NSDate *firstRun;
// Run count
@property (nonatomic,retain) NSNumber *runCount;
// Stored values
@property (nonatomic,retain) Sentegrity_Assertion_Store_Assertion_Object_Stored_Value *stored;

// Compare the assertion object values
- (instancetype)compare:(Sentegrity_TrustFactor_Output *)assertion withError:(NSError **)error;

@end
