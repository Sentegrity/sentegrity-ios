//
//  Sentegrity_TrustFactor_Datasets.h
//  Sentegrity
//
//  Copyright (c) 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_History_Object : NSObject

// Device Score
@property (nonatomic, assign) NSInteger deviceScore;

// Trust Score
@property (nonatomic, assign) NSInteger trustScore;

// User Score
@property (nonatomic, assign) NSInteger userScore;

// Timestamp
@property (nonatomic, copy  ) NSDate    *timestamp;

// Violation Action
@property (nonatomic, assign) NSInteger violationAction;

// Authentication  Action
@property (nonatomic, assign) NSInteger authenticationAction;

// Core Detection Result
@property (nonatomic, assign) NSInteger coreDetectionResult;

// Core Detection Result
@property (nonatomic, assign) NSInteger authenticationResponseCode;

// User Issues
@property (nonatomic, strong) NSArray<NSString  *> *userIssues;

// System Issues
@property (nonatomic, strong) NSArray<NSString  *> *SystemIssues;

// User Analysis Results
@property (nonatomic, strong) NSArray<NSString  *> *userAnalysisResults;

// System Analysis Results
@property (nonatomic, strong) NSArray<NSString  *> *systemAnalysisResults;

@end