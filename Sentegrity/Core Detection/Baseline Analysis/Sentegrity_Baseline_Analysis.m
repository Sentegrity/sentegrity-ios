//
//  Sentegrity_Baseline_Analysis.m
//  SenTest
//
//  Created by Jason Sinchak on 5/20/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sentegrity_Baseline_Analysis.h"
#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_Assertion_Store.h"
#import "Sentegrity_Policy.h"
#import "Sentegrity_TrustFactor_Storage.h"


// Pod for hashing
#import "NSString+Hashes.h"

@implementation Sentegrity_Baseline_Analysis

//@synthesize trustFactorOutputObjectsForProtectMode = _trustFactorOutputObjectsForProtectMode, trustFactorOutputObjectsForComputation = _trustFactorOutputObjectsForComputation;

static NSTimeInterval nowEpochSeconds;

// Retrieve stored assertions
+ (NSArray *)performBaselineAnalysisUsing:(NSArray *)trustFactorOutputObjects forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    
    
    // Create a bool to check if local store exists
    BOOL exists = NO;
    
    
    // Attempt to get our local assertion store
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getLocalStore:&exists withAppID:policy.appID withError:error];
    
    // Check if the local store exists (should, unless is the first run for this policy)
    if (!localStore || localStore == nil || !exists) {
        
        NSLog(@"Local store did not exist...creating blank");
        // Create the store for the first time
        localStore = [[Sentegrity_Assertion_Store alloc] init];
        
        // Check if we've failed again
        if (!localStore || localStore == nil) {
            return nil;
        }
    }
    
    
    // Create the mutable array to hold the storedTrustFactoObjects for each trustFactorOutputObject
    Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject;
    
    //Updated trustFactorOutputObject
    Sentegrity_TrustFactor_Output_Object *updatedTrustFactorOutputObject;
    
    //Set lastTime for all assertions
    nowEpochSeconds = [[NSDate date] timeIntervalSince1970];
    
    // Run through all the trustFactorOutput objects and determine if they're local or global TrustFactors and perform compare
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorOutputObjects)
    {
        
        // Check if the TrustFactor is valid to start with
        if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
            // Error out, no trustFactorOutputObject were able to be added
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Invalid trustFactorOutputObject passed" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStoredTrustFactorObjectsProvided userInfo:errorDetails];
            
            // Don't return anything
            return nil;
        }
        
        // Check DNE status code prior to computation to avoid evaluation non-ok rules, but do evaluate nodata so that they can update learning
        if(trustFactorOutputObject.statusCode != DNEStatus_ok && trustFactorOutputObject.statusCode != DNEStatus_nodata){
            continue;
        }
        
            
        // Find the matching stored assertion object for the trustfactor in the local store
        storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
        
        
        // If we could not find an existing stored assertion in the local store create it
        if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists==NO) {
            
            storedTrustFactorObject = [localStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
            
            NSLog(@"Could not find storedTrustFctorObject in local store, creating new");
            
            // Check returned object
            if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
                // Error out, no trustFactorOutputObject were able to be added
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to create new storedTrustFactorObject for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToCreateNewStoredAssertion userInfo:errorDetails];
                
                // Don't return anything
                return nil;
            }
            
            //add the created storedTrustFactorObject to the current trustFactorOutputObject
            trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
            
            //perform baseline analysis against storedTrustFactorObject
            updatedTrustFactorOutputObject =[self performBaselineAnalysisUsing:trustFactorOutputObject withError:error];
            
            // Check if we got a result
            if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                // Error out, something went wrong in compare
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                
                // Don't return anything
                return nil;
            }
            
            
            //add the new storedTrustFactorObject to the runtime local store, to be written later
            if (![localStore addSingleObjectToStore:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                //Error out, no storedTrustFactorObjects were able to be added
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"No storedTrustFactorObjects addeded to local store" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                
                // Don't return anything
                return nil;
            }
            
            
            
        }
        else // we found an existing stored assertion, check revisions
        {
            
            
            //if revisions do not match create new
            if (![self checkTrustFactorRevision:trustFactorOutputObject withStored:storedTrustFactorObject]) {
                
                //create a new object in the local store
                storedTrustFactorObject = [localStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                
                //update the trustFactorOutputObject with newly created storedTrustFactorObject
                trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
                
                //perform baseline analysis against storedTrustFactorObject
                updatedTrustFactorOutputObject =[self performBaselineAnalysisUsing:trustFactorOutputObject withError:error];
                
                // Check if we got a result
                if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                    // Error out, something went wrong in compare
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                //replace existing in the local store
                if (![localStore replaceSingleObjectInStore:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                    // Error out, no storedTrustFactorOutputObjects were able to be added
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"Unable to replace stored assertion" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                
            }
            else{ //revisions match, no replacement required
                
                //update the trustFactorOutputObject with newly created storedTrustFactorObject
                trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
    
                //perform baseline analysis against storedTrustFactorObject
                updatedTrustFactorOutputObject = [self performBaselineAnalysisUsing:trustFactorOutputObject withError:error];
                
                // Check if we got a result
                if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                    // Error out, something went wrong in compare
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                //since we modified, replace existing in the local store
                if (![localStore replaceSingleObjectInStore:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                    // Error out, no storedTrustFactorOutputObjects were able to be added
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"Unable to replace stored assertion" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                
            }
            
            
        }
        
        
    } //end FOR
    
    //save stores due to learning mode updates
    exists = YES;
    
    
    //update stores
    Sentegrity_Assertion_Store *localStoreOutput = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore withAppID:policy.appID withError:error];
    
    if (!localStoreOutput || localStoreOutput == nil) {
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error writing assertion stores after baseline analysis" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWriteStore userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    return trustFactorOutputObjects;
}




+ (Sentegrity_TrustFactor_Output_Object *)performBaselineAnalysisUsing:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    

    Sentegrity_TrustFactor_Output_Object *updatedTrustFactorOutputObject;
    
    trustFactorOutputObject.assertionObjectsToWhitelist = [[NSMutableArray alloc] init];
    
    
    if (!trustFactorOutputObject) {
        // Failed, no trustFactorOutputObject found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No trustFactorOutputObject received or candidate assertions for compare" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    
    // Check if we should decay
    // If the assertion store is greater than the TF's max history value
    if(trustFactorOutputObject.storedTrustFactorObject.assertionObjects.count >= [trustFactorOutputObject.trustFactor.history integerValue]){
        
        trustFactorOutputObject = [self performDecay:trustFactorOutputObject withError:error];
        
        if (!trustFactorOutputObject) {
            // Failed, no trustFactorOutputObject found
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Error during TrustFactor decay" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAErrorDuringDecay userInfo:errorDetails];
            
            // Don't return anything
            return nil;
        }
        
    }

    
    // Create assertions
    switch (trustFactorOutputObject.trustFactor.ruleType.intValue) {
        case 1: //Rule type 1 leverages a default assertion to look for blacklisted artifacts on the system or enforce user policies
            
            // Must be the first time this has run
            if(trustFactorOutputObject.storedTrustFactorObject.learned==NO)
            {
                // Set stored assertion to the default for proper comparison
                trustFactorOutputObject.storedTrustFactorObject.assertionObjects = [NSArray arrayWithObjects:[trustFactorOutputObject defaultAssertionObject],nil];
                
                // Set to learned
                trustFactorOutputObject.storedTrustFactorObject.learned=YES;
                
            }
            
            // Run baseline analysis
            updatedTrustFactorOutputObject = [self checkBaselineForNoMatch:trustFactorOutputObject withError:error];
          

            break;
        case 2: // Rule Type 2 employs various learning for system anomaly detection, no default assertion is used, these rules don't take effect right away
            
            // If TF is learned run baseline analysis
            if(trustFactorOutputObject.storedTrustFactorObject.learned==YES)
            {
                updatedTrustFactorOutputObject = [self checkBaselineForNoMatch:trustFactorOutputObject withError:error];
            }
            else{ // Not yet learned, just update learning and don't baseline
              
                updatedTrustFactorOutputObject = [self updateLearningAndAddCandidateAssertions:trustFactorOutputObject withError:error];

            }
            
            break;
        case 3: // Rule Type 3 builds a profile to identify known-good good user conditions one login at a time, good conditions are determined by login therefore no learning occurs, everything triggers on first run

            // Must be the first time this has run
            if(trustFactorOutputObject.storedTrustFactorObject.learned==NO)
            {
                // Do any first time stuff here
                
                // Set to learned
                trustFactorOutputObject.storedTrustFactorObject.learned=YES;
                
            }
            
            updatedTrustFactorOutputObject = [self checkBaselineForNoMatch:trustFactorOutputObject withError:error];
            
            break;
        case 4: // Rule Type 4 employs learned assertions to identify good conditions but flips when it triggers (does not penalize for no match)
            
            // Must be the first time this has run
            if(trustFactorOutputObject.storedTrustFactorObject.learned==NO)
            {
                // Do any first time stuff here
                
                // Set to learned
                trustFactorOutputObject.storedTrustFactorObject.learned=YES;
                
            }
            
            updatedTrustFactorOutputObject = [self checkBaselineForAMatch:trustFactorOutputObject withError:error];

            
            break;
        default:
            break;
    }
    
    if (!updatedTrustFactorOutputObject) {
        // Failed, no trustFactorOutputObject found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error during TrustFactor learning check" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAErrorDuringLearningCheck userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }

    

    return updatedTrustFactorOutputObject;
    
    
}

+ (Sentegrity_TrustFactor_Output_Object *)checkBaselineForNoMatch:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    // Now we do the real  baseline analysis
    NSNumber *origHitCount;
    NSNumber *newHitCount;
    NSMutableArray *assertionObjectsToWhitelist;
    BOOL foundMatch;
    
    
    //trigger on NO MATCH in the baseline
    //e.g., knownBadProcesses, shortUptime, newRootProcess, etc
    
    // List of individual candidates that should be whitelisted in the TF if/when it goes into protect mode
    assertionObjectsToWhitelist = [[NSMutableArray alloc]init];
    
    for(Sentegrity_Stored_Assertion *candidate in trustFactorOutputObject.assertionObjects)
    {
        foundMatch=NO;
        
        // Iterate through all stored assertions for this TF looking for a match on the candidate
        for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
            
            //search for a match in the stored objetcs
            if([[candidate assertionHash] isEqualToString:[stored assertionHash]]){
                foundMatch=YES;
                // Set so that it can be used later
                
                //we DID find a match, RULE NOT YET TRIGGERED  (increment matching stored assertions hitcount & check threshold)
                origHitCount = [stored hitCount];
                newHitCount = [NSNumber numberWithInt:[origHitCount intValue]+1];
                [stored setHitCount:newHitCount];
                [stored setLastTime:[NSNumber numberWithInteger:nowEpochSeconds]];
                
                //if this rules has frequency requirments then enforce them
                if(trustFactorOutputObject.trustFactor.threshold.intValue != 0)
                {
                    // Still strigger the rule if we have not meet the hitcount threshold, regardless of if its in the store or not (generally only user anomaly rules)
                    if(newHitCount < trustFactorOutputObject.trustFactor.threshold)
                    {
                        //only add as triggered if meet
                        trustFactorOutputObject.triggered=YES;
                        
                    }
                    
                }

                break;
            }
        }
        
        //We DID NOT find a match for the candidate in the store = RULE TRIGGERED (a bad thing, since it should match the kDefaultTrustFactorOutput assertion at the very least)
        if(foundMatch==NO)
        {
            // Trigger rule
            trustFactorOutputObject.triggered=YES;
            
            //update list, but we still need to look at all assertions before exiting loop
            if(trustFactorOutputObject.trustFactor.whitelistable.intValue == 1){
                //Add non matching assertion to whitelist for TF
                [assertionObjectsToWhitelist addObject:candidate];
                trustFactorOutputObject.whitelist=YES;
            }
            
        } // End notfound/found if/else
        
        
    } // End next candidate assertion
    
    // Set the whitelist to the mutable array using during runtime
    [trustFactorOutputObject setAssertionObjectsToWhitelist:assertionObjectsToWhitelist];
    
    
    return trustFactorOutputObject;
    
}

+ (Sentegrity_TrustFactor_Output_Object *)checkBaselineForAMatch:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    NSNumber *origHitCount;
    NSNumber *newHitCount;
    NSMutableArray *assertionObjectsToWhitelist;
    BOOL foundMatch;
    
    //trigger on MATCH to ensure negative penalty is applied, these are authenticator type rules (currently only: knownBLEDevice, KnowWifiBSSID)
    
    // List of individual candidates that should be whitelisted in the TF if/when it goes into protect mode
    assertionObjectsToWhitelist = [[NSMutableArray alloc]init];
    
    for(Sentegrity_Stored_Assertion *candidate in trustFactorOutputObject.assertionObjects)
    {
        foundMatch=NO;
        
        // Iterate through all stored assertions for this TF looking for a match on the candidate
        for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
            
            //search for a match in the stored objetcs
            if([[candidate assertionHash] isEqualToString:[stored assertionHash]]){
                foundMatch=YES;
                
                //we DID find a match, rule should trigger as its inverse (applies a negative value that boosts the score positively by negating penalties)
                trustFactorOutputObject.triggered=YES;
                
                //increment hitCount for matching stored assertion (used for decay)
                origHitCount = [stored hitCount];
                newHitCount = [NSNumber numberWithInt:[origHitCount intValue]+1];
                [stored setHitCount:newHitCount];
                [stored setLastTime:[NSNumber numberWithInteger:nowEpochSeconds]];
                
                //if this rules has frequency requirments then enforce them
                if(trustFactorOutputObject.trustFactor.threshold.intValue != 0)
                {
                    // Don't trigger the rule if we have not meet the hitcount threshold, regardless of if its in the store or not (generally only user anomaly rules)
                    if(newHitCount < trustFactorOutputObject.trustFactor.threshold)
                    {
                        //only add as triggered if meet
                        trustFactorOutputObject.triggered=NO;
                        
                    }
                    
                }
                break;
            }
        }
        
        //We DID NOT find a match for the candidate in the store don't do anything but add to whitelist since this is inverse (applies a negative value that boosts the score positively by negating penalties)
        if(foundMatch==NO)
        {
            if(trustFactorOutputObject.trustFactor.whitelistable.intValue == 1){
                
                [assertionObjectsToWhitelist addObject:candidate];
                trustFactorOutputObject.whitelist=YES;
            }
            
            
        }
     

        
    } // End next candidate assertion
    
    // Set the whitelist to the mutable array using during runtime
    [trustFactorOutputObject setAssertionObjectsToWhitelist:assertionObjectsToWhitelist];
    
    return trustFactorOutputObject;
    
}


+ (Sentegrity_TrustFactor_Output_Object *)performDecay:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    // Rules:
    // Sort all by hitsPerHour metric
    // Keep anything less than 30 min since last hit
   
    
    float secondsInAnHour = 3600;
    float hoursSinceCreation=0.0;
    float hoursSinceLastHit=0.0;
    float hitsPerHourMetric=0.0;

    // Current EPOCH
    NSDate *now = [NSDate date];
    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
    
    // Array to hold assertions to retain
    NSMutableArray *assertionObjectsToKeep = [[NSMutableArray alloc]init];
    
    // Array to hold assertions that were recenty created and should be kept to avoid destroying user experience
    NSMutableArray *assertionObjectsRecentlyCreated = [[NSMutableArray alloc]init];
    
    // Iterate through stored assertions for each trustFactorOutputObject
    for(Sentegrity_Stored_Assertion *storedAssertion in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
        
        // Calculate hours since the assertion was created
        hoursSinceCreation = ((float)nowEpochSeconds - [storedAssertion.created floatValue]) / secondsInAnHour;
    
        // Check hours since last hit
        hoursSinceLastHit = ((float)nowEpochSeconds - [storedAssertion.lastTime floatValue]) / secondsInAnHour;
        
        // Must be a minimum of 1
        if(hoursSinceCreation<1.0){
            hoursSinceCreation=1.0;
        }
        
        // Give new assertions a chance to catch up, hoursSinceCreation are new, hoursSinceLastHit prevent back-to-back user anomalies
        if(hoursSinceLastHit < 0.1) {
            
            // If history=0 (we want a clean slate after each run), then disregard lastHit time and dont add it
            if(trustFactorOutputObject.trustFactor.history.intValue != 0){
                    [assertionObjectsRecentlyCreated addObject:storedAssertion];
            }

            
        }

        // Calculate our core metric to normalize usage of an assertion regardless of its age
        hitsPerHourMetric = [storedAssertion.hitCount floatValue] / (hoursSinceCreation);
        
        // Set the metric
        [storedAssertion setDecayMetric:hitsPerHourMetric];
        
  

    }
    
    // Sort all assertions by decay metric, highest at top (in theory, the most frequently used)
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decayMetric"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray;
    
    sortedArray = [trustFactorOutputObject.storedTrustFactorObject.assertionObjects sortedArrayUsingDescriptors:sortDescriptors];
    
    //Trim NS to the history size
    assertionObjectsToKeep = [[sortedArray subarrayWithRange:NSMakeRange(0,trustFactorOutputObject.trustFactor.history.intValue)] mutableCopy];
    
    // Make sure we retain any newly created or just hit assertions
    for(Sentegrity_Stored_Assertion *recentAssertion in assertionObjectsRecentlyCreated){

         //If its not already in the sorted array add it to it
        if(![assertionObjectsToKeep containsObject:recentAssertion]){
            [assertionObjectsToKeep addObject:recentAssertion];
        }

    }
    
    // Set stored assertions back
    trustFactorOutputObject.storedTrustFactorObject.assertionObjects = assertionObjectsToKeep;
    
    return trustFactorOutputObject;
 }

+ (Sentegrity_TrustFactor_Output_Object *)updateLearningAndAddCandidateAssertions:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error
{
    
    // Increment the run count to ensure a valid learning check
    trustFactorOutputObject.storedTrustFactorObject.runCount = [NSNumber numberWithInt:(trustFactorOutputObject.storedTrustFactorObject.runCount.intValue + 1)];
    
    
    // Determine which kind of learning mode the trustfactor has
    switch (trustFactorOutputObject.trustFactor.learnMode.integerValue) {
        case 0:
            // Learn Mode 0: Nothing is learned
        
            // Set learned to YES
            trustFactorOutputObject.storedTrustFactorObject.learned = YES;
            
            break;
        case 1:
            // Learn Mode 1: Only needs the TrustFactor to run once, generally to monitor values of something in the payload for a change
            
            // Add learned assertions to storedTrustFactorOutputObject
            [self addLearnedAssertions:trustFactorOutputObject];
            
            // Set learned to YES
            trustFactorOutputObject.storedTrustFactorObject.learned = YES;
            
            break;
        case 2:
            // Learn Mode 2: Checks the number of runs and date since first run of TrustFactor
            
            // Add learned assertions to storedTrustFactorOutputObject
            [self addLearnedAssertions:trustFactorOutputObject];
            
            // Check if the run count has been met
            if (trustFactorOutputObject.storedTrustFactorObject.runCount.integerValue >= trustFactorOutputObject.trustFactor.learnRunCount.integerValue) {
                // This TrustFactor has run enough times to be learned
                
                // Now check the time since first run  (in days)
                if ([self daysBetweenDate:trustFactorOutputObject.storedTrustFactorObject.firstRun andDate:[NSDate date]] >= trustFactorOutputObject.trustFactor.learnTime.integerValue) {
                    // Far enough apart in days to be learned, set to YES
                    trustFactorOutputObject.storedTrustFactorObject.learned = YES;
                } else {
                    // Not run far enough apart in days to be learned, set to NO
                    trustFactorOutputObject.storedTrustFactorObject.learned = NO;
                }
                
            } else {
                // Not run enough times to be learned, set to NO and never check time
                trustFactorOutputObject.storedTrustFactorObject.learned = NO;
            }
            
            break;
        case 3:
            // Learn Mode 3: Checks the number of assertions we have and the date since first run of TrustFactor
            
            // Add learned assertions to storedTrustFactorOutputObject
            [self addLearnedAssertions:trustFactorOutputObject];
            
            // Check the time since first run (in days)
            if ([self daysBetweenDate:trustFactorOutputObject.storedTrustFactorObject.firstRun andDate:[NSDate date]] >= trustFactorOutputObject.trustFactor.learnTime.integerValue) {
                // Far enough apart in days
                
                // Check if we have enough stored assertions to be learned
                if (trustFactorOutputObject.storedTrustFactorObject.assertionObjects.count >= trustFactorOutputObject.trustFactor.learnAssertionCount.integerValue) {
                    // Enough input to call it learned, set to YES
                    trustFactorOutputObject.storedTrustFactorObject.learned = YES;
                } else {
                    // Not enough assertions to be learned, set to NO
                    trustFactorOutputObject.storedTrustFactorObject.learned = NO;
                }
            } else {
                // Not run far enough apart in days to be learned, set to NO
                trustFactorOutputObject.storedTrustFactorObject.learned = NO;
            }
            break;
        default:
            return nil;
            break;
    }
    
    return trustFactorOutputObject;
    
}


+ (void)addLearnedAssertions:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject{
    
    NSNumber *origHitCount;
    NSNumber *newHitCount;
    Sentegrity_Stored_Assertion *matchingAssertionObject;
    BOOL foundMatch;
    
    //stored assertions array of Sentegrity_Stored_Assertion objects
    NSMutableArray *storedAssertions;
    storedAssertions = [trustFactorOutputObject.storedTrustFactorObject.assertionObjects mutableCopy];
    
    // If we dont have any storedAssertion then just add all the candidates right in
    if (!storedAssertions || storedAssertions == nil || storedAssertions.count < 1) {
        
        // Empty assertions, must be the first run, set it to the candidates
        [trustFactorOutputObject.storedTrustFactorObject setAssertionObjects:[trustFactorOutputObject assertionObjects]];
        
    } else { // Does contain assertions, must walk through and find anything new to add
        
        
        for(Sentegrity_Stored_Assertion *candidate in trustFactorOutputObject.assertionObjects)
        {
            foundMatch=NO;
            
            // Iterate through all stored assertions for this TF looking for a match on the candidate
            for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
                
                //search for a match in the stored objetcs
                if([[candidate assertionHash] isEqualToString:[stored assertionHash]]){
                    foundMatch=YES;
                    // Set so that it can be used later
                    matchingAssertionObject = stored;
                    break;
                }
            }
            
            if(foundMatch==YES){
                //just increment runCount
                //increment hitCount for matching stored assertion (used for decay)
                origHitCount = [matchingAssertionObject hitCount];
                newHitCount = [NSNumber numberWithInt:[origHitCount intValue]+1];
                
                // Updated the stored object that matched
                [matchingAssertionObject setHitCount:newHitCount];
                
                
            }else{
                //add it to the storedAssertions
                [storedAssertions addObject:candidate];
            }
            
        } // End next candidate assertion
        
    } // End if/else does it contain any stored assertions
}

+ (BOOL)checkTrustFactorRevision:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withStored:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject{
    // Check if the revision number is different - if so, return nil to create new
    if (trustFactorOutputObject.trustFactor.revision != storedTrustFactorObject.revision) {
        
        return NO;
    }
    
    
    return YES;
}

// Include date helper method to determine number of days between two dates
// http://stackoverflow.com/questions/4739483/number-of-days-between-two-nsdates
+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    
    // TODO: Validate the input dates - otherwise there will be issues
    // Currently, I'm not aware of any way to validate dates
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}



@end

