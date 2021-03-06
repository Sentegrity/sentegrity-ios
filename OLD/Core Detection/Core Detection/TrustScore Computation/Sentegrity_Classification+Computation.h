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

// Transparent authentication
@property (nonatomic,retain) NSArray *trustFactorsForTransparentAuthentication;

// Debug Information
@property (nonatomic,retain) NSArray *trustFactorsNotLearned;
@property (nonatomic,retain) NSArray *trustFactorsTriggered;
@property (nonatomic,retain) NSArray *trustFactorsWithErrors;

// Weight
@property (nonatomic) NSInteger score;

// Messages
@property (nonatomic,retain) NSArray *issues;
@property (nonatomic,retain) NSArray *suggestions;
@property (nonatomic,retain) NSArray *status;
@property (nonatomic,retain) NSArray *dynamicTwoFactors;

@end
