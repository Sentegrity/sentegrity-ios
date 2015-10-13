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
#import "ProtectMode.h"

// Sentegrity Classes
#import "Sentegrity_Parser.h"
#import "Sentegrity_Policy.h"
#import "Sentegrity_DNEModifiers.h"
#import "Sentegrity_TrustScore_Computation.h"
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_TrustFactor_Dispatcher.h"
#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_Stored_TrustFactor_Object.h"
#import "Sentegrity_Assertion_Store.h"
#import "Sentegrity_TrustFactor_Storage.h"
#import "Sentegrity_Baseline_Analysis.h"

#endif