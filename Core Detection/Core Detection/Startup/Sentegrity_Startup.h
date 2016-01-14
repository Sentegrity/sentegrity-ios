//
//  Sentegrity_TrustFactor_Datasets.h
//  Sentegrity
//
//  Copyright (c) 2016 Sentegrity. All rights reserved.
//

#import <Foundation/Foundation.h>

// Sentegrity History
#import "Sentegrity_History.h"

@interface Sentegrity_Startup : NSObject

// Device Salt
@property (nonatomic, copy) NSString *deviceSalt;

// Core Detection Checksum
@property (nonatomic, assign) NSInteger coreDetectionChecksum;

// Run History
@property (nonatomic, strong) Sentegrity_History *runHistory;

// User Salt
@property (nonatomic, copy) NSString *userSalt;

// Last State of application
@property (nonatomic, copy) NSString *lastState;

// Last OS Version
@property (nonatomic, copy) NSString *lastOSVersion;

@end