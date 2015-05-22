//
//  Sentegrity_Assertion_Store_Assertion_Object.h
//  SenTest
//
//  Created by Kramer on 3/1/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_Stored_TrustFactor_Object : NSObject

// Unique Identifier
@property (nonatomic,retain) NSNumber *factorID;
// Revision Number
@property (nonatomic,retain) NSNumber *revision;
// History - How many to learn from
@property (nonatomic,retain) NSNumber *history;
// Learning mode allowed
@property (nonatomic) BOOL learned;
// First run date
@property (nonatomic,retain) NSDate *firstRun;
// Run count
@property (nonatomic,retain) NSNumber *runCount;
// Stored assertions
@property (nonatomic,retain) NSMutableDictionary *assertions;

@end
