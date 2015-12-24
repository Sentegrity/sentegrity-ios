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


// issue message
- (void)setIssueMessage:(NSString *)trustedMessage{
    _issueMessage = trustedMessage;
}

// suggestion message
- (void)setSuggestionMessage:(NSString *)untrustedMessage{
    _suggestionMessage = untrustedMessage;
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


// Decay Mode
- (void)setDecayMode:(NSNumber *)decayMode{
    _decayMetric= decayMode;
}

// Decay Metric
- (void)setDecayMetric:(NSNumber *)decayMetric{
    _decayMetric = decayMetric;
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
- (void)setRuleType:(NSNumber *)ruleType{
    _ruleType = ruleType;
}

// Whitelistable
- (void)setWhitelistable:(NSNumber *)whitelistable{
    _whitelistable = whitelistable;
}

// PrivateAPI
- (void)setPrivateAPI:(NSNumber *)privateAPI{
    _privateAPI = privateAPI;
}

// Payload
- (void)setPayload:(NSArray *)payload{
    _payload = payload;
}

@end
