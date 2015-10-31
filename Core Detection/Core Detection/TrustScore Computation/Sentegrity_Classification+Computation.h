//
//  Sentegrity_Classification+Computation.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_Classification.h"

@interface Sentegrity_Classification (Computation)

// Links
@property (nonatomic,retain) NSArray *subClassifications;
@property (nonatomic,retain) NSArray *trustFactors;

// Protect Mode
@property (nonatomic,retain) NSArray *trustFactorsToWhitelist;

// Debug Information
@property (nonatomic,retain) NSArray *trustFactorsNotLearned;
@property (nonatomic,retain) NSArray *trustFactorsTriggered;
@property (nonatomic,retain) NSArray *trustFactorsWithErrors;

// Penalty
@property (nonatomic) NSInteger basePenalty;
@property (nonatomic) NSInteger weightedPenalty;

// Messages
@property (nonatomic,retain) NSArray *issues;
@property (nonatomic,retain) NSArray *suggestions;
@property (nonatomic,retain) NSArray *status;

@end
