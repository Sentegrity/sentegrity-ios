//
//  Sentegrity_Baseline_Analysis.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Import necessary header files
#import <Foundation/Foundation.h>
#import "Sentegrity_Baseline_Analysis.h"
#import "Sentegrity_TrustFactor_Output_Object.h"
#import "Sentegrity_Assertion_Store.h"
#import "Sentegrity_Assertion_Store+Helper.h"
#import "Sentegrity_Policy.h"
#import "Sentegrity_TrustFactor_Storage.h"
#import "Sentegrity_TrustFactor_Datasets.h"


// Pod for hashing
#import "NSString+Hashes.h"

@implementation Sentegrity_Baseline_Analysis

//@synthesize trustFactorOutputObjectsForProtectMode = _trustFactorOutputObjectsForProtectMode, trustFactorOutputObjectsForComputation = _trustFactorOutputObjectsForComputation;

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
    
    // Updated trustFactorOutputObject
    Sentegrity_TrustFactor_Output_Object *updatedTrustFactorOutputObject;
    
    // Run through all the trustFactorOutput objects and determine if they're local or global TrustFactors and perform compare
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorOutputObjects) {
        
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
        if(trustFactorOutputObject.statusCode != DNEStatus_ok && trustFactorOutputObject.statusCode != DNEStatus_nodata) {
            continue;
        }
        
        
        // Find the matching stored assertion object for the trustfactor in the local store
        storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
        
        
        // If we could not find an existing stored assertion in the local store create it
        if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists==NO) {
            
            //  Create new stored assertion in the local store with error
            storedTrustFactorObject = [localStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
            
            NSLog(@"Could not find storedTrustFactorObject in local store, creating new");
            
            // Check returned object
            if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
                
                // Error out, no trustFactorOutputObject were able to be added
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to create new storedTrustFactorObject for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToCreateNewStoredAssertion userInfo:errorDetails];
                
                // Don't return anything
                return nil;
            }
            
            // Add the created storedTrustFactorObject to the current trustFactorOutputObject
            trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
            
            // Perform baseline analysis against storedTrustFactorObject
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
            
            // Add the new storedTrustFactorObject to the runtime local store, to be written later
            if (![localStore addSingleObjectToStore:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                
                // Error out, no storedTrustFactorObjects were able to be added
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"No storedTrustFactorObjects addeded to local store" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                
                // Don't return anything
                return nil;
            }
            
        } else {
            // Found an existing stored assertion, check revisions
            
            // If revisions do not match create new
            if (![self checkTrustFactorRevision:trustFactorOutputObject withStored:storedTrustFactorObject]) {
                
                // Create a new object in the local store
                storedTrustFactorObject = [localStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                
                // Update the trustFactorOutputObject with newly created storedTrustFactorObject
                trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
                
                // Perform baseline analysis against storedTrustFactorObject
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
                
                // Replace existing in the local store
                if (![localStore replaceSingleObjectInStore:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                    
                    // Error out, no storedTrustFactorOutputObjects were able to be added
                    NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                    [errorDetails setValue:@"Unable to replace stored assertion" forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                    
                    // Don't return anything
                    return nil;
                }
                
                
            } else {
                // Revisions match, no replacement required
                
                // Update the trustFactorOutputObject with newly created storedTrustFactorObject
                trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
                
                // Perform baseline analysis against storedTrustFactorObject
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
                
                // Since we modified, replace existing in the local store
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
    }
    
    // Save stores due to learning mode updates
    exists = YES;
    
    // Update stores
    Sentegrity_Assertion_Store *localStoreOutput = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore withAppID:policy.appID withError:error];
    
    // If local store doesn't get written
    if (!localStoreOutput || localStoreOutput == nil) {
        
        // Create error explaining what went wrong
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error writing assertion stores after baseline analysis" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWriteStore userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Return the TrustFactor objects
    return trustFactorOutputObjects;
}

// Perform baseline analysis
+ (Sentegrity_TrustFactor_Output_Object *)performBaselineAnalysisUsing:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    // Create an object for updated objects
    Sentegrity_TrustFactor_Output_Object *updatedTrustFactorOutputObject;
    
    // An array for the objects added to WhiteList
    trustFactorOutputObject.assertionObjectsToWhitelist = [[NSMutableArray alloc] init];
    
    // First check if we recieved the trustFactorOutputObject
    if (!trustFactorOutputObject) {
        // Failed, no trustFactorOutputObject found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No trustFactorOutputObject received or candidate assertions for compare" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Check if decay is enabled for this TrustFactor
    switch (trustFactorOutputObject.trustFactor.decayMode.intValue) {
            
        case 0:
            
            // Do not decay
            break;
            
        case 1:
            
            // Only run decay if history exceeds
            if(trustFactorOutputObject.storedTrustFactorObject.assertionObjects.count > [trustFactorOutputObject.trustFactor.decayMetric integerValue]) {
                
                trustFactorOutputObject = [self performCountBasedDecay:trustFactorOutputObject withError:error];
                
            }
            break;
            
        case 2:
            
            // Only update decay if there is at leaste two stored assertion to be check, otherwise its a waste of time
            if(trustFactorOutputObject.storedTrustFactorObject.assertionObjects.count > 1){
                
                trustFactorOutputObject = [self performMetricBasedDecay:trustFactorOutputObject withError:error];
                
            }
            
            break;
            
        // Default case
        default:
            break;
    }
    
    // Create and update assertions depending on type of rule
    switch (trustFactorOutputObject.trustFactor.ruleType.intValue) {
        
        // Rule type 1 leverages a default assertion to look for blacklisted artifacts on the system or enforce user policies
        case 1:
            
            // Must be the first time this has run
            if(trustFactorOutputObject.storedTrustFactorObject.learned == NO) {
                
                // Set stored assertion to the default for proper comparison
                trustFactorOutputObject.storedTrustFactorObject.assertionObjects = @[[trustFactorOutputObject defaultAssertionObject]];
                
                // Updated assertion object
                updatedTrustFactorOutputObject = [self updateLearningAndAddCandidateAssertions:trustFactorOutputObject withError:error];
            }
            
            // Run baseline analysis
            updatedTrustFactorOutputObject = [self checkBaselineForNoMatch:trustFactorOutputObject withError:error];
            
            break;
            
        // Rule Type 2 employs learning for anomaly detection, no default assertion is used, these rules don't take effect right away
        case 2:
            
            // If TrustFactor is learned run baseline analysis
            if(trustFactorOutputObject.storedTrustFactorObject.learned == YES) {
                updatedTrustFactorOutputObject = [self checkBaselineForNoMatch:trustFactorOutputObject withError:error];
            } else {
                
                // Not yet learned, just update learning and don't baseline
                updatedTrustFactorOutputObject = [self updateLearningAndAddCandidateAssertions:trustFactorOutputObject withError:error];
            }
            
            break;
            
        // Rule Type 3 uses no default assertion and no learning mode, triggers right away (e.g., builds a profile to identify known-good good user conditions one login at a time, good conditions are determined by login therefore no learning occurs, everything triggers on first run)
        case 3:
            
            // Must be the first time this has run
            if(trustFactorOutputObject.storedTrustFactorObject.learned == NO) {
                // Do any first time stuff here
                
                // Set to learned
                trustFactorOutputObject.storedTrustFactorObject.learned = YES;
                
            }
            
            // Update learning
            updatedTrustFactorOutputObject = [self checkBaselineForNoMatch:trustFactorOutputObject withError:error];
            
            break;
            
        // Rule Type 4 is designed for authenticator TFs (known wifi, known bluetooth, etc) the same as ruletype 3 but flips the learning, it triggers when there is match in order to apply a negative penalty, unlike all other rule types that trigger on no-match and apply a positive penalty, only a few USER rules u
        case 4:
            
            // Must be the first time this has run
            if(trustFactorOutputObject.storedTrustFactorObject.learned == NO) {
                // Do any first time stuff here
                
                // Set to learned
                trustFactorOutputObject.storedTrustFactorObject.learned = YES;
            }
            
            // Update learning
            updatedTrustFactorOutputObject = [self checkBaselineForAMatch:trustFactorOutputObject withError:error];
            
            
            break;
            
        // Default case
        default:
            break;
    }
    
    // Check if trustFactorOutputObject was found
    if (!updatedTrustFactorOutputObject) {
        
        // Failed, no trustFactorOutputObject found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error during TrustFactor learning check" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAErrorDuringLearningCheck userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Return object
    return updatedTrustFactorOutputObject;
}

// Perform the actual baseline analysis with no match
+ (Sentegrity_TrustFactor_Output_Object *)checkBaselineForNoMatch:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    // Now we do the real  baseline analysis
    NSNumber *origHitCount;
    NSNumber *newHitCount;
    NSMutableArray *assertionObjectsToWhitelist;
    BOOL foundMatch;

    // Trigger on NO MATCH in the baseline
    // e.g., knownBadProcesses, shortUptime, newRootProcess, etc
    
    // List of individual candidates that should be whitelisted in the TF if/when it goes into protect mode
    assertionObjectsToWhitelist = [[NSMutableArray alloc]init];
    
    // When candidate is in assertion objects
    for(Sentegrity_Stored_Assertion *candidate in trustFactorOutputObject.assertionObjects) {
        
        // Set foundMatch variable
        foundMatch = NO;
        
        // Iterate through all stored assertions for this TrustFactor looking for a match on the candidate
        for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects) {
            
            // Search for a match in the stored objetcs
            if([[candidate assertionHash] isEqualToString:[stored assertionHash]]) {
                
                // Change foundMatch variable
                foundMatch = YES;
                
                // Set so that it can be used later
                
                //we DID find a match, RULE NOT YET TRIGGERED  (increment matching stored assertions hitcount & check threshold)
                origHitCount = [stored hitCount];
                newHitCount = [NSNumber numberWithInt:[origHitCount intValue]+1];
                [stored setHitCount:newHitCount];
                [stored setLastTime:[NSNumber numberWithInteger:[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch]]];
                
                // If this rules has frequency requirments then enforce them
                if(trustFactorOutputObject.trustFactor.threshold.intValue != 0) {
                    
                    // Still strigger the rule if we have not meet the hitcount threshold, regardless of if its in the store or not (generally only user anomaly rules)
                    if(newHitCount < trustFactorOutputObject.trustFactor.threshold) {
                        
                        // Only add as triggered if meet
                        trustFactorOutputObject.triggered=YES;
                    }
                }
                break;
            }
        }
        
        // We DID NOT find a match for the candidate in the store = RULE TRIGGERED (a bad thing, since it should match the kDefaultTrustFactorOutput assertion at the very least)
        if(foundMatch == NO) {
            
            // Trigger rule
            trustFactorOutputObject.triggered=YES;
            
            // Update list, but we still need to look at all assertions before exiting loop
            if(trustFactorOutputObject.trustFactor.whitelistable.intValue == 1) {
                
                //Add non matching assertion to whitelist for TF
                [assertionObjectsToWhitelist addObject:candidate];
                trustFactorOutputObject.whitelist=YES;
            }
        // End notfound/found if/else
        }
    // End next candidate assertion
    }
    
    // Set the whitelist to the mutable array using during runtime
    [trustFactorOutputObject setAssertionObjectsToWhitelist:assertionObjectsToWhitelist];
    
    // Return the object
    return trustFactorOutputObject;
}

// Perform the actual basline analysis with a match
+ (Sentegrity_TrustFactor_Output_Object *)checkBaselineForAMatch:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    NSNumber *origHitCount;
    NSNumber *newHitCount;
    NSMutableArray *assertionObjectsToWhitelist;
    BOOL foundMatch;
    
    // tTrigger on MATCH to ensure negative penalty is applied, these are authenticator type rules (currently only: knownBLEDevice, KnowWifiBSSID)
    
    // List of individual candidates that should be whitelisted in the TF if/when it goes into protect mode
    assertionObjectsToWhitelist = [[NSMutableArray alloc]init];
    
    // Go through the candidates in assertion objects
    for(Sentegrity_Stored_Assertion *candidate in trustFactorOutputObject.assertionObjects)
    {
        
        // Set foundMatch variable
        foundMatch = NO;
        
        // Iterate through all stored assertions for this TF looking for a match on the candidate
        for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
            
            // Search for a match in the stored objetcs
            if([[candidate assertionHash] isEqualToString:[stored assertionHash]]) {
                
                // Change foundMatch variable
                foundMatch = YES;
                
                // We DID find a match, rule should trigger as its inverse (applies a negative value that boosts the score positively by negating penalties)
                trustFactorOutputObject.triggered=YES;
                
                // Increment hitCount for matching stored assertion (used for decay)
                origHitCount = [stored hitCount];
                newHitCount = [NSNumber numberWithInt:[origHitCount intValue]+1];
                [stored setHitCount:newHitCount];
                [stored setLastTime:[NSNumber numberWithInteger:[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch]]];
                
                // If this rules has frequency requirments then enforce them
                if(trustFactorOutputObject.trustFactor.threshold.intValue != 0) {
                    
                    // Don't trigger the rule if we have not meet the hitcount threshold, regardless of if its in the store or not (generally only user anomaly rules)
                    if(newHitCount < trustFactorOutputObject.trustFactor.threshold) {
                        
                        // Only add as triggered if meet
                        trustFactorOutputObject.triggered = NO;
                    }
                }
                break;
            }
        }
        
        // We DID NOT find a match for the candidate in the store don't do anything but add to whitelist since this is inverse (applies a negative value that boosts the score positively by negating penalties)
        if(foundMatch == NO) {
            
            // Perform if the TrustFactor candidate is able to be white listed
            if(trustFactorOutputObject.trustFactor.whitelistable.intValue == 1){
                
                // Add the candidate to WhiteList
                [assertionObjectsToWhitelist addObject:candidate];
                trustFactorOutputObject.whitelist=YES;
            }
        }
    // End next candidate assertion
    }
    
    // Set the whitelist to the mutable array using during runtime
    [trustFactorOutputObject setAssertionObjectsToWhitelist:assertionObjectsToWhitelist];
    
    // Return object
    return trustFactorOutputObject;
}

// Metric based decay function
+ (Sentegrity_TrustFactor_Output_Object *)performMetricBasedDecay:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    double secondsInADay = 86400.0;
    
    // Accelerate for debug (10 min)
    //double secondsInADay = 600;
    
    double daysSinceCreation=0.0;
    double hitsPerDay=0.0;
 
    // Use the metric decay method (e.g., keep all assertions that meet the metric, removing only those that don't)
    // This is ideal for TFs device orientation or access time
    
    // Array to hold assertions to retain
    NSMutableArray *assertionObjectsToKeep = [[NSMutableArray alloc]init];
    
    // Iterate through stored assertions for each trustFactorOutputObject
    for(Sentegrity_Stored_Assertion *storedAssertion in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
        
        // Hours since the assertion was created
        daysSinceCreation = ((double)[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch] - [storedAssertion.created doubleValue]) / secondsInADay;
        //minutesSinceCreation = ((float)[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch] - [storedAssertion.created floatValue]) / 60;

        // Check when last time it was created
        if(daysSinceCreation < 1){
            
            // Set creation date to 1 if less than 1
            daysSinceCreation = 1;
        }
        
        // Calculate our core metric for sorting
        hitsPerDay = [storedAssertion.hitCount doubleValue] / (daysSinceCreation);
        
        // Set the metric for sorting
        [storedAssertion setDecayMetric:hitsPerDay];
        
        if([storedAssertion decayMetric] > trustFactorOutputObject.trustFactor.decayMetric.floatValue) {
                
            [assertionObjectsToKeep addObject:storedAssertion];
        }
    }
    
    // Keep at leaste the top metric if none where found above the set limit
    if (assertionObjectsToKeep.count == 0){
        
        // Sort the original array by decay
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decayMetric"
                                                     ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSArray *sortedArray;
        
        //Sort the array
        sortedArray = [trustFactorOutputObject.storedTrustFactorObject.assertionObjects sortedArrayUsingDescriptors:sortDescriptors];
        
        // add the first element (top) to the keep array
        [assertionObjectsToKeep addObject:[sortedArray objectAtIndex:1]];
        
        trustFactorOutputObject.storedTrustFactorObject.assertionObjects = assertionObjectsToKeep;
        
        
    } else {
        
        // Sort what we're keeping by decay metric, highest at top (in theory, the most frequently used)
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decayMetric"
                                                     ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSArray *sortedArray;
        
        // Sort the array
        sortedArray = [assertionObjectsToKeep sortedArrayUsingDescriptors:sortDescriptors];
        
        // Set the sorted version of what we're keeping
        trustFactorOutputObject.storedTrustFactorObject.assertionObjects = sortedArray;
        
    }
    
    // Return TrustFactor object
    return trustFactorOutputObject;
}

// Count based decay function
+ (Sentegrity_TrustFactor_Output_Object *)performCountBasedDecay:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    //double secondsInADay = 86400.0;
    
    //Accelerate for debug (10 min)
    double secondsInADay = 600;
    double daysSinceCreation=0.0;
    double hitsPerDay=0.0;
    
    // Iterate through stored assertions for each trustFactorOutputObject and update metric
    for(Sentegrity_Stored_Assertion *storedAssertion in trustFactorOutputObject.storedTrustFactorObject.assertionObjects) {
        
        // Hours since the assertion was created
        daysSinceCreation = ((double)[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch] - [storedAssertion.created doubleValue]) / secondsInADay;
        //minutesSinceCreation = ((float)[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch] - [storedAssertion.created floatValue]) / 60;
        
        
        // Check when last time it was created
        if(daysSinceCreation < 1){
            
            // Set creation date to 1 if less than 1
            daysSinceCreation = 1;
        }
        
        // Calculate our core metric for sorting
        hitsPerDay = [storedAssertion.hitCount doubleValue] / (daysSinceCreation);
        
        // Set the metric for sorting
        [storedAssertion setDecayMetric:hitsPerDay];
    }
    
    // Sort all assertions by decay metric, highest at top (in theory, the most frequently used)
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decayMetric"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray;
    
    //Sort the array
    sortedArray = [trustFactorOutputObject.storedTrustFactorObject.assertionObjects sortedArrayUsingDescriptors:sortDescriptors];
    
    // Trim to the set amount of keep (decayMetric > 0 when decayMode = 1)
    trustFactorOutputObject.storedTrustFactorObject.assertionObjects = [sortedArray subarrayWithRange:NSMakeRange(0,trustFactorOutputObject.trustFactor.decayMetric.intValue)];
    
    return trustFactorOutputObject;
}

// Update learning and candidate assertions function
+ (Sentegrity_TrustFactor_Output_Object *)updateLearningAndAddCandidateAssertions:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    // Increment the run count to ensure a valid learning check
    trustFactorOutputObject.storedTrustFactorObject.runCount = [NSNumber numberWithInt:(trustFactorOutputObject.storedTrustFactorObject.runCount.intValue + 1)];
    
    // Determine which kind of learning mode the trustfactor has (i.e., in what conditions do we add the candidates to the stored assertion list)
    switch (trustFactorOutputObject.trustFactor.learnMode.integerValue) {
            
        // No learning performed
        case 0:
            
            // Set learned to YES
            trustFactorOutputObject.storedTrustFactorObject.learned = YES;
            
            break;

        // Learn Mode 1: Only needs the TrustFactor to run once, generally to monitor values of something in the payload for a change or use baseline assertion
        case 1:
            
            // Add learned assertions to storedTrustFactorOutputObject
            [self addLearnedAssertions:trustFactorOutputObject];
            
            // Set learned to YES
            trustFactorOutputObject.storedTrustFactorObject.learned = YES;
            
            break;
            
        // Learn Mode 2: Checks the number of runs and date since first run of TrustFactor
        case 2:
            
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
            
        // Learn Mode 3: Checks the number of assertions we have and the date since first run of TrustFactor
        case 3:
            
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
            
        // Default case
        default:
            return nil;
            break;
    }
    
    // Return TrustFactor object
    return trustFactorOutputObject;
}

// Add the assertions we learned
+ (void)addLearnedAssertions:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject{
    
    NSNumber *origHitCount;
    NSNumber *newHitCount;
    Sentegrity_Stored_Assertion *matchingAssertionObject;
    BOOL foundMatch;
    
    // Stored assertions array of Sentegrity_Stored_Assertion objects
    NSMutableArray *storedAssertions;
    storedAssertions = [trustFactorOutputObject.storedTrustFactorObject.assertionObjects mutableCopy];
    
    // If we dont have any storedAssertion then just add all the candidates right in
    if (!storedAssertions || storedAssertions == nil || storedAssertions.count < 1) {
        
        // Empty assertions, must be the first run, set it to the candidates
        [trustFactorOutputObject.storedTrustFactorObject setAssertionObjects:[trustFactorOutputObject assertionObjects]];
    
    // Does contain assertions, must walk through and find anything new to add
    } else {
        
        // Go through each candidate in assertion objects
        for(Sentegrity_Stored_Assertion *candidate in trustFactorOutputObject.assertionObjects) {
            
            // Set foundMatch variable
            foundMatch = NO;
            
            // Iterate through all stored assertions for this TF looking for a match on the candidate
            for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
                
                // Search for a match in the stored objetcs
                if([[candidate assertionHash] isEqualToString:[stored assertionHash]]){
                    foundMatch=YES;
                    // Set so that it can be used later
                    matchingAssertionObject = stored;
                    break;
                }
            }
            
            // When we find a match
            if(foundMatch == YES) {
                
                //just increment runCount
                //increment hitCount for matching stored assertion (used for decay)
                origHitCount = [matchingAssertionObject hitCount];
                newHitCount = [NSNumber numberWithInt:[origHitCount intValue]+1];
                
                // Updated the stored object that matched
                [matchingAssertionObject setHitCount:newHitCount];
            } else {
                
                //add it to the storedAssertions
                [storedAssertions addObject:candidate];
            }
        // End next candidate assertion
        }
    // End if/else does it contain any stored assertions
    }
}

// Check revisions function
+ (BOOL)checkTrustFactorRevision:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withStored:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject {
    
    // Check if the revision number is different - if so, return nil to create new
    if (trustFactorOutputObject.trustFactor.revision != storedTrustFactorObject.revision) {
        
        // Return no
        return NO;
    }
    
    // Return Yes
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

