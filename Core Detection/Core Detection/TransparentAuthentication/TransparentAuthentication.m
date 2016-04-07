//
//  TransparentAuthentication.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "TransparentAuthentication.h"

@implementation TransparentAuthentication

// Singleton instance
+ (id)sharedTransparentAuth {
    static TransparentAuthentication *sharedTransparentAuthentication = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTransparentAuthentication = [[self alloc] init];
    });
    return sharedTransparentAuthentication;
}

// Attempt Transparent Authentication for Computation
-  (Sentegrity_TrustScore_Computation *)attemptTransparentAuthenticationForComputation:(Sentegrity_TrustScore_Computation *)computationResults withPolicy:policy withError:(NSError **)error {
    
    // Validate no errors
    if (!computationResults.transparentAuthenticationTrustFactorOutputObjects || computationResults.transparentAuthenticationTrustFactorOutputObjects == nil) {
        
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No TrustFactorsObjects for transparent authentication processing", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No transparent authentication TrustFactorObjects", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTransparentAuthenticationTrustFactorObjects userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get transparent auth trustfactor objects: %@", errorDetails);
        
        // We stil return computationResults instead of nil so that we can continue even if transparent auth fails
        // A transparent auth failure is not catastrophic
        computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthError;
        computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
        computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
        return computationResults;
        
    }
    
    NSString *candidateTransparentKeyRawOutputString=@"";
    
    // Concat all transparent auth realted TrustFactor output data to comprise the transparent key
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in computationResults.transparentAuthenticationTrustFactorOutputObjects) {
        
        // Iterate through all output returned by TrustFactor
        for(NSString *output in trustFactorOutputObject.output) {
            
           candidateTransparentKeyRawOutputString = [candidateTransparentKeyRawOutputString stringByAppendingFormat:@",%@",output];
        }
        
        
    }
    
    // Get startup store of current transparent authentication key hashes
    // Get our startup file
    //NSError *startupError;
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
    
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
        
        // We stil return computationResults instead of nil so that we can continue even if transparent auth fails
        // A transparent auth failure is not catastrophic
        computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthError;
        computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
        computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
        return computationResults;
        
    }
    
    
    // Generate the PBKDF2 raw key from concatinated output and set it, salt is created once at startup and used for all PBKDF2 of
    // transparent auth keys - a different salt is used for encryption of the master key by each transparent key
    NSError *transparentKeyError;
    computationResults.candidateTransparentKey = [[Sentegrity_Crypto sharedCrypto] getTransparentKeyForTrustFactorOutput:candidateTransparentKeyRawOutputString withError:&transparentKeyError];
    
    // Validate return value
    if (!computationResults.candidateTransparentKey || computationResults.candidateTransparentKey == nil) {
        
        // Invalid return value
        
        // Check if we received an error
        if (transparentKeyError || transparentKeyError != nil) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error during transparent auth PBKDF2 of candidate transparent key", nil),
                                           NSLocalizedFailureReasonErrorKey: transparentKeyError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey: transparentKeyError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:sentegrityDomain code:SAInvalidPBKDF2TransparentKeyDerivation userInfo:errorDetails];
            
        } else {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error during transparent auth PBKDF2 of candidate transparent key", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No trustfactor output or missing salt", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:sentegrityDomain code:SAInvalidPBKDF2TransparentKeyDerivation userInfo:errorDetails];
            
        } // Done checking if we received an error
        
        // Log Error
        NSLog(@"Failed to derive key for transparent authentication candidate using  trustfactor output: %@", [*error debugDescription]);
        
        // We stil return computationResults instead of nil so that we can continue even if transparent auth fails
        // A transparent auth failure is not catastrophic
        computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthError;
        computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
        computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
        return computationResults;
        
    }
    
    // Create SHA1 hash of PBKDF2 raw key to perform search on and save for later in the event we dont find a match and
    // it is used to create a new key completely
    NSError *shaHashError = nil;
    computationResults.candidateTransparentKeyHashString = [[Sentegrity_Crypto sharedCrypto] createSHA1HashOfData:computationResults.candidateTransparentKey withError:&shaHashError];
    
    // Check if the candidate transparent key hash string was received
    if (!computationResults.candidateTransparentKeyHashString || computationResults.candidateTransparentKeyHashString == nil || computationResults.candidateTransparentKey.length < 1) {
        
        // Check if we received an error
        if (shaHashError || shaHashError != nil) {
            
            // Log the error
            NSLog(@"%@", shaHashError.debugDescription);
            
        } else {
            
            // Did not get a value for the candidate transparent key hash string
            NSLog(@"Did not get a value for the candidateTransparentKeyHashString");
            
        } // Done checking if error is valid
        
    } // Done checking candidateTransparentKeyHashString
    
    //Temporary for debugging purposes (add on plaintext)
    computationResults.candidateTransparentKeyHashString = [computationResults.candidateTransparentKeyHashString stringByAppendingFormat:@"-%@",candidateTransparentKeyRawOutputString];
    
    
    // TODO: Utilize Error
    
    // Defaults
    computationResults.foundTransparentMatch=NO;
    
    // Perform transparent authentication decay
    NSArray * currentTransparentAuthKeyObjects = [startup transparentAuthKeyObjects];
    NSArray * decayedTransparentAuthKeyObjects;
    
    if(currentTransparentAuthKeyObjects.count>0){
        
        // Decay
        decayedTransparentAuthKeyObjects  = [self performMetricBasedDecay:currentTransparentAuthKeyObjects forPolicy:policy withError:error];
        
        // Compare current transparent key hash to stored hashes
        for(Sentegrity_TransparentAuth_Object *storedTransparentAuthObject in decayedTransparentAuthKeyObjects)
        {
            
            if([[storedTransparentAuthObject transparentKeyPBKDF2HashString] isEqualToString:computationResults.candidateTransparentKeyHashString]){
                
                computationResults.foundTransparentMatch=YES;
                
                // Update decay information
                
                //increment hitCount for matching storedTransparentAuthObject
                NSNumber *origHitCount = [storedTransparentAuthObject hitCount];
                [storedTransparentAuthObject setHitCount:[NSNumber numberWithInt:[origHitCount intValue]+1]];
                
                // update last hit time
                [storedTransparentAuthObject setLastTime:[NSNumber numberWithInteger:[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch]]];
                
                
                // Store the matching transparentAuth Object in computation results
                computationResults.matchingTransparentAuthenticationObject = storedTransparentAuthObject;
                
                // return current successful status (may change if decrypt fails later on)
                computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthSuccess;
                computationResults.preAuthenticationAction = preAuthenticationAction_TransparentlyAuthenticate;
                
                // its up for debate if we whitelist when there is transparent authentication taking place
                // obviously there cant be much to whitelist if we were above the userScore threshold
                // this allows sentegrity to auto-whitelist without a user intervention
                // im not sure what the impact of this may be on the profile if the user is constantly transparently authetnicated
                // it may help build a stronger profile when the user is not transparently authenticated or result in a bad profile
                
                computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
                
                break;
                
            }
        }
        
        // Set
        [startup setTransparentAuthKeyObjects:decayedTransparentAuthKeyObjects];
    }
    
    // Determine the actions to take once core detection completes
    // Transparent auth does not get its action codes from the policy, they are determined during runtime
    // This is unlike attributing classifications when the device is untrusted
    // In those conditions (violationActionCode and authenticationActionCodes are pulled striaght from that classifications
    // policy declerations
    
    if(computationResults.coreDetectionResult != CoreDetectionResult_TransparentAuthSuccess && computationResults.coreDetectionResult != CoreDetectionResult_TransparentAuthError && computationResults.foundTransparentMatch==NO){
        
        // If we made it this far there were no errors but we didnt find a match otherwise TransparentAuthSuccess would be present
        // checking for foundMatch is purely a sanity check as under normal operation if we make it this far and TransparentAuthSuccess
        // is not present then it has to be a new key
        
        computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthNewKey;
        computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
        computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertionsAndCreateTransparentKey;
    }
    
    return computationResults;
    
    
}

// Metric based decay function
- (NSArray *)performMetricBasedDecay:(NSArray *)currentTransparentAuthObjects forPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    double secondsInADay = 86400.0;
    double daysSinceCreation=0.0;
    double hitsPerDay=0.0;
    
    // Array to hold transparent auth objects to retain
    NSMutableArray *transparentAuthObjectsToKeep = [[NSMutableArray alloc]init];
    
    // Iterate through stored transparent auth objects
    for(Sentegrity_TransparentAuth_Object *storedTransparentAuthObject in currentTransparentAuthObjects){
        
        // Days since the assertion was created
        daysSinceCreation = ((double)[[Sentegrity_TrustFactor_Datasets sharedDatasets] runTimeEpoch] - [storedTransparentAuthObject.created doubleValue]) / secondsInADay;
        
        // Check when last time it was created
        if(daysSinceCreation < 1){
            
            // Set creation date to 1 if less than 1
            daysSinceCreation = 1;
        }
        
        // Calculate our decay metric
        hitsPerDay = [storedTransparentAuthObject.hitCount doubleValue] / (daysSinceCreation);
        
        // Set the metric for storage
        [storedTransparentAuthObject setDecayMetric:hitsPerDay];
        
        // If the stored assertions (days / hits) metric exceeds the policy keep it
        if([storedTransparentAuthObject decayMetric] > policy.transparentAuthDecayMetric.floatValue) {
            
            [transparentAuthObjectsToKeep addObject:storedTransparentAuthObject];
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
    sortedArray = [transparentAuthObjectsToKeep sortedArrayUsingDescriptors:sortDescriptors];
    
    // Return TrustFactor object
    return transparentAuthObjectsToKeep;
}






@end

