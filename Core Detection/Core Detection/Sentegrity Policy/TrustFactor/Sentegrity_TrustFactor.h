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
@property (nonatomic, retain) NSString *issueMessage;
@property (nonatomic, retain) NSString *suggestionMessage;
@property (nonatomic, retain) NSNumber *revision;
@property (nonatomic, retain) NSNumber *classID;
@property (nonatomic, retain) NSNumber *subClassID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *penalty;
@property (nonatomic, retain) NSNumber *dnePenalty;
@property (nonatomic, retain) NSNumber *ruleType;
@property (nonatomic, retain) NSNumber *learnMode;
@property (nonatomic, retain) NSNumber *learnTime;
@property (nonatomic, retain) NSNumber *learnAssertionCount;
@property (nonatomic, retain) NSNumber *learnRunCount;
@property (nonatomic, retain) NSNumber *threshold;
@property (nonatomic, retain) NSNumber *whitelistable;
@property (nonatomic, retain) NSNumber *privateAPI;
@property (nonatomic, retain) NSNumber *decayMode;
@property (nonatomic, retain) NSNumber *decayMetric;
@property (nonatomic, retain) NSString *dispatch;
@property (nonatomic, retain) NSString *implementation;
@property (nonatomic, retain) NSArray *payload;

@end
