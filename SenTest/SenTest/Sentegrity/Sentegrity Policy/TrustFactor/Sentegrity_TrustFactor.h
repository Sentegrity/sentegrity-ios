//
//  Sentegrity_TrustFactors.h
//  SenTest
//
//  Created by Walid Javed on 2/4/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_TrustFactor : NSObject

@property (nonatomic, retain) NSNumber *identification;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSNumber *classID;
@property (nonatomic, retain) NSNumber *subClassID;
@property (nonatomic, retain) NSNumber *priority;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *penalty;
@property (nonatomic, retain) NSNumber *dnePenalty;
@property (nonatomic, retain) NSNumber *learnMode;
@property (nonatomic, retain) NSNumber *learnTime;
@property (nonatomic, retain) NSNumber *learnAssertionCount;
@property (nonatomic, retain) NSNumber *learnRunCount;
@property (nonatomic, retain) NSNumber *managed;
@property (nonatomic, retain) NSNumber *local;
@property (nonatomic, retain) NSNumber *history;
@property (nonatomic, retain) NSString *dispatch;
@property (nonatomic, retain) NSString *implementation;
@property (nonatomic, retain) NSNumber *baseline;
@property (nonatomic, retain) NSArray *payload;

@end
