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



@implementation Sentegrity_Baseline_Analysis

//@synthesize trustFactorOutputObjectsForProtectMode = _trustFactorOutputObjectsForProtectMode, trustFactorOutputObjectsForComputation = _trustFactorOutputObjectsForComputation;


// Retrieve stored assertions
+ (instancetype)performBaselineAnalysisUsing:(NSArray *)trustFactorOutputObjects forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    
    //Create baseline object to return
    Sentegrity_Baseline_Analysis *baselineAnalysisResults = [[Sentegrity_Baseline_Analysis alloc] init];
    baselineAnalysisResults.trustFactorOutputObjectsForProtectMode = [[NSMutableArray alloc]init];
    baselineAnalysisResults.trustFactorOutputObjectsForComputation = [[NSMutableArray alloc]init];
    
    
    // Attempt to get our local assertion store, if does not exist it gets created
    Sentegrity_Assertion_Store *localStore = [self getLocalAssertionStoreForPolicy:policy withError:error];
    
    // Create a bool to check if global store exists
    BOOL exists = NO;
    
    // Get the global store singleton
    Sentegrity_Assertion_Store *globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getGlobalStore:&exists withError:error];
    
    // Check if the global store exists (should, unless is the first ever run)
    if (!globalStore || globalStore == nil || !exists) {
        // Store doesn't exist yet, create the store
        
        // Create the store for the first time
        globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] setGlobalStore:nil overwrite:NO withError:error];
        
        // Check if we've failed again
        if (!globalStore || globalStore == nil) {
            return nil;
        }
    }
    
    // Create the mutable array to hold the storedTrustFactoObjects for each trustFactorOutputObject
    Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject;
    
    //Updated trustFactorOutputObject
    Sentegrity_TrustFactor_Output_Object *updatedTrustFactorOutputObject;
    
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
        
        
        //If the TrustFactor not OK add to list and skip
        if(trustFactorOutputObject.statusCode != DNEStatus_ok)
        {
            //add TF to the list as its triggered
            [baselineAnalysisResults.trustFactorOutputObjectsForComputation addObject:trustFactorOutputObject];
        }
        else
        {
            //TrustFactor belongs to the local store (user store)
        
            if ([trustFactorOutputObject.trustFactor.local boolValue]) {
            
                // Find the matching stored assertion object for the trustfactor in the local store
                storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
            
            
                // If could not find in the local store create it
                if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists==NO) {
                
                    storedTrustFactorObject = [localStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                
                    // Check if created
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
                    updatedTrustFactorOutputObject =[self performBaselineAnalysisUsing:trustFactorOutputObject withBaselineAnalysisResults:baselineAnalysisResults withError:error];
                
                    // Check if created
                    if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                        // Error out, something went wrong in compare
                        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                        [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                    
                        // Don't return anything
                        return nil;
                    }
                
                
                    //add the new storedTrustFactorObject to the local store
                    if (![localStore addStoredTrustFactorObject:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
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
                        updatedTrustFactorOutputObject =[self performBaselineAnalysisUsing:trustFactorOutputObject withBaselineAnalysisResults:baselineAnalysisResults withError:error];
                    
                        // Check if created
                        if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                            // Error out, something went wrong in compare
                            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                            [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                        
                            // Don't return anything
                            return nil;
                        }
                    
                        //replace existing in the local store
                        if (![localStore setStoredTrustFactorObject:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                            // Error out, no storedTrustFactorOutputObjects were able to be added
                            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                            [errorDetails setValue:@"Unable to replace stored assertion" forKey:NSLocalizedDescriptionKey];
                            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                        
                            // Don't return anything
                            return nil;
                        }
                    
                    
                    }
                    else{ //revisions match, no creation required
                    
                        //update the trustFactorOutputObject with newly created storedTrustFactorObject
                        trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
                    
                        //perform baseline analysis against storedTrustFactorObject
                        updatedTrustFactorOutputObject = [self performBaselineAnalysisUsing:trustFactorOutputObject withBaselineAnalysisResults:baselineAnalysisResults withError:error];
                    
                        // Check if created
                        if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                            // Error out, something went wrong in compare
                            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                            [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                        
                            // Don't return anything
                            return nil;
                        }
                    
                        //since we modified, replace existing in the local store
                        if (![localStore setStoredTrustFactorObject:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                            // Error out, no storedTrustFactorOutputObjects were able to be added
                            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                            [errorDetails setValue:@"Unable to replace stored assertion" forKey:NSLocalizedDescriptionKey];
                            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                        
                            // Don't return anything
                            return nil;
                        }
                    
                    
                    }
                
                
                }
            
            
                //TrustFactor belongs to the global store
            } else {
            
                // Find the matching stored assertion object for the trustfactor in the global store
                storedTrustFactorObject = [globalStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
            
            
                // If could not find in the global store create it
                if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
                
                    storedTrustFactorObject = [globalStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                
                    // Check if created
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
                    updatedTrustFactorOutputObject =[self performBaselineAnalysisUsing:trustFactorOutputObject withBaselineAnalysisResults:baselineAnalysisResults withError:error];
                
                    // Check if created
                    if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                        // Error out, something went wrong in compare
                        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                        [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                    
                        // Don't return anything
                        return nil;
                    }
                
                
                    //add the new storedTrustFactorObject to the global store
                    if (![globalStore addStoredTrustFactorObject:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                        //Error out, no storedTrustFactorObjects were able to be added
                        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                        [errorDetails setValue:@"No storedTrustFactorObjects addeded to global store" forKey:NSLocalizedDescriptionKey];
                        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsAddedToStore userInfo:errorDetails];
                    
                        // Don't return anything
                        return nil;
                    }
                
                
                
                
                }
                else // we found an existing stored assertion, check revisions
                {
                
                
                    //if revisions do not match create new
                    if (![Sentegrity_Baseline_Analysis checkTrustFactorRevision:trustFactorOutputObject withStored:storedTrustFactorObject]) {
                    
                        //create a new object in the global store
                        storedTrustFactorObject = [globalStore createStoredTrustFactorObjectFromTrustFactorOutput:trustFactorOutputObject withError:error];
                    
                        //update the trustFactorOutputObject with newly created storedTrustFactorObject
                        trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
                    
                        //perform baseline analysis against storedTrustFactorObject
                        updatedTrustFactorOutputObject = [self performBaselineAnalysisUsing:trustFactorOutputObject withBaselineAnalysisResults:baselineAnalysisResults withError:error];
                    
                        // Check if created
                        if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                            // Error out, something went wrong in compare
                            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                            [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                        
                            // Don't return anything
                            return nil;
                        }
                    
                        //replace existing in the global store
                        if (![globalStore setStoredTrustFactorObject:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
                            // Error out, no storedTrustFactorOutputObjects were able to be added
                            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                            [errorDetails setValue:@"Unable to replace stored assertion" forKey:NSLocalizedDescriptionKey];
                            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToSetAssertionToStore userInfo:errorDetails];
                        
                            // Don't return anything
                            return nil;
                        }
                    
                    
                    }
                    else{ //revisions match, no modification required only check learning
                    
                        //update the trustFactorOutputObject with newly created storedTrustFactorObject
                        trustFactorOutputObject.storedTrustFactorObject = storedTrustFactorObject;
                    
                        //perform baseline analysis against storedTrustFactorObject
                        updatedTrustFactorOutputObject = [self performBaselineAnalysisUsing:trustFactorOutputObject withBaselineAnalysisResults:baselineAnalysisResults withError:error];
                    
                        // Check if created
                        if (!updatedTrustFactorOutputObject || updatedTrustFactorOutputObject == nil) {
                            // Error out, something went wrong in compare
                            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                            [errorDetails setValue:@"Unable to perform baseline analysis for trustFactorOutputObject" forKey:NSLocalizedDescriptionKey];
                            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToPerformBaselineAnalysisForTrustFactor userInfo:errorDetails];
                        
                            // Don't return anything
                            return nil;
                        }
                    
                        //since we modified, replace existing in the local store
                        if (![globalStore setStoredTrustFactorObject:updatedTrustFactorOutputObject.storedTrustFactorObject withError:error]) {
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
        }
        
    } //end FOR
    
    //save stores due to learning mode updates
    exists = YES;

    localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore forAppID:policy.appID overwrite:YES withError:error];
    globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] setGlobalStore:globalStore overwrite:YES withError:error];
    
    return baselineAnalysisResults;
}




+ (Sentegrity_TrustFactor_Output_Object *)performBaselineAnalysisUsing:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withBaselineAnalysisResults:(Sentegrity_Baseline_Analysis *)baselineAnalysisResults withError:(NSError **)error {
    
    //bool to indicate if rule should be added to computation/protect mode lists based on variety of factors
    BOOL addToProtectModeList=NO;
    BOOL addToComputationList=NO;
    
    trustFactorOutputObject.assertionsToWhitelist = [[NSMutableDictionary alloc] init];
    

    
    if (!trustFactorOutputObject) {
        // Failed, no trustFactorOutputObject found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No trustFactorOutputObject received or candidate assertions for compare" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    
        //If the TF did not run then we don't update anything
        if(trustFactorOutputObject.statusCode==DNEStatus_ok)
        {
            
            //Check if this rule should detect during provioning (first run), these to be BREACH_INDICATOR style rules
            //that return known bad values as output or the default if none are found, the purpose of this is to ensure
            //that if the device is compromised or high risk we don't learn bad baseline values during the first run of the rule
            //we correct this by manually checking for the default assertion prior to the actual comparison
            
            if(!trustFactorOutputObject.storedTrustFactorObject.learned && trustFactorOutputObject.trustFactor.provision.intValue==1)
            {
                //if the TF with provisoning attribute does not have the baseline, it found something bad
                if(![trustFactorOutputObject.assertions objectForKey:[trustFactorOutputObject generateDefaultAssertion]])
                {
                    //manually trigger it by setting the default assertion and moving others to whitelist
                    trustFactorOutputObject.storedTrustFactorObject.assertions = [trustFactorOutputObject generateDefaultAssertion];
                    
                    //set to learned to avoid compareAndUpdateLearning on next run
                    trustFactorOutputObject.storedTrustFactorObject.learned=YES;
                    
                    // Increment the run count for consisteny
                    trustFactorOutputObject.storedTrustFactorObject.runCount = [NSNumber numberWithInt:(trustFactorOutputObject.storedTrustFactorObject.runCount.intValue + 1)];
                }
            }
            
            
            //Check if TF is not learned and update it, this TF won't count towards computation
            if(!trustFactorOutputObject.storedTrustFactorObject.learned)
            {
                
                    //update learning attributes
                    [self compareAndUpdateLearning:trustFactorOutputObject];
 
            }
            else //TF is learned so lets compare assertions and add to computation
            {
        
                //for increment
                NSNumber *newHitCount;
                
                //for increment
                NSNumber *currentHitCount;
                
                
                //check if this is a normal rule and trigger on NO MATCH
                //e.g., knownBadProcesses, shortUptime, newRootProcess, etc
                if(trustFactorOutputObject.trustFactor.inverse.intValue==0)
                {
                    for(NSString *candidate in trustFactorOutputObject.assertions)
                    {
                        //We DID NOT find a match for the candidate in the store = RULE TRIGGERED (a bad thing, since it should match the kDefaultTrustFactorOutput assertion at the very least)
                        if(![trustFactorOutputObject.storedTrustFactorObject.assertions objectForKey:candidate])
                        {
                    
                            //update list, but we still need to look at all assertions before exiting loop
                            addToProtectModeList=YES;
                            addToComputationList=YES;
                            
                            //keep track of which assertions did not match for whitelisting within the TF itself (may be multiple)
                            [trustFactorOutputObject.assertionsToWhitelist setValue:[NSNumber numberWithInt:0] forKey:candidate];
  
                             
                        }
                        else //we DID find a match = RULE NOT YET TRIGGERED  (increment matching stored assertions hitcount)
                        {
                            //increment hitCount for matching stored assertion (used for decay)
                            newHitCount = [NSNumber numberWithInt:[[trustFactorOutputObject.storedTrustFactorObject.assertions objectForKey:candidate] intValue]+1];
                            [trustFactorOutputObject.storedTrustFactorObject.assertions setObject:newHitCount forKey:candidate];
                            
                            //test next assertion
                    
                        }
                    }
                    
                  
                }
                else //this is an inverse rule,  trigger on MATCH to ensure negative penalty is applied, these are authenticator type rules (e.g., knownBLEDevice, KnowWifiBSSID)
                {
                    for(NSString *candidate in trustFactorOutputObject.assertions)
                    {
                        //search for a match in the store
                         currentHitCount = [trustFactorOutputObject.storedTrustFactorObject.assertions objectForKey:candidate];
                        
                        //We FOUND a match for the candidate in the store
                        if(currentHitCount)
                        {
                            //if this rules has frequency requirments then enforce them
                            if(trustFactorOutputObject.trustFactor.threshold.intValue != 0)
                            {
                                // frequency threshold meet = RULE TRIGGERED (apply negative penalty and update the store)
                                if(currentHitCount >= trustFactorOutputObject.trustFactor.threshold)
                                {
                                    //only add as triggered if meet
                                    addToComputationList=YES;
                                    
                                }
                                
                                //else, we do nothing and wait for the hitcount to rise
                            }
                            else {
                                
                                //add TF to the computation list, but not protect mode (as we dont need to learn anything new)
                                addToComputationList=YES;
                                
                            }
                            

                    
                            //increment hitCount in all situations for the matching stored assertion (used for decay)
                            newHitCount = [NSNumber numberWithInt:[[trustFactorOutputObject.storedTrustFactorObject.assertions objectForKey:candidate] intValue]+1];
                            [trustFactorOutputObject.storedTrustFactorObject.assertions setObject:newHitCount forKey:candidate];
                    
                    
                    
                        }
                        else //no match, but add assertions to whitelist
                        {
                            //keep track of which assertions did not match for whitelisting within the TF itself (may be multiple)
                            [trustFactorOutputObject.assertionsToWhitelist setValue:[NSNumber numberWithInt:0] forKey:candidate];
                            
                            
                            //add TF to the protectMode list, but not computation
                            addToProtectModeList=YES;
                            
                        }
                    } //Inverse for loop
                    
            
            
                } //Inverse if-else

        
            } //TF learned if-then
            
            
            //add trustFactorOutputObject to protect mode list where appropriate
            if(addToProtectModeList)
            {
                //add TF to the protectMode list
                [baselineAnalysisResults.trustFactorOutputObjectsForProtectMode  addObject:trustFactorOutputObject];
            }
            
            //add trustFactorOutputObject to computation list where appropriate
            if(addToComputationList)
            {
                //add TF to the computation list
                [baselineAnalysisResults.trustFactorOutputObjectsForComputation addObject:trustFactorOutputObject];
                
            }
        }
        else{
            //add non-executed rules so their DNE_Status codes impact the score
            [baselineAnalysisResults.trustFactorOutputObjectsForComputation addObject:trustFactorOutputObject];
            
        } //dnestatus_OK if-then
    
    
    return trustFactorOutputObject;

    
}

+ (void)compareAndUpdateLearning:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject

{
    
    //first we must do the actual compare
    
    //candidate assertions
    NSMutableDictionary *candidateAssertions;
    candidateAssertions = trustFactorOutputObject.assertions;
    
    //stored assertions
    NSMutableDictionary *storedAssertions;
    storedAssertions = trustFactorOutputObject.storedTrustFactorObject.assertions;
    
    // If we dont have any storedAssertion then just add the candidates right in
    if (!storedAssertions || storedAssertions == nil || storedAssertions.count < 1) {
        
        // Empty assertions, must be the first run, set it to the candidates
        trustFactorOutputObject.storedTrustFactorObject.assertions = candidateAssertions;

        
    } else {
        // Contains existing assertions, we must append the new assertions by adding the dictionary to the existing dictionary but leave out duplicates
        
        NSNumber *hitCount = [NSNumber numberWithInt:0];
        
        for(NSString *key in candidateAssertions)
        {
            //if candidate assertion does not already exist in store
            if(![storedAssertions objectForKey:key])
            {
                //add with a 0 hitcount
                [storedAssertions setValue:hitCount forKey:key];
            }
            else //it does already exist
            {
                //increment hitcount
                hitCount = [NSNumber numberWithInt:[[storedAssertions objectForKey:key] intValue] +1];
                [storedAssertions setValue:hitCount forKey:key];
            }
            
        }
        
    }
    
    
    // Increment the run count to ensure a valid learning check
    trustFactorOutputObject.storedTrustFactorObject.runCount = [NSNumber numberWithInt:(trustFactorOutputObject.storedTrustFactorObject.runCount.intValue + 1)];
    

    // Determine which kind of learning mode the trustfactor has
    switch (trustFactorOutputObject.trustFactor.learnMode.integerValue) {
        case 1:
            // Learn Mode 1: Only needs the TrustFactor to run once
            
            // Set learned to YES
            trustFactorOutputObject.storedTrustFactorObject.learned = YES;
            
            break;
        case 2:
            // Learn Mode 2: Checks the number of runs and date since first run of TrustFactor
            
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
            
            // Check the time since first run (in days)
            if ([self daysBetweenDate:trustFactorOutputObject.storedTrustFactorObject.firstRun andDate:[NSDate date]] >= trustFactorOutputObject.trustFactor.learnTime.integerValue) {
                // Far enough apart in days
                
                // Check if we have enough stored assertions to be learned
                if (trustFactorOutputObject.storedTrustFactorObject.assertions.count >= trustFactorOutputObject.trustFactor.learnAssertionCount.integerValue) {
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
            break;
    }
    
    
    
}

+ (BOOL)checkTrustFactorRevision:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withStored:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject{
    // Check if the revision number is different - if so, return nil to create new
    if (trustFactorOutputObject.trustFactor.revision != storedTrustFactorObject.revision) {
        
        return NO;
    }
    
    
    return YES;
}

// Get the assertion store (if any) for the policy
+ (Sentegrity_Assertion_Store *)getLocalAssertionStoreForPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    // Make sure we got a policy
    if (!policy || policy.policyID < 0) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No policy provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoPolicyProvided userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Create the store
    Sentegrity_Assertion_Store *store;
    
    // Create a bool to check if it exists
    BOOL exists = NO;
    
    // Check with the assertion storage to see if we have one for the policy
    if ([[Sentegrity_TrustFactor_Storage sharedStorage] getListOfStores:error].count > 0) {
        
        // Find the local store by the name
        store = [[Sentegrity_TrustFactor_Storage sharedStorage] getLocalStoreWithAppID:policy.appID doesExist:&exists withError:error];
        
    }
    
    // Store doesn't exist, create it
    if ((!store || store == nil) && !exists) {
        // Set the store
        store = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:nil forAppID:policy.appID overwrite:NO withError:error];
    }
    
    // Return the store
    return store;
}

// Include date helper method to determine number of days between two dates
// http://stackoverflow.com/questions/4739483/number-of-days-between-two-nsdates
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
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

