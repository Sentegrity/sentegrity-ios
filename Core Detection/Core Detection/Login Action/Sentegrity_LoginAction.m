//
//  Sentegrity_LoginAction.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_LoginAction.h"

// Assertion Store
#import "Sentegrity_Assertion_Store+Helper.h"

// TrustFactor Storage
#import "Sentegrity_TrustFactor_Storage.h"

// Transparent Auth
#import "TransparentAuthentication.h"

// Crypto
#import "Sentegrity_Crypto.h"

// Core Detection
#import "CoreDetection.h"

@implementation Sentegrity_LoginAction

// Singleton instance
+ (id)sharedLogin {
    static Sentegrity_LoginAction *sharedLogin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogin = [[self alloc] init];
    });
    return sharedLogin;
}

#pragma mark - Deactivations

// Attempt login with user input
- (Sentegrity_LoginResponse_Object *)attemptLoginWithUserInput:(NSString *)Userinput andError:(NSError **)error {
    
    // Get computation results
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    // Create response object
    Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginResponse_Object alloc] init];
    
    // Check if the preauthentication action is to transparently authenticate
    if (computationResults.preAuthenticationAction == preAuthenticationAction_TransparentlyAuthenticate) {
        
        // Transparent Authentication
        
        // Decrypt using previously determiend values
        computationResults.decryptedMasterKey = [[Sentegrity_Crypto sharedCrypto] decryptMasterKeyUsingTransparentAuthenticationWithError:error];
        
        // TODO: Utilize Error
        
        // See if it decrypted
        if (computationResults.decryptedMasterKey != nil || !computationResults.decryptedMasterKey) {
            
            // Set to success, no response title/desc required because its not used for transparent
            [loginResponseObject setAuthenticationResponseCode:authenticationResult_Success];
            [loginResponseObject setResponseLoginTitle:@""];
            [loginResponseObject setResponseLoginDescription:@""];
            [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
            
            // Perform post auth action (e.g., whitelist)
            if ([Sentegrity_LoginAction performPostAuthenticationActionWithError:error] == NO) {
                
                // Unable to perform post authentication events
                
                // Set the error if it's not set
                if (!*error) {
                    
                    // Set the error details
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Post authentication action failed", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during post authentication", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Verify whitelisting and other post authentication actions", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToPerformPostAuthenticationAction userInfo:errorDetails];
                    
                    // Log it
                    NSLog(@"Post authentication action failed: %@", errorDetails);
                    
                } // Done checking for error
                
                // This is not catastrophic but it likely means we didn't whitelist, we will still return a loginResponseObject to keep things working because the master key decrypted successfully
                [loginResponseObject setAuthenticationResponseCode:authenticationResult_recoverableError];
                [loginResponseObject setResponseLoginTitle:@""];
                [loginResponseObject setResponseLoginDescription:@""];
                [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                
            } // Done performing post auth action
            
        } else {
            
            // Set to error, no response title/desc required because its not used for transparent
            [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
            [loginResponseObject setResponseLoginTitle:@""];
            [loginResponseObject setResponseLoginDescription:@""];
            [loginResponseObject setDecryptedMasterKey:nil];
            
        } // Done seeing if it decrypted
        
    } // Done checking if the preauthentication action is to transparently authenticate
    
    // Check if the preauthentication action is to prompt for user password or prompt for user password and warn
    else if (computationResults.preAuthenticationAction == preAuthenticationAction_PromptForUserPassword || computationResults.preAuthenticationAction == preAuthenticationAction_PromptForUserPasswordAndWarn) {
        
        // Prompt for user password
        
        // We bundle these together because they do the same
        
        //NSError *startupError;
        Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] currentStartupStore];
        
        // Validate no errors
        if (!startup || startup == nil) {
            
            // Set to error, no response title/desc required because its not used for transparent
            NSLog(@"Unable to get the startup file for preauthentication action: PromptForUserPassword");
            [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
            [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
            [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
            [loginResponseObject setDecryptedMasterKey:nil];
            
        } // Done validating no errors
        
        // Derive key from user input (we do this here instead of inside sentegrity crypto to prevent doing multiple key derivations, in the event the password is correct and we need to do decryption)
        NSData *userKey = [[Sentegrity_Crypto sharedCrypto] getUserKeyForPassword:Userinput withError:error];
        
        // TODO: Utilize Error
        
        // Create user key hash
        NSString *candidateUserKeyHash =  [[Sentegrity_Crypto sharedCrypto] createSHA1HashOfData:userKey withError:error];
        
        // TODO: Utilize Error
        
        // Retrieve the stored user key hash created during provisoning
        NSString *storedUserKeyHash = [startup userKeyHash];
        
        // Successful login
        if ([candidateUserKeyHash isEqualToString:storedUserKeyHash]) {
            
            // Attempt to decrypt master
            computationResults.decryptedMasterKey = [[Sentegrity_Crypto sharedCrypto] decryptMasterKeyUsingUserKey:userKey withError:error];
            
            // TODO: Utilize Error
            
            // See if it decrypted
            if (computationResults.decryptedMasterKey != nil || !computationResults.decryptedMasterKey) {
                
                // Master key decrypted successfully
                
                // Set to success, no response title/desc required
                [loginResponseObject setAuthenticationResponseCode:authenticationResult_Success];
                [loginResponseObject setResponseLoginTitle:@""];
                [loginResponseObject setResponseLoginDescription:@""];
                [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                
                // Perform post auth action (e.g., whitelist)
                if ([Sentegrity_LoginAction performPostAuthenticationActionWithError:error] == NO) {
                    
                    // Unable to perform post authentication events
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Post authentication action failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during post authentication", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Verify whitelisting and other post authentication actions", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToPerformPostAuthenticationAction userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Post authentication action failed: %@", errorDetails);
                        
                    } // Done setting the error if not set
                    
                    // This is not catastrophic but it likely means we didn't whitelist, we will still return a loginResponseObject to keep things working because the master key decrypted successfully
                    [loginResponseObject setAuthenticationResponseCode:authenticationResult_recoverableError];
                    [loginResponseObject setResponseLoginTitle:@""];
                    [loginResponseObject setResponseLoginDescription:@""];
                    [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                    
                } // Done Perform Post Auth
                
            } else {
                
                // Set to error, no response title/desc required because its not used for transparent
                NSLog(@"Unable to authenticate: unable to decrypt master key");
                [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
                [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
                [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
                [loginResponseObject setDecryptedMasterKey:nil];
                
            } // Done Seeing if it decrypted
            
        } else {
            
            // Login failed
            
            // Set to error, no response title/desc required because its not used for transparent
            NSLog(@"Unable to authenticate: unsuccessful login");
            [loginResponseObject setAuthenticationResponseCode:authenticationResult_incorrectLogin];
            [loginResponseObject setResponseLoginTitle:@"Incorrect password"];
            [loginResponseObject setResponseLoginDescription:@"Please retry your password"];
            [loginResponseObject setDecryptedMasterKey:nil];
            
        } // Done Successful login
        
    } // Done cehcking if the preauthentication action is to prompt for user password or prompt for user password and warn
    
    // Check if the preauthentication action is to prompt for user password or prompt for user password and warn
    else if (computationResults.preAuthenticationAction == preAuthenticationAction_BlockAndWarn) {
        
        // Block and warn
        [loginResponseObject setAuthenticationResponseCode:authenticationResult_incorrectLogin];
        [loginResponseObject setResponseLoginTitle:@"Access Denied"];
        [loginResponseObject setResponseLoginDescription:@"This device has exceeded it's risk threshold."];
        [loginResponseObject setDecryptedMasterKey:nil];
        
    } else {
        
        // Somehow we ended up here
        
        // None of the preauthentication actions were hit
        
        // Set to error, no response title/desc required because its not used for transparent
        NSLog(@"Unable to authenticate: Preauthentication action: %ld", (long)computationResults.preAuthenticationAction);
        [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
        [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
        [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
        [loginResponseObject setDecryptedMasterKey:nil];
        
    } // Done Checking the authentication mechanism
    
    // Return the response object
    return loginResponseObject;
    
} // Done Attempt login with user input

// Perform post-login action
+ (BOOL)performPostAuthenticationActionWithError:(NSError **)error {
    
    // Get computation results
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    //Get trustfactors to whitelist from computation results
    NSArray *trustFactorsToWhitelist;
    
    // Go through the post authentication actions
    switch (computationResults.postAuthenticationAction) {
            
        case postAuthenticationAction_whitelistUserAssertions: {
            
            // Whitelist User Assertions
            
            // Get the trustfactors to whitelist
            trustFactorsToWhitelist = computationResults.userTrustFactorWhitelist;
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                        
                    } // Done checking for errors
                    
                    // Return NO
                    return NO;
                    
                } // Done whitelisting trustfacotrs
                
            } // Done checking for trustfactors to whitelist
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_whitelistUserAssertions
            
        case postAuthenticationAction_whitelistUserAndSystemAssertions: {
            
            // Whitelist user and system assertions
            
            // Get the trustfactors to whitelist
            trustFactorsToWhitelist = [computationResults.userTrustFactorWhitelist arrayByAddingObjectsFromArray:computationResults.systemTrustFactorWhitelist];
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                        
                    } // Done checking for errors
                    
                    // Return NO
                    return NO;
                    
                } // Done whitelisting assertions
                
            } // Done checking the whitelist count
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_whitelistUserAndSystemAssertions
            
        case postAuthenticationAction_whitelistSystemAssertions: {
            
            // Whitelist system assertions
            
            // Set the trustfactors to whitelist
            trustFactorsToWhitelist = computationResults.systemTrustFactorWhitelist;
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                        
                    } // Done checking for errors
                    
                    // Return NO
                    return NO;
                    
                } // Done whitelisting
                
            } // Done checking the whitelist count
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_whitelistSystemAssertions
            
        case postAuthenticationAction_whitelistUserAssertionsAndCreateTransparentKey: {
            
            // Whitelist user assertions and create transparent key
            
            // Set the trustfactors to whitelist
            trustFactorsToWhitelist = computationResults.userTrustFactorWhitelist;
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                        
                    } // Done checking for errors
                    
                    // Return NO
                    return NO;
                    
                } // Done whitelisting
                
            } // Done checking the whitelist count
            
            // Now create a new transparent key
            Sentegrity_TransparentAuth_Object *newTransparentObject = [[Sentegrity_Crypto sharedCrypto] createNewTransparentAuthKeyObjectWithError:(NSError **)error];
            
            // TODO: Utilize Error Checking
            
            // Check for error
            if (!newTransparentObject || newTransparentObject == nil) {
                
                // Unable to whitelist attributing TrustFactor Output Objects
                
                // Set the error if it's not set
                if (!*error) {
                    
                    // Set the error details
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to create new transparent key", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Faile to create new object for whitelisting", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check transparent object parameters", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToCreateNewTransparentKey userInfo:errorDetails];
                    
                    // Log it
                    NSLog(@"New transparent auth object store failed: %@", errorDetails);
                    
                } // Done checking for errors
                
                // Return NO
                return NO;
                
            } // Done Checking for newTransparent object errors
            
            // Get the current Transparent objects from the startup file and re-set the file
            
            //NSError *startupError;
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
                
                // Return no
                return NO;
                
            } // Done checking for errors
            
            // Create the currentTransparentAuthKeyObjects array
            NSMutableArray *currentTransparentAuthKeyObjects = [[startup transparentAuthKeyObjects] mutableCopy];
            [currentTransparentAuthKeyObjects addObject:newTransparentObject];
            
            // Set the Transparent Auth Key Objects
            [startup setTransparentAuthKeyObjects:currentTransparentAuthKeyObjects];
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_whitelistUserAssertionsAndCreateTransparentKey
            
        default: {
            
            // We only care aboute whitelisting here, anything else, such as show suggestions or doNothing is handled outside of this
            
            // Return NO
            return NO;
            
            // Break
            break;
            
        } // Done default
            
    } // Done switch
    
} // Done performPostAuthenticationActionWithError

#pragma mark - Whitelisting

// Whitelist the Attributing TrustFactor Output Objects
+ (BOOL)whitelistAttributingTrustFactorOutputObjects:(NSArray *)trustFactorsToWhitelist withError:(NSError **)error {
    
    // Get the shared store
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getAssertionStoreWithError:error];
    
    // Check for errors
    if (!localStore || localStore == nil ) {
        
        // Unable to get the local store
        // Set the error if it's not set
        if (!*error) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Whitelist Attributing TrustFactor Output Objects Failed", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error getting the local store", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to whitelist", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
            
            // Log it
            NSLog(@"Whitelist Attributing TrustFactor Output Objects Failed: %@", errorDetails);
            
        } // Done checking for errors
        
        // Return NO
        return NO;
        
    } // Done checking for localStore errors
    
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
        
        // Exists Variable
        BOOL exists;
        
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
        
    } // Done for
    
    // Update the stores
    [[Sentegrity_TrustFactor_Storage sharedStorage] setAssertionStoreWithError:error];
    
    // Return YES
    return YES;
    
} // Done whitelistAttributingTrustFactorOutputObjects

@end
