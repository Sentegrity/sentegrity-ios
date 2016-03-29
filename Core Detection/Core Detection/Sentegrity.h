//
//  Sentegrity.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/*!
 *  Sentegrity is a class that runs a determined policy and provides the output
 */

#ifndef Sentegrity_h
#define Sentegrity_h

// Constants
#import "Sentegrity_Constants.h"

// Core Detection
#import "CoreDetection.h"

// Protect Mode
#import "LoginAction.h"

// Parser of policy files - takes json and plist
#import "Sentegrity_Policy_Parser.h"

// Policy
#import "Sentegrity_Policy.h"

// Startup
#import "Sentegrity_Startup_Store.h"

// Did not execute modifiers
#import "Sentegrity_DNEModifiers.h"

// Trustscore computation and information about the score
#import "Sentegrity_TrustScore_Computation.h"

// Classification and additions
#import "Sentegrity_Classification+Computation.h"

// Subclassifications and Addiditons
#import "Sentegrity_Subclassification+Computation.h"

// TrustFactor - Basically a rule that gets run
#import "Sentegrity_TrustFactor.h"

// Dispatcher - The rule dispatcher
#import "Sentegrity_TrustFactor_Dispatcher.h"

// TrustFactor Output Object - Assertion
#import "Sentegrity_TrustFactor_Output_Object.h"

// TrustFactor Stored Object - Stored information about the assertion
#import "Sentegrity_Stored_TrustFactor_Object.h"

// Assertion Store - Storage for assertions
#import "Sentegrity_Assertion_Store.h"

// Storage for Assertions and TrustFactors
#import "Sentegrity_TrustFactor_Storage.h"

// Baseline Analysis - Information about the output
#import "Sentegrity_Baseline_Analysis.h"

// Activity Dispatcher
#import "Sentegrity_Activity_Dispatcher.h"

#endif