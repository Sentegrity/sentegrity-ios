//
//  Sentegrity_Assertion_Store_Assertion_Object.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sentegrity_Stored_Assertion.h"

@interface Sentegrity_Stored_TrustFactor_Object : NSObject

// Unique Identifier
@property (nonatomic,retain) NSNumber *factorID;
// Revision Number
@property (nonatomic,retain) NSNumber *revision;
// History - How many to learn from
@property (nonatomic,retain) NSNumber *decayMetric;
// Learning mode allowed
@property (nonatomic) BOOL learned;
// First run date
@property (nonatomic,retain) NSDate *firstRun;
// Run count
@property (nonatomic,retain) NSNumber *runCount;

// Array of Sentegrity_Stored_Assertion objects
@property (nonatomic,retain) NSArray *assertionObjects;


@end
