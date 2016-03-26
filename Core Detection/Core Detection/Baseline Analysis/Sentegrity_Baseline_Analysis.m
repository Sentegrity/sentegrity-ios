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
#import "Sentegrity_Startup_Store.h"


// Pod for hashing
#import "NSString+Hashes.h"

@implementation Sentegrity_Baseline_Analysis

//@synthesize trustFactorOutputObjectsForProtectMode = _trustFactorOutputObjectsForProtectMode, trustFactorOutputObjectsForComputation = _trustFactorOutputObjectsForComputation;

// Retrieve stored assertions
+ (NSArray *)performBaselineAnalysisUsing:(NSArray *)trustFactorOutputObjects forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {

    // Create a bool to check if the assertion store exists
    BOOL exists = NO;
    
    // Attempt to get our assertion store
    Sentegrity_Assertion_Store *assertionStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getAssertionStoreWithError:error];
    
    // Check if the assertion store exists (should, unless is the first run for this policy)
    if (!assertionStore || assertionStore == nil) {
        
        // Error out, no trustFactorOutputObject were able to be added
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get assertion store file", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No assertion file received", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the assertion file", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get assertion store file: %@", errorDetails);
        
        // Don't return anything
        return nil;

    }
    
    // Get our startup file
    NSError *startupError;
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&startupError];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        // Error out, no trustFactorOutputObject were able to be added
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get startup file: %@", errorDetails);
        
        // Don't return anything
        return nil;
        
    }
    
    // Should TF wipe due to update?
    BOOL shouldWipeOldData = NO;
    
    // Check for updated version
    if (![startup.lastOSVersion isEqualToString:[[UIDevice currentDevice] systemVersion]]) {
        
        // OS Versions DO NOT MATCH
        shouldWipeOldData = YES;
        
        // Write the new startup os version
        [startup setLastOSVersion:[[UIDevice currentDevice] systemVersion]];

    }
    
    // Create the mutable array to hold the storedTrustFactoObjects for each trustFactorOutputObject
    Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject;
    
    // Updated trustFactorOutputObject
    Sentegrity_TrustFactor_Output_Object *updatedTrustFactorOutputObject;
    
    // Run through all the trustFactorOutput objects and perform compare based on rule type
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorOutputObjects) {
        
        // Check if the TrustFactor is valid to start with
        if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
            
            // Error out, no trustFactorOutputObject were able to be added
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Add trustFactorOutputObject.", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid trustFactorOutputObject passed.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid trustFactorOutputObject.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStoredTrustFactorObjectsProvided userInfo:errorDetails];
            
            // Log Error
            NSLog(@"Failed to Add trustFactorOutputObject: %@", errorDetails);
            
            // Don't return anything
            return nil;
        }
        
        // Find the matching stored assertion object for the trustfactor
        storedTrustFactorObject = [assertionStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
        
        
        // If we could not find an existing stored assertion in the local store create it
        if (exists == NO || !storedTrustFactorObject || storedTrustFactorObject == nil) {
            
            //  Create new stored assertion in the local store with error
            storedTrustFactorObject = [assertionStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
            
            NSLog(@"Could not find storedTrustFactorObject in local store, creating new");
            
            // Check returned object
            if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
                
                // Error out, no trustFactorOutputObject were able to be added
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"No trustFactorOutputObject were able to be added.", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to create a new storedTrustFactorObject.", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid trustFactorOutputObject.", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToCreateNewStoredAssertion userInfo:errorDetails];
                
                // Log Error
                NSLog(@"No trustFactorOutputObject were able to be added: %@", errorDetails);
                
                // Don't return anything
                return nil;
            }
            
            // Add the created storedTrustFactorObject to the current trustFactorOutputObject
            trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
            
            // Perform baseline analysis against storedTrustFactorObject
            updatedTrustFactorOutputObject = [self performBaselineAnalysisUsing:trustFactorOutputObject withError:error];
            
            // Check if we got a result
            if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                
                // Error out, something went wrong in compare
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Compare.", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to perform baseline analysis for trustFactorOutputObject.", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try updating trustFactorOutputObjects.", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                
                // Log Error
                NSLog(@"Failed to Compare: %@", errorDetails);
                
                // Don't return anything
                return nil;
            }
            
            // Add the new storedTrustFactorObject to the runtime local store, to be written later
            if (![assertionStore addSingleObjectToStore:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                
                // Error out, no storedTrustFactorObjects were able to be added
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Add storedTrustFactorObjects.", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to add storedTrustFactorObjects to the runtime local store.", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing a valid object to store.", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                
                // Log Error
                NSLog(@"Failed to Add storedTrustFactorObjects: %@", errorDetails);
                
                // Don't return anything
                return nil;
            }
            
        } else {
            
            // Found an existing stored assertion, check revisions
            
            // If revisions do not match create new - or if device versions don't match and the trustfactor should wipe on new versions, create new
            if (![self checkTrustFactorRevision:trustFactorOutputObject withStored:storedTrustFactorObject] || (shouldWipeOldData && [trustFactorOutputObject.trustFactor.wipeOnUpdate boolValue])) {
                
                // Create a new object in the local store
                storedTrustFactorObject = [assertionStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                
                // Update the trustFactorOutputObject with newly created storedTrustFactorObject
                trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
                
                // Perform baseline analysis against storedTrustFactorObject
                updatedTrustFactorOutputObject = [self performBaselineAnalysisUsing:trustFactorOutputObject withError:error];
                
                // Check if we got a result
                if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                    
                    // Error out, something went wrong in compare
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Compare.", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to perform baseline analysis for trustFactorOutputObject.", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try updating trustFactorOutputObjects.", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                    
                    // Log Error
                    NSLog(@"Failed to Perform: %@", errorDetails);
                    
                    // Don't return anything
                    return nil;
                }
                
                // Replace existing in the local store
                if (![assertionStore replaceSingleObjectInStore:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                    
                    // Error out, no storedTrustFactorOutputObjects were able to be added
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"No trustFactorOutputObject were able to be added.", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to replace stored assertion.", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid trustFactorOutputObject.", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                    
                    // Log Error
                    NSLog(@"No trustFactorOutputObject were able to be added: %@", errorDetails);
            
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
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Compare.", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to perform baseline analysis for trustFactorOutputObject.", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try updating trustFactorOutputObjects.", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                    
                    // Log Error
                    NSLog(@"Failed to Perform: %@", errorDetails);
                    
                    // Don't return anything
                    return nil;
                }
                
                // Since we modified, replace existing in the local store
                if (![assertionStore replaceSingleObjectInStore:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                    
                    // Error out, no storedTrustFactorOutputObjects were able to be added
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"No trustFactorOutputObject were able to be added.", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to replace stored assertion.", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid trustFactorOutputObject.", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                    
                    // Log Error
                    NSLog(@"No trustFactorOutputObject were able to be added: %@", errorDetails);
                    
                    // Don't return anything
                    return nil;
                }
            }
        }
    }
    
    // Save stores due to learning mode and decay updates
    exists = YES;
    
    // Update stores
    [[Sentegrity_TrustFactor_Storage sharedStorage] setAssertionStoreWithError:error];
    
    
    // Return the TrustFactor objects
    return trustFactorOutputObjects;
}

// Perform baseline analysis
+ (Sentegrity_TrustFactor_Output_Object *)performBaselineAnalysisUsing:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    // Create an object for updated objects
    Sentegrity_TrustFactor_Output_Object *updatedTrustFactorOutputObject;
    
    // An array for the objects added to WhiteList
    trustFactorOutputObject.candidateAssertionObjectsForWhitelisting = [[NSMutableArray alloc] init];
    
    // First check if we recieved the trustFactorOutputObject
    if (!trustFactorOutputObject) {
        
        // Failed, no trustFactorOutputObject found
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed, no trustFactorOutputObjects found.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No trustFactorOutputObject received or candidate assertions for compare.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a trustFactorOutputObject.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed, no trustFactorOutputObjects found: %@", errorDetails);
    
        // Don't return anything
        return nil;
    }
    
    // Check if decay is enabled for this TrustFactor
    if(trustFactorOutputObject.trustFactor.decayMode.intValue == 1) {
            
        // Metric based decay where hitcounts are divided by time since last the stored assertion was hit
            
        trustFactorOutputObject = [self performMetricBasedDecay:trustFactorOutputObject withError:error];

    }
    
    // Check learning
    if(trustFactorOutputObject.storedTrustFactorObject.learned==NO){
        updatedTrustFactorOutputObject = [self updateLearningAndAddCandidateAssertions:trustFactorOutputObject withError:error];
    }
    
    // Dont do baseline if we have no output and the rule did not error OR it has a DNE of no data
    if((trustFactorOutputObject.candidateAssertionObjects.count < 1 && trustFactorOutputObject.statusCode == DNEStatus_ok) || trustFactorOutputObject.statusCode == DNEStatus_nodata){
        trustFactorOutputObject.forComputation=NO;
        updatedTrustFactorOutputObject = trustFactorOutputObject;
    }
    else{
        
        // Everything else should go to computation
        trustFactorOutputObject.forComputation=YES;
        
        // If we have output and the TF is learned then do baseline analysis
        // We check learned again here in the event that hte TF was just learned during the last call to "updateLearningAndAddCandidateAssertions"
        if(trustFactorOutputObject.storedTrustFactorObject.learned == YES) {
            updatedTrustFactorOutputObject = [self checkBaselineForMatch:trustFactorOutputObject withError:error];
            
            
        }

    }
    
    
    // Check if trustFactorOutputObject was found
    if (!updatedTrustFactorOutputObject) {
    
        // Failed, no trustFactorOutputObject found
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed, no trustFactorOutputObjects found.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during learning check.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing or updating trustFactorOutputObjects.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAErrorDuringLearningCheck userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed, no trustFactorOutputObjects found: %@", errorDetails);
    
        // Don't return anything
        return nil;
    }
    
    // Return object
    return updatedTrustFactorOutputObject;
}

// Perform the actual baseline analysis with no match
+ (Sentegrity_TrustFactor_Output_Object *)checkBaselineForMatch:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    NSNumber *origHitCount;
    NSNumber *newHitCount;
    NSMutableArray *candidateAssertionToWhitelist;
    NSMutableArray *storedAssertionObjectsMatched;
    BOOL currentCandidateMatch=NO;

    // List of individual candidates that should be whitelisted in the TF if/when it goes into protect mode
    candidateAssertionToWhitelist = [[NSMutableArray alloc]init];
    
    // List of all match assertion objects
    storedAssertionObjectsMatched = [[NSMutableArray alloc]init];
    
    
    
    // Iterate through all candidates returned by TrustFactor, remember many rules return multiple candidates
    for(Sentegrity_Stored_Assertion *candidate in trustFactorOutputObject.candidateAssertionObjects) {
        
        // Set foundMatch variable
        currentCandidateMatch = NO;
        
        // Iterate through all stored assertions for this TrustFactor looking for a match to the current candidate
        for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects) {
            
            // Search for a match in the stored objetcs
            if([[candidate assertionHash] isEqualToString:[stored assertionHash]]) {

                // increment matching stored assertions hitcount & check threshold
                origHitCount = [stored hitCount];
                newHitCount = [NSNumber numberWithInt:[origHitCount intValue]+1];
                [stored setHitCount:newHitCount];
                [stored setLastTime:[NSNumber numberWithInteger:[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch]]];
                
                // Set matched
                currentCandidateMatch = YES;
                trustFactorOutputObject.matchFound = YES;
                
                // store assertion objects matched
                [storedAssertionObjectsMatched addObject:stored];
            
                break;
            }
        } // Completed iterating through all stored assertions for current candidate
        
        // We DID NOT find a match for the candidate
        if(currentCandidateMatch == NO) {
            
            // Add candidate assertion to whitelist for TrustFactor object if its whitelistable
            if(trustFactorOutputObject.trustFactor.whitelistable.intValue == 1) {
                
                //Add non matching assertion to whitelist for TF
                [candidateAssertionToWhitelist addObject:candidate];
            }
        // End notfound/found if/else
        }
    // End next candidate assertion
    }

    
    // Set the assertions objects not match to the mutable array using during runtime
    [trustFactorOutputObject setCandidateAssertionObjectsForWhitelisting:candidateAssertionToWhitelist];
    
    // Set the assertions objects match to the mutable array using during runtime
    [trustFactorOutputObject setStoradeAssertionObjectsMatched:storedAssertionObjectsMatched];
    
    // Return the object
    return trustFactorOutputObject;
}

// Metric based decay function
+ (Sentegrity_TrustFactor_Output_Object *)performMetricBasedDecay:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    
    double secondsInADay = 86400.0;
    double daysSinceCreation=0.0;
    double hitsPerDay=0.0;
    
    // Array to hold assertions to retain
    NSMutableArray *assertionObjectsToKeep = [[NSMutableArray alloc]init];
    
    // Iterate through stored assertions for each trustFactorOutputObject
    for(Sentegrity_Stored_Assertion *storedAssertion in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
        
        // Days since the assertion was created
        daysSinceCreation = ((double)[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch] - [storedAssertion.created doubleValue]) / secondsInADay;

        // Check when last time it was created
        if(daysSinceCreation < 1){
            
            // Set creation date to 1 if less than 1
            daysSinceCreation = 1;
        }
        
        // Calculate our decay metric
        hitsPerDay = [storedAssertion.hitCount doubleValue] / (daysSinceCreation);
        
        // Set the metric for storage
        [storedAssertion setDecayMetric:hitsPerDay];
        
        // If the stored assertions (days / hits) metric exceeds the policy keep it
        if([storedAssertion decayMetric] > trustFactorOutputObject.trustFactor.decayMetric.floatValue) {
                
            [assertionObjectsToKeep addObject:storedAssertion];
        }
    }
    
        // Sort what we're keeping by decay metric, this should help performance, highest at top (in theory, the most frequently used)
        // Highest at top prevents from having to search long for a common match
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decayMetric"
                                                     ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSArray *sortedArray;
        
        // Sort the array
        sortedArray = [assertionObjectsToKeep sortedArrayUsingDescriptors:sortDescriptors];
        
        // Set the sorted version of what we're keeping
        trustFactorOutputObject.storedTrustFactorObject.assertionObjects = sortedArray;
    
    // Return TrustFactor object
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
            
        // Learn Mode 3: Checks the number of assertions we have and the date since first run of TrustFactor (not currently used by anything)
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
        [trustFactorOutputObject.storedTrustFactorObject setAssertionObjects:[trustFactorOutputObject candidateAssertionObjects]];
    
    // Does contain assertions, must walk through and find anything new to add
    } else {
        
        // Go through each candidate in assertion objects
        for(Sentegrity_Stored_Assertion *candidate in trustFactorOutputObject.candidateAssertionObjects) {
            
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

