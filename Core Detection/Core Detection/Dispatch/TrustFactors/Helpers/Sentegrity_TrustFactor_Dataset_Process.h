//
//  Sentegrity_TrustFactor_Rule.h
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

// Import Constants
#import "Sentegrity_Constants.h"

// Headers
#import <Foundation/Foundation.h>
#import <sys/sysctl.h>

@interface Process_Info : NSObject

// List of process information including PID's, Names, PPID's, and Status'
+ (NSArray *)getProcessInfo;

// Get self PID
+ (NSNumber *) getOurPID;

@end
