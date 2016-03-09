//
//  ProtectMode.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "ProtectMode.h"

// Assertion Store
#import "Sentegrity_Assertion_Store+Helper.h"

// TrustFactor Storage
#import "Sentegrity_TrustFactor_Storage.h"

@implementation ProtectMode

// Init
- (id)init {
    // Initialize with our custom init
    return [self initWithPolicy:nil andTrustFactorsToWhitelist:nil];
}

// Init with our properties
- (id)initWithPolicy:(Sentegrity_Policy *)policy andTrustFactorsToWhitelist:(NSArray *)trustFactorsToWhitelist {
    if (self = [super init]) {
        _policy = policy;
        _trustFactorsToWhitelist = trustFactorsToWhitelist;
    }
    return self;
}


- (void)attemptTransparentAuthentication{
    
    
}


#pragma mark - Deactivations



// Deactivate Protect Mode User with user pin
- (BOOL)deactivateProtectModeAction:(NSInteger)action withInput:(NSString *)input andError:(NSError **)error {
    
    // Validate the user pin
    if (!input || input == nil || input.length < 1) {
        
        // Invalid User PIN
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid input provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid input", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:sentegrityDomain code:SAInvalidUserPinProvided userInfo:errorDetails];
        
        // Log it
        NSLog(@"Deactivate Protect Mode with input Failed: %@", errorDetails);
        
        // Return NO
        return NO;
    }
    
    
    // check protect mode action
    switch ((int)action) {
        case 1: {
            //REQUIRE USER PASSWORD
            if ([[input lowercaseString] isEqualToString:@"user"]) {
                
                // Log it
                NSLog(@"Deactivating Protect Mode");
                
                // Check the whitelist count
                if (self.trustFactorsToWhitelist.count > 0) {
                    
                    // Whitelist them and check for an error
                    if ([self whitelistAttributingTrustFactorOutputObjectsWithError:error] == NO) {
                        
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
            
            // Return NO - no errors
            return NO;
            
        }
            break;
            
        case 2: {
            // REQUIRE USER PASSWORD AND WARN ABOUT POLICY VIOLATION
            if ([[input lowercaseString] isEqualToString:@"user"]) {
                
                // Log it
                NSLog(@"Deactivating Protect Mode");
                
                // Check the whitelist count
                if (self.trustFactorsToWhitelist.count > 0) {
                    
                    // Whitelist them and check for an error
                    if ([self whitelistAttributingTrustFactorOutputObjectsWithError:error] == NO) {
                        
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
            
            // Return NO - no errors
            return NO;
            
        }
            break;

        case 3: {
            // REQUIRE USER PASSWORD AND WARN ABOUT DATA BREACH
            if ([[input lowercaseString] isEqualToString:@"user"]) {
                
                // Log it
                NSLog(@"Deactivating Protect Mode");
                
                // Check the whitelist count
                if (self.trustFactorsToWhitelist.count > 0) {
                    
                    // Whitelist them and check for an error
                    if ([self whitelistAttributingTrustFactorOutputObjectsWithError:error] == NO) {
                        
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
            
            // Return NO - no errors
            return NO;
            
        }
            break;
            
        case 4: {
            // PREVENT ACCESS
            }
            break;
        case 5: {
            // REQUIRE ADMIN PASSWORD
            
            if ([[input lowercaseString] isEqualToString:@"admin"]) {
                
                // Log it
                NSLog(@"Deactivating Protect Mode");
                
                // Check the whitelist count
                if (self.trustFactorsToWhitelist.count > 0) {
                    
                    // Whitelist them and check for an error
                    if ([self whitelistAttributingTrustFactorOutputObjectsWithError:error] == NO) {
                        
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
            
            // Return NO - no errors
            return NO;
            
        }
            break;
            
    }
    
    // for testing
    return YES;
    
  }

#pragma mark - Whitelisting

// Whitelist the Attributing TrustFactor Output Objects
- (BOOL)whitelistAttributingTrustFactorOutputObjectsWithError:(NSError **)error {
    
    // Create a variable to check if the localstore exists
    BOOL exists = NO;
    
    // Get the shared store
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getAssertionStore:&exists withAppID:self.policy.appID withError:error];
    
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
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in self.trustFactorsToWhitelist) {
        
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
    Sentegrity_Assertion_Store *localStoreOutput = [[Sentegrity_TrustFactor_Storage sharedStorage] setAssertionStore:localStore withAppID:self.policy.appID withError:error];
    
    // Validate it was set
    if (!localStoreOutput || localStoreOutput == nil) {
        
        // Unable to set the local store
        // Set the error if it's not set
        if (!*error) {
            
            // Unable to set stroe
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Whitelist Attributing TrustFactor Output Objects Failed", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error setting the local store", nil),
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
    
    // Return YES
    return YES;
}

@end

