//
//  Sentegrity_Classification+Computation.h
//  SenTest
//
//  Created by Kramer on 4/15/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Classification.h"

@interface Sentegrity_Classification (Computation)

@property (nonatomic,retain) NSArray *subClassifications;
@property (nonatomic,retain) NSArray *trustFactors;
@property (nonatomic) NSInteger weightedPenalty;

@end
