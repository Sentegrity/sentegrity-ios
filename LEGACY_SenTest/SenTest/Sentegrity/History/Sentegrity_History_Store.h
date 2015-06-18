//
//  Sentegrity_Assertion_Store_Assertion_Object.h
//  SenTest
//
//  Created by Kramer on 3/1/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sentegrity_History_Store : NSObject

// Time of execution
@property (nonatomic,retain) NSDate *runTime;

// System Score
@property (nonatomic,retain) NSNumber *systemScore;

// User Score
@property (nonatomic,retain) NSNumber *userScore;

// User Score
@property (nonatomic,retain) NSNumber *deviceScore;

// System Trusted
@property (nonatomic) BOOL systemTrusted;

// User Trusted
@property (nonatomic) BOOL userTrusted;

// User Trusted
@property (nonatomic) BOOL deviceTrusted;

// Policy Protect Mode
@property (nonatomic,retain) NSNumber *protectMode;

// Stored assertions dictionary [trustFactorID, assertion]
@property (nonatomic,retain) NSMutableDictionary *assertionsToWhitelist;

@end
