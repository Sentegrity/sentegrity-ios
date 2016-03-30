//
//  ProtectMode.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "LoginAction.h"

// Assertion Store
#import "Sentegrity_Assertion_Store+Helper.h"

// TrustFactor Storage
#import "Sentegrity_TrustFactor_Storage.h"

// Transparent Auth
#import "TransparentAuthentication.h"

// Crypto
#import "Sentegrity_Crypto.h"

#import "CoreDetection.h"

@implementation LoginAction

// Singleton instance
+ (id)sharedLogin {
    static LoginAction *sharedLogin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogin = [[self alloc] init];
    });
    return sharedLogin;
}

#pragma mark - Deactivations



// Deactivate Protect Mode User with user pin
- (Sentegrity_LoginResponse_Object *)attemptLoginWithUserInput:(NSString *)Userinput andError:(NSError **)error {
    
    // Get computation results
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    //Create response object
    Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginResponse_Object alloc] init];
    
        if(computationResults.preAuthenticationAction == preAuthenticationAction_TransparentlyAuthenticate)
        {
            // Decrypt using previously determiend values
            computationResults.decryptedMasterKey = [[Sentegrity_Crypto sharedCrypto] decryptMasterKeyUsingTransparentAuthentication];
            
            // See if it decrypted
            if(computationResults.decryptedMasterKey != nil || !computationResults.decryptedMasterKey){
                
                // Set to success, no response title/desc required because its not used for transparent
                [loginResponseObject setAuthenticationResponseCode:authenticationResult_Success];
                [loginResponseObject setResponseLoginTitle:@""];
                [loginResponseObject setResponseLoginDescription:@""];
                [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                
                // Perform post auth action (e.g., whitelist)
                if ([LoginAction performPostAuthenticationActionWithError:error] == NO) {
                    
                    // Unable to perform post authentication events
                    
                    // Set the error if it's not set
                    if (!*error) {
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Post authentication action failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during post authentication", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Verify whitelisting and other post authentication actions", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToPerformPostAuthenticationAction userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Post authentication action failed: %@", errorDetails);
                    }
                    
                    // This is not catastrophic but it likely means we didn't whitelist, we will still return a loginResponseObject to keep things working because the master key decrypted successfully

                    [loginResponseObject setAuthenticationResponseCode:authenticationResult_recoverableError];
                    [loginResponseObject setResponseLoginTitle:@""];
                    [loginResponseObject setResponseLoginDescription:@""];
                    [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                    
                }
            }
            else{
                
                // Set to error, no response title/desc required because its not used for transparent
                [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
                [loginResponseObject setResponseLoginTitle:@""];
                [loginResponseObject setResponseLoginDescription:@""];
                [loginResponseObject setDecryptedMasterKey:nil];
                
            }
 
        } //We bundle these together because they do the same
        else if (computationResults.preAuthenticationAction == preAuthenticationAction_PromptForUserPassword || computationResults.preAuthenticationAction == preAuthenticationAction_PromptForUserPasswordAndWarn)
        {
            
            NSError *startupError;
            Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
            
            // Validate no errors
            if (!startup || startup == nil) {
                
                // Set to error, no response title/desc required because its not used for transparent
                [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
                [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
                [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
                [loginResponseObject setDecryptedMasterKey:nil];
                
            }
            
            // Derive key from user input (we do this here instead of inside sentegrity crypto to prevent doing multiple key derivations, in the event the password is correct and we need to do decryption)
            NSData *userKey = [[Sentegrity_Crypto sharedCrypto] getUserKeyForPassword:Userinput];
            
            // Create user key hash
            NSString *candidateUserKeyHash =  [[Sentegrity_Crypto sharedCrypto] createSHA1HashOfData:userKey];
            
            // Retrieve the stored user key hash created during provisoning
            NSString *storedUserKeyHash = [startup userKeyHash];
            
            
            // Successful login
            if([candidateUserKeyHash isEqualToString:storedUserKeyHash]){
                
                // attempt to decrypt master
                computationResults.decryptedMasterKey = [[Sentegrity_Crypto sharedCrypto] decryptMasterKeyUsingUserKey:userKey];
                
                // See if it decrypted
                if(computationResults.decryptedMasterKey != nil || !computationResults.decryptedMasterKey){
                    
                    // Set to success, no response title/desc required
                    [loginResponseObject setAuthenticationResponseCode:authenticationResult_Success];
                    [loginResponseObject setResponseLoginTitle:@""];
                    [loginResponseObject setResponseLoginDescription:@""];
                    [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                    
                    // Perform post auth action (e.g., whitelist)
                    if ([LoginAction performPostAuthenticationActionWithError:error] == NO) {
                        
                        // Unable to perform post authentication events
                        
                        // Set the error if it's not set
                        if (!*error) {
                            NSDictionary *errorDetails = @{
                                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Post authentication action failed", nil),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during post authentication", nil),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Verify whitelisting and other post authentication actions", nil)
                                                           };
                            
                            // Set the error
                            *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToPerformPostAuthenticationAction userInfo:errorDetails];
                            
                            // Log it
                            NSLog(@"Post authentication action failed: %@", errorDetails);
                        }
                        
                        // This is not catastrophic but it likely means we didn't whitelist, we will still return a loginResponseObject to keep things working because the master key decrypted successfully
                        
                        [loginResponseObject setAuthenticationResponseCode:authenticationResult_recoverableError];
                        [loginResponseObject setResponseLoginTitle:@""];
                        [loginResponseObject setResponseLoginDescription:@""];
                        [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                        
                    }

                }
                else{
                    
                    // Set to error, no response title/desc required because its not used for transparent
                    [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
                    [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
                    [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
                    [loginResponseObject setDecryptedMasterKey:nil];
                    
                }

            }
            else{ // Login failed
                
                // Set to error, no response title/desc required because its not used for transparent
                [loginResponseObject setAuthenticationResponseCode:authenticationResult_incorrectLogin];
                [loginResponseObject setResponseLoginTitle:@"Incorrect password"];
                [loginResponseObject setResponseLoginDescription:@"Please retry your password"];
                [loginResponseObject setDecryptedMasterKey:nil];
            }
        
        }
        else{ // Somehow we ended up here
            // Set to error, no response title/desc required because its not used for transparent
            [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
            [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
            [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
            [loginResponseObject setDecryptedMasterKey:nil];
        }
    

    
    return loginResponseObject;


}


// Perform post-login action
+ (BOOL)performPostAuthenticationActionWithError:(NSError **)error{
    
    // Get computation results
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    //Get trustfactors to whitelist from computation results
    NSArray *trustFactorsToWhitelist;
    
    
    switch (computationResults.postAuthenticationAction) {
        case postAuthenticationAction_whitelistUserAssertions:{
            
            trustFactorsToWhitelist = computationResults.userTrustFactorWhitelist;
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                    }
                    
                    // Return NO
                    return NO;
                    
                }
                
            }
            
            // Return YES - no errors
            return YES;
            
        }
            break;
        case postAuthenticationAction_whitelistUserAndSystemAssertions:{
            
            trustFactorsToWhitelist = [computationResults.userTrustFactorWhitelist arrayByAddingObjectsFromArray:computationResults.systemTrustFactorWhitelist];
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                    }
                    
                    // Return NO
                    return NO;
                    
                }
                
            }
            
            // Return YES - no errors
            return YES;
            
        }
            break;
        case postAuthenticationAction_whitelistSystemAssertions:{
            
            trustFactorsToWhitelist = computationResults.systemTrustFactorWhitelist;
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                    }
                    
                    // Return NO
                    return NO;
                    
                }
                
            }
            
            // Return YES - no errors
            return YES;
            
        }
            break;
        case postAuthenticationAction_whitelistUserAssertionsAndCreateTransparentKey:{
            
            trustFactorsToWhitelist = computationResults.userTrustFactorWhitelist;
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                    }
                    
                    // Return NO
                    return NO;
                    
                }
                
            }
            
            // Now create a new transparent key
            Sentegrity_TransparentAuth_Object *newTransparentObject = [[Sentegrity_Crypto sharedCrypto] createNewTransparentAuthKeyObject];
            
            // Check for error
            if (!newTransparentObject || newTransparentObject == nil) {
                
                // Unable to whitelist attributing TrustFactor Output Objects
                
                // Set the error if it's not set
                if (!*error) {
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to create new transparent key", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Faile to create new object for whitelisting", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check transparent object parameters", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToCreateNewTransparentKey userInfo:errorDetails];
                    
                    // Log it
                    NSLog(@"New transparent auth object store failed: %@", errorDetails);
                }
                
                // Return NO
                return NO;
                
            }

            
            // Get the current Transparent objects from the startup file and re-set the file
            
            NSError *startupError;
            Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
            
            // Validate no errors
            if (!startup || startup == nil) {
                
                
                // Error out, no trustFactorOutputObject were able to be added
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file during whitelisting", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStartupInstance userInfo:errorDetails];
                
                // Log Error
                NSLog(@"Failed to get startup file during whitelisting: %@", errorDetails);
                
                return NO;
                
            }

            
            NSMutableArray * currentTransparentAuthKeyObjects = [[startup transparentAuthKeyObjects] mutableCopy];
            [currentTransparentAuthKeyObjects addObject:newTransparentObject];
            
            // Set
            [startup setTransparentAuthKeyObjects:currentTransparentAuthKeyObjects];
            
            // Return YES - no errors
            return YES;

            
        }
            break;
        default: //We only care aboute whitelisting here, anything else, such as show suggestions or doNothing is handled outside of this
            return NO;
            break;
    }
    

    
  }

#pragma mark - Whitelisting

// Whitelist the Attributing TrustFactor Output Objects
+ (BOOL)whitelistAttributingTrustFactorOutputObjects:(NSArray *)trustFactorsToWhitelist withError:(NSError **)error {
    
    // Create a variable to check if the localstore exists
    BOOL exists = NO;
    
    // Get the shared store
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getAssertionStoreWithError:error];
    
    // Check for errors
    if (!localStore || localStore == nil || !exists) {
        
        // Unable to get the local store
        // Set the error if it's not set
        if (!*error) {
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Whitelist Attributing TrustFactor Output Objects Failed", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error getting the local store", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to whitelist", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
            
            // Log it
            NSLog(@"Whitelist Attributing TrustFactor Output Objects Failed: %@", errorDetails);
        }
        
        // Return NO
        return NO;
    }
    
    // Create variables to hold the existing assertion objects and the merged assertion objects
    NSArray *existingStoredAssertionObjects = [NSArray array];
    NSArray *mergedStoredAssertionObjects = [NSArray array];
    
    // Run through all the Assertions in the whitelist
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorsToWhitelist) {
        
        // Make sure the assertionObjects is not empty or we cant merge
        if (trustFactorOutputObject.storedTrustFactorObject.assertionObjects == nil || trustFactorOutputObject.storedTrustFactorObject.assertionObjects.count < 1) {
            
            // Set the assertion objects
            
            // Set the assertion objects to the whitelist objects
            trustFactorOutputObject.storedTrustFactorObject.assertionObjects = trustFactorOutputObject.candidateAssertionObjects;
            
        } else {
            
            // Merge the assertion objects
            
            // Get the existing objects
            existingStoredAssertionObjects = trustFactorOutputObject.storedTrustFactorObject.assertionObjects;
            
            // Get the merged objects
            mergedStoredAssertionObjects = [existingStoredAssertionObjects arrayByAddingObjectsFromArray:trustFactorOutputObject.candidateAssertionObjectsForWhitelisting];
            
            // Set the merged list back to storedTrustFactorObject
            [trustFactorOutputObject.storedTrustFactorObject setAssertionObjects:mergedStoredAssertionObjects];
        }
        
        // Check for matching stored assertion object in the local store
        Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
        
        // If we can't find in the local store then skip
        if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists == NO) {
            // Continue
            continue;
        }
        
        // Try to set the storedTrustFactorObject back in the store, skip if fail
        if (![localStore replaceSingleObjectInStore:trustFactorOutputObject.storedTrustFactorObject withError:error]) {
            // Continue
            continue;
        }
    }
    
    // Update the stores
    [[Sentegrity_TrustFactor_Storage sharedStorage] setAssertionStoreWithError:error];
    
        
    // Return YES
    return YES;
}

@end

