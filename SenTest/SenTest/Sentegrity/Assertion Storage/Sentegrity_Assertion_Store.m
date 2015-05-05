//
//  Sentegrity_Assertion_Store.m
//  SenTest
//
//  Created by Kramer on 2/25/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Assertion_Store.h"
#import "Sentegrity_Constants.h"

@implementation Sentegrity_Assertion_Store

// Initialize
- (id)init {
    self = [super init];
    if (self) {
        [self setAssertions:[NSArray array]];
    }
    return self;
}

// Add assertions to the store
- (BOOL)addAssertionsIntoStore:(NSArray *)assertions withError:(NSError **)error {
    // Check if we received assertions
    if (!assertions || assertions.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of assertions
    for (Sentegrity_Assertion_Stored_Assertion_Object *assertion in assertions) {
        
        // Check to make sure the assertion was added to the store
        if (![self addAssertionIntoStore:assertion withError:error]) {
            
            // Error out, unable to add assertion into the store
            if (!*error || *error == nil) {
                // Create the error
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to add assertion into the store" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToAddAssertionIntoStore userInfo:errorDetails];
            }
            
            // Return NO
            return NO;
        }
    }
    
    // Return yes
    return YES;
}

// Add single assertion into the store
- (BOOL)addAssertionIntoStore:(Sentegrity_Assertion_Stored_Assertion_Object *)assertion withError:(NSError **)error {
    // Check that the passed assertion is valid
    if (!assertion || assertion == nil) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Check to see if the assertion already exists
    BOOL exists;
    if ([self getAssertionObjectWithFactorID:assertion.factorID doesExist:&exists withError:error] != nil || exists) {
        // Error out, already exists
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Cannot add assertion object into the store, already exists" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToAddAssertionIntoStoreAlreadyExists userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // We've gotten to this point
    NSMutableArray *assertionsArray = [self.assertions mutableCopy];
    
    // Add the assertion into the array
    [assertionsArray addObject:assertion];
    
    // Set the assertions
    [self setAssertions:assertionsArray];

    // Return YES
    return YES;
}

// Set multiple assertions into the store
- (BOOL)setAssertions:(NSArray *)assertions withError:(NSError **)error {
    // Check if we received assertions
    if (!assertions || assertions.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Invalid assertion objects provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidAssertionsProvided userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of assertions
    for (Sentegrity_Assertion_Stored_Assertion_Object *assertionObject in assertions) {
        
        // Check to make sure the assertion was added to the store
        if (![self setAssertion:assertionObject withError:error]) {
            
            // Error out, unable to add assertion into the store
            if (!*error || *error == nil) {
                // Create the error
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to set assertion in the store" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToAddAssertionIntoStore userInfo:errorDetails];
            }
            
            // Return NO
            return NO;
        }
    }
    
    // Return yes
    return YES;
}

// Set assertion into the store
- (BOOL)setAssertion:(Sentegrity_Assertion_Stored_Assertion_Object *)assertion withError:(NSError **)error {
    // Validate original assertion and replacement assertions
    if (!assertion || assertion == nil) {
        // Error out, no assertion objects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Missing provided assertion object" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Check to see if the original assertion already exists
    BOOL exists;
    Sentegrity_Assertion_Stored_Assertion_Object *existing = [self getAssertionObjectWithFactorID:assertion.factorID doesExist:&exists withError:error];
    if (existing || existing != nil || exists) {
        // Remove the original assertion from the array
        if (![self removeAssertion:existing withError:error]) {
            // Error out, unable to remove assertion
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Unable to remove assertion" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToRemoveAssertion userInfo:errorDetails];
            
            // Return NO
            return NO;
        }
    }
    
    // Add the new assertion object into the array
    if (![self addAssertionIntoStore:assertion withError:error]) {
        // Error out, unable to add the assertion into the store
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Unable to add assertion" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToAddAssertionIntoStore userInfo:errorDetails];
        
        // Return NO
        return NO;
    }

    // Return YES
    return YES;
}

// Add an assertion
- (NSArray *)compareAssertionsInStoreWithAssertions:(NSArray *)assertions withError:(NSError **)error
{
    // Check if we received assertions
    if (!assertions || assertions.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Create our mutable array of created compared assertions
    NSMutableArray *comparedAssertions = [NSMutableArray arrayWithCapacity:assertions.count];
    
    // Run through this array of assertions
    for (Sentegrity_TrustFactor_Output *assertion in assertions) {
        
        // Compared object
        Sentegrity_Assertion_Stored_Assertion_Object *comparedObject = [self findMatchingStoredAssertionInStore:assertion withError:error];
        
        // Check to make sure the assertion was added to the store
        if (!comparedObject || comparedObject == nil) {
            
            // Error out, unable to add assertion into the store
            if (!*error || *error == nil) {
                // Create the error
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to compare assertion" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToCompareAssertion userInfo:errorDetails];
            }
            
            // Return NO
            return nil;
        }
        
        // Add it to the compared objects array
        [comparedAssertions addObject:comparedObject];
    }
    
    // Return the compared assertions
    return comparedAssertions;
}

// Compare trustFactorOutput with what's in the store - Core Functionality
- (Sentegrity_Assertion_Stored_Assertion_Object *)findMatchingStoredAssertionInStore:(Sentegrity_TrustFactor_Output *)trustFactorOutput withError:(NSError **)error
{
    // Check that the passed trustFactorOutput is valid
    if (!trustFactorOutput || trustFactorOutput == nil) {
        // Error out, no assertion passed
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Get the existing stored assertion object by trustFactor ID, if it exists
    BOOL exists;
    Sentegrity_Assertion_Stored_Assertion_Object *storedAssertionObject = [self getAssertionObjectWithFactorID:trustFactorOutput.trustFactor.identification doesExist:&exists withError:error];

    // Check if the assertion object exists
    if ((!storedAssertionObject || storedAssertionObject == nil) && (exists)) {
        // Error out, no assertion found to compare
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No stored assertion found to compare to trustfactor output" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToFindAssertionToCompare userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Compare the stored assertion to trustFactorOutput
    Sentegrity_Assertion_Stored_Assertion_Object *comparison = [storedAssertionObject compare:trustFactorOutput withError:error];
    
    // If the assertion object doesn't exist, then create a new one
    if (!comparison || comparison == nil || error != nil) {
        // Doesn't exist, create a new one
        comparison = [self createAssertionObjectFromTrustFactorOutput:trustFactorOutput withError:error];
    }
    
    // Return the generated compared assertion
    return comparison;
}

// Remove provided assertion object from the store - returns whether it passed or failed
- (BOOL)removeAssertion:(Sentegrity_Assertion_Stored_Assertion_Object *)assertion withError:(NSError **)error {
    // Check that the passed assertion is valid
    if (!assertion || assertion == nil) {
        // Error out, no assertion object provided
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Return NO
        return NO;
    }
    
    // Check to see if the assertion already exists
    BOOL exists;
    if ([self getAssertionObjectWithFactorID:assertion.factorID doesExist:&exists withError:error] != nil || exists) {
        // Remove it
        NSMutableArray *assertionsArray = [self.assertions mutableCopy];
        
        // Add the assertion into the array
        [assertionsArray removeObject:assertion];
        
        // Set the assertions
        [self setAssertions:assertionsArray];
    } else {
        // Error out, no matching assertion objects found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No matching assertion object found" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoMatchingAssertionsFound userInfo:errorDetails];
        
        // Return NO
        return NO;
    }
    
    // Return YES
    return YES;
    
}

// Remove provided assertion objects from the store - returns whether it passed or failed
- (BOOL)removeAssertions:(NSArray *)assertions withError:(NSError **)error {
    // Check if we received assertions
    if (!assertions || assertions.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of assertions
    for (Sentegrity_Assertion_Stored_Assertion_Object *assertion in assertions) {
        
        // Check to make sure the assertion was added to the store
        if (![self removeAssertion:assertion withError:error]) {
            
            // Error out, unable to add assertion into the store
            if (!*error || *error == nil) {
                // Create the error
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to remove assertion from the store" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToRemoveAssertion userInfo:errorDetails];
            }
            
            // Return NO
            return NO;
        }
    }
    
    // Return yes
    return YES;
}

#pragma mark - Helper Methods (kind of)

// Create an assertion object from an assertion
- (Sentegrity_Assertion_Stored_Assertion_Object *)createAssertionObjectFromTrustFactorOutput:(Sentegrity_TrustFactor_Output *)assertion withError:(NSError **)error {
    // Check that the passed assertion is valid
    if (!assertion || assertion == nil) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertion provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Create a new assertion object for the provided assertion
    Sentegrity_Assertion_Stored_Assertion_Object *assertionObject = [[Sentegrity_Assertion_Stored_Assertion_Object alloc] init];
    [assertionObject setFactorID:assertion.trustFactor.identification];
    [assertionObject setRevision:assertion.revision];
    [assertionObject setHistory:assertion.trustFactor.history];
    [assertionObject setLearned:assertion.trustFactor.learnMode];
    [assertionObject setFirstRun:[NSDate date]];
    [assertionObject setRunCount:[NSNumber numberWithInt:1]];
    // Create the stored value
    Sentegrity_Assertion_Store_Assertion_Object_Stored_Value *stored = [[Sentegrity_Assertion_Store_Assertion_Object_Stored_Value alloc] init];
    // TODO: BETA2 Fix assertion object creation hashing
    [stored setHashValue:assertion.output];
    [stored setHitCount:[NSNumber numberWithInt:1]];
    [assertionObject setStored:stored];
    
    // Return the assertion object
    return assertionObject;
}

// Get an assertion object by its factorID
- (Sentegrity_Assertion_Stored_Assertion_Object *)getAssertionObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error {
    // Check the factor id passed is valid
    if (!factorID || factorID == nil) {
        // Error out, no factorID set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No factorID provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoFactorIDReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Check if assertions is valid
    if (!self.assertions || self.assertions.count < 1) {
        // No assertions
        *exists = NO;
        return nil;
    }
    
    // Run through all the assertions and check for the factorID
    for (Sentegrity_Assertion_Stored_Assertion_Object *assertion in self.assertions) {
        // Look for the matching assertion with the same factorID
        if ([assertion.factorID isEqualToNumber:factorID]) {
            *exists = YES;
            return assertion;
        }
    }
    
    // No trustfactor found
    *exists = NO;
    return nil;
}

@end
