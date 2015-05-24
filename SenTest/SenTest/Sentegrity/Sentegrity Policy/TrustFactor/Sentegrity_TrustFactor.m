//
//  Sentegrity_TrustFactors.m
//  SenTest
//
//  Created by Walid Javed on 2/4/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor.h"

@implementation Sentegrity_TrustFactor

// Identification
- (void)setIdentification:(NSNumber *)identification{
    _identification = identification;
}

// Description
- (void)setDesc:(NSString *)desc{
    _desc = desc;
}

// Revision
- (void)setRevision:(NSNumber *)revision{
    _revision = revision;
}

// ClassID
- (void)setClassID:(NSNumber *)classID{
    _classID = classID;
}

// SubclassID
- (void)setSubClassID:(NSNumber *)subClassID{
    _subClassID = subClassID;
}

// Priority
- (void)setPriority:(NSNumber *)priority{
    _priority = priority;
}

// Name
- (void)setName:(NSString *)name{
    _name = name;
}

// Penalty
- (void)setPenalty:(NSNumber *)penalty{
    _penalty = penalty;
}

//DNEPenalty
- (void)setDnePenalty:(NSNumber *)dnePenalty{
    _dnePenalty = dnePenalty;
}

//LearnMode
- (void)setLearnMode:(NSNumber *)learnMode{
    _learnMode = learnMode;
}

// LearnTime
- (void)setLearnTime:(NSNumber *)learnTime{
    _learnTime = learnTime;
}

// LearnAssertionCount
- (void)setLearnAssertionCount:(NSNumber *)learnAssertionCount{
    _learnAssertionCount = learnAssertionCount;
}

// LearnRunCount
- (void)setLearnRunCount:(NSNumber *)learnRunCount{
    _learnRunCount = learnRunCount;
}

// Threshold
- (void)setThreshold:(NSNumber *)threshold{
    _threshold = threshold;
}

// Provision
- (void)setProvision:(NSNumber *)provision{
    _provision = provision;
}

// Managed
- (void)setManaged:(NSNumber *)managed{
    _managed = managed;
}

// Local
- (void)setLocal:(NSNumber *)local{
    _local = local;
}

// History
- (void)setHistory:(NSNumber *)history{
    _history = history;
}

// Dispatch
- (void)setDispatch:(NSString *)dispatch{
    _dispatch = dispatch;
}

// Implementation
- (void)setImplementation:(NSString *)implementation{
    _implementation = implementation;
}

// Inverse
- (void)setInverse:(NSNumber *)inverse{
    _inverse = inverse;
}

// Payload
- (void)setPayload:(NSArray *)payload{
    _payload = payload;
}

@end
