//
//  Sentegrity_Assertion_Store_Assertion_Object.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_Stored_Assertion : NSObject

// Hash the Assertion
@property (atomic,retain) NSString *assertionHash;

// Hit Counter
@property (atomic,retain) NSNumber *hitCount;

// Date and Time of last hit
@property (atomic,retain) NSNumber *lastTime;

// Date and Time first created
@property (atomic,retain) NSNumber *created;

// How many time to learn from
@property (atomic) double decayMetric;

@end
