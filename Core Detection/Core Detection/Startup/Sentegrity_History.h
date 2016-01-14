//
//  Sentegrity_TrustFactor_Datasets.h
//  Sentegrity
//
//  Copyright (c) 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_History : NSObject

// Device Score
@property (nonatomic, assign) NSInteger deviceScore;

// Trust Score
@property (nonatomic, assign) NSInteger trustScore;

// Device Issues
@property (nonatomic, strong) NSArray<NSString *> *deviceIssues;

// User Score
@property (nonatomic, assign) NSInteger userScore;

// Timestamp
@property (nonatomic, copy) NSDate *timestamp;

// Protect Mode Action
@property (nonatomic, assign) NSInteger protectModeAction;

// User Issues
@property (nonatomic, strong) NSArray<NSString *> *userIssues;

@end