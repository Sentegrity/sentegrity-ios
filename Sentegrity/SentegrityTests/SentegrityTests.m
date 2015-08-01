//
//  SentegrityTests.m
//  SentegrityTests
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// Sentegrity
#import "Sentegrity.h"

@interface SentegrityTests : XCTestCase

@end

@implementation SentegrityTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Test the Core Detection Singleton
- (void)testCoreDetectionSingleton {
    // Make sure the core detection singleton is valid
    XCTAssertNotNil([CoreDetection sharedDetection], @"Core Detection Shared Instance is valid");
}

- (void)testCoreDetectionDefaultPolicyParsing {
    // Make sure the core detection policy parsing is valid
    
    // Create an error
    NSError *error;
    
    // Get the policy
    NSURL *policyPath = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"policy"]];
    
    // Check if the policy path exists
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:policyPath.path]);
    
    // Parse the policy
    Sentegrity_Policy *policy = [[CoreDetection sharedDetection] parsePolicy:policyPath withError:&error];
    
    // Check if the policy is empty
    XCTAssertNotNil(policy);
}

// Test the Core Detection Sentegrity_TrustFactor_Storage Singleton
- (void)testCoreDetectionTrustFactorStorageSingleton {
    // Make sure it's not nil
    XCTAssertNotNil([Sentegrity_TrustFactor_Storage sharedStorage], @"Sentegrity_TrustFactor_Storage Shared Instance is valid");
}

// Test to make sure we can get the global store if it supposedly exists
- (void)testGlobalStoreExists {
    
    // Variables
    NSError *errorValue;
    BOOL globalStoreExists;
    
    // Get the test assertion store
    Sentegrity_Assertion_Store *testAssertionStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getGlobalStore:&globalStoreExists withError:&errorValue];
    
    // Check fi the global store exists
    if (globalStoreExists) {
        
        // Check to make sure the global store is not nil if it supposedly exists
        XCTAssertNotNil(testAssertionStore, @"Sentegrity Global Assertion Store says exists but nil");

        // Check to make sure there is no error
        XCTAssertNil(errorValue, @"Error value is nil");
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
