//
//  Sentegrity.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

// Take in a file path and parse it - Done
// Process trustfactor rules and generate output (candidate assertions) - Done
// Compare the output to the stored previous outputs (baseline assertions) and learn from output
// Compute the penalty associated with which rules triggered and summarize the results
/*
 Summarize penalties by subclass and classifications, applying appropriate weights
 Generate TrustScores per classification
 Generate User, System, and Device TrustScores for return to a subscriber via IPC
 */

// Analyze computed TrustScores and compare them against policy provided thresholds to determine if a violation has occured and which protect mode to implement where appropriate

/*
 ##Outline##
 
 // Nick
 Parse policy from file
 
 // Walid
 Process rules
 
 // Walid-Nick
 Generate assertions
 
 // Nick
 Create assertion store
 Create TrustFactor and Assertion object
 
 // Nick
 Perform TrustScore computation
 
 // Walid
 Perform Protect Mode analysis

*/



#ifndef SenTest_Sentegrity_h
#define SenTest_Sentegrity_h

// Constants
#import "Sentegrity_Constants.h"

// Core Detection
#import "CoreDetection.h"

// Sentegrity Classes
#import "Sentegrity_Parser.h"
#import "Sentegrity_Policy.h"
#import "Sentegrity_DNEModifiers.h"
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_TrustFactor_Dispatcher.h"
#import "Sentegrity_TrustFactor_Output.h"
#import "Sentegrity_Assertion_Store.h"
#import "Sentegrity_TrustFactor_Storage.h"


#endif