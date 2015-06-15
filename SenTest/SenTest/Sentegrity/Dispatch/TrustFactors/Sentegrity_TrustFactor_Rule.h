//
//  Sentegrity_TrustFactor_Rule.h
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>

// Import Constants
#import "Sentegrity_Constants.h"

// Import Assertions
#import "Sentegrity_TrustFactor_Output_Object.h"

@interface Sentegrity_TrustFactor_Rule : NSObject

// Validate the given payload
+ (BOOL)validatePayload:(NSArray *)payload;

/* Process Information */

// List of process information including PID's, Names, PPID's, and Status'
+ (NSArray *)processInformation;

// Parent ID for a certain PID
+ (int)parentPIDForProcess:(int)pid;

// Get self PID 
+ (int) getOurPID;


@end
