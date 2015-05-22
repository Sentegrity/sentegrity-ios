//
//  CoreDetection.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Policy.h"
#import "Sentegrity_Assertion_Store.h"
#import "Sentegrity_TrustScore_Computation.h"

@interface CoreDetection : NSObject {
    // Default policy url path
    NSURL *defaultPolicyURLPath;
}


// Singleton instance
+ (id)sharedDetection;


#pragma mark - Parsing

// Parse Default Policy
- (Sentegrity_Policy *)parseDefaultPolicy:(NSError **)error;

// Parse a Custom Policy
- (Sentegrity_Policy *)parseCustomPolicy:(NSURL *)customPolicyPath withError:(NSError **)error;

#pragma mark - TrustFactor Analysis


#pragma mark - Protect Mode Analysis

// Block Definition
typedef void (^coreDetectionBlock)(BOOL success, BOOL deviceTrusted, BOOL systemTrusted, BOOL userTrusted, NSArray *computationOutput, NSError *error);
// Protect Mode Analysis
- (void)performCoreDetectionWithPolicy:(Sentegrity_Policy *)policy withTimeout:(int)timeOut withCallback:(coreDetectionBlock)callback;


#pragma mark - Properties

// Default URL path to the default policy plist (Documents is preferred, default is Resources Bundle)
@property (nonatomic, retain) NSURL *defaultPolicyURLPath;

@end
