//
//  CoreDetection.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Constants.h"
#import "Sentegrity_Parser.h"
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_TrustScore_Computation.h"
//#import "Sentegrity_Subclassification.h"
#import "Sentegrity_TrustFactor_Dispatcher.h"
#import "Sentegrity_TrustFactor_Storage.h"
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"
#import "Sentegrity_Baseline_Analysis.h"

@interface CoreDetection : NSObject


// Singleton instance
+ (id)sharedDetection;


#pragma mark - Parsing

// Parse a  Policy
- (Sentegrity_Policy *)parsePolicy:(NSURL *)policyPath withError:(NSError **)error;


#pragma mark - Core Detection

// Block Definition
typedef void (^coreDetectionBlock)(BOOL success, Sentegrity_TrustScore_Computation *computationResults, Sentegrity_Baseline_Analysis *baselineResults, Sentegrity_Policy *policy, NSError *error);

// Start Core Detection
- (void)performCoreDetectionWithPolicy:(Sentegrity_Policy *)policy withTimeout:(int)timeOut withCallback:(coreDetectionBlock)callback;


#pragma mark - Properties


@property (nonatomic, retain) Sentegrity_Policy *currentPolicy;

@end
