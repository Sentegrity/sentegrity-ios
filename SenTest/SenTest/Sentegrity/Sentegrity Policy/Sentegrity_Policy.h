//
//  Sentegrity_Policy.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_DNEModifiers.h"

@interface Sentegrity_Policy : NSObject

@property (nonatomic,retain) NSNumber *policyID;
@property (nonatomic,retain) NSString *appID;
@property (nonatomic,retain) NSNumber *revision;
@property (nonatomic,retain) NSNumber *runtime;
@property (nonatomic,retain) NSNumber *userThreshold;
@property (nonatomic,retain) NSNumber *systemThreshold;
@property (nonatomic,retain) Sentegrity_DNEModifiers *DNEModifiers;
@property (nonatomic,retain) NSArray *classifications;
@property (nonatomic,retain) NSArray *subclassification;
@property (nonatomic,retain) NSArray *trustFactors;

// Is the policy the default policy?
@property BOOL isDefault;

@end
