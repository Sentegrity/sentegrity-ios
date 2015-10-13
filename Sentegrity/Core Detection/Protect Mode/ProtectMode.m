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

#pragma mark - Activations

// Activate Protect Mode Policy
- (void)activateProtectModePolicy{
    
    NSLog(@"Protect Mode: Policy Executed");
    
}

// Activate Protect Mode User
- (void)activateProtectModeUser{
    
    
    NSLog(@"Protect Mode: User Executed");
    
    //take crypto disable action
    
    //prompt for user pin and wait
    
}

// Activate Protect Mode Wipe
- (void)activateProtectModeWipe{
    
    NSLog(@"Protect Mode: Wipe Executed");
    
    //take crypto disable action
    
    //show wipe screen
    
}

#pragma mark - Deactivations

// Deactivate Protect Mode Policy with policy pin
- (BOOL)deactivateProtectModePolicyWithPIN:(NSString *)policyPIN andError:(NSError **)error {
    
    // Validate the policy pin
    if (!policyPIN || policyPIN == nil || policyPIN.length < 1) {
        
        // Invalid Policy PIN
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Policy with PIN Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid PolicyPIN provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid policy PIN", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:sentegrityDomain code:SAInvalidPolicyPinProvided userInfo:errorDetails];
        
        // Return NO
        return NO;
    }
    
    // TODO: Remove this sometime in the future
    // Check if the policy pin is equal to admin
    if ([[policyPIN lowercaseString] isEqualToString:@"admin"]) {
        
        // Log it
        NSLog(@"Deactivating Protect Mode: Admin");
        
        // Check if the whitelistcount is more than 0
        if (self.trustFactorsToWhitelist.count > 0) {
            
            // Whitelist them and check for an error
            if ([self whitelistAttributingTrustFactorOutputObjectsWithError:error] == NO) {
                
                // Unable to whitelist attributing TrustFactor Output Objects
                
                // Set the error if it's not set
                if (!*error) {
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Policy with PIN Failed", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
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

// Deactivate Protect Mode User with user pin
- (BOOL)deactivateProtectModeUserWithPIN:(NSString *)userPIN andError:(NSError **)error {
    
    // Validate the user pin
    if (!userPIN || userPIN == nil || userPIN.length < 1) {
        
        // Invalid User PIN
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode User with PIN Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid UserPIN provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid user PIN", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:sentegrityDomain code:SAInvalidUserPinProvided userInfo:errorDetails];
        
        // Return NO
        return NO;
    }
    
    // TODO: Remove this sometime in the future
    // Check if the user pin is equal to user
    if ([[userPIN lowercaseString] isEqualToString:@"user"]) {
        
        // Log it
        NSLog(@"Deactivating Protect Mode: User");
        
        // Check the whitelist count
        if (self.trustFactorsToWhitelist.count > 0) {
            
            // Whitelist them and check for an error
            if ([self whitelistAttributingTrustFactorOutputObjectsWithError:error] == NO) {
                
                // Unable to whitelist attributing TrustFactor Output Objects
                
                // Set the error if it's not set
                if (!*error) {
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode User with PIN Failed", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:sentegrityDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
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

#pragma mark - Whitelisting

// Whitelist the Attributing TrustFactor Output Objects
- (BOOL)whitelistAttributingTrustFactorOutputObjectsWithError:(NSError **)error {
    
    // Create a variable to check if the localstore exists
    BOOL exists = NO;
    
    // Get the shared store
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getLocalStore:&exists withAppID:self.policy.appID withError:error];
    
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
            trustFactorOutputObject.storedTrustFactorObject.assertionObjects = trustFactorOutputObject.assertionObjectsToWhitelist;
            
        } else {
            
            // Merge the assertion objects
            
            // Get the existing objects
            existingStoredAssertionObjects = trustFactorOutputObject.storedTrustFactorObject.assertionObjects;
            
            // Get the merged objects
            mergedStoredAssertionObjects = [existingStoredAssertionObjects arrayByAddingObjectsFromArray:trustFactorOutputObject.assertionObjectsToWhitelist];
            
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
    Sentegrity_Assertion_Store *localStoreOutput = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore withAppID:self.policy.appID withError:error];
    
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
        }
        
        // Return NO
        return NO;
        
    }
    
    // Return YES
    return YES;
    
}

@end

