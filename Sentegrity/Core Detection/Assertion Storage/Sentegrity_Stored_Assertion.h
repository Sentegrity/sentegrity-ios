//
//  Sentegrity_Assertion_Store_Assertion_Object.h
//  SenTest
//
//  Created by Kramer on 3/1/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_Stored_Assertion : NSObject

// Hash
@property (nonatomic,retain) NSString *assertionHash;
// Hit counter
@property (nonatomic,retain) NSNumber *hitCount;
// date and time of last hit
@property (nonatomic,retain) NSNumber *lastTime;
// date and time first created
@property (nonatomic,retain) NSNumber *created;
// date and time first created
@property (nonatomic) float decayMetric;



@end
