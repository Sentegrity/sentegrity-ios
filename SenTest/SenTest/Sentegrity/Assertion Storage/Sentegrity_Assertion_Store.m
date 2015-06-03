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
        [self setStoredTrustFactorObjects:[NSMutableArray array]];
    }
    return self;
}

// Add multiple new StoredTrustFactorObjects to the store
- (BOOL)addMultipleObjectsToStore:(NSArray *)storedTrustFactorObjects withError:(NSError **)error {
    // Check if we received StoredTrustFactorObjects
    if (!storedTrustFactorObjects || storedTrustFactorObjects.count < 1) {
        // Error out, no StoredTrustFactorObjects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No StoredTrustFactorObjects provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Run through provided array of storedTrustFactorObjects
    for (Sentegrity_Stored_TrustFactor_Object *newStoredTrustFactorObject in storedTrustFactorObjects) {
        
        // Add the new StoredTrustFactorObject into the array
        if (![self addSingleObjectToStore:newStoredTrustFactorObject withError:error]) {
            // Error out, unable to add the StoredTrustFactorObject into the store
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Unable to add StoredTrustFactorObject" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToAddStoreTrustFactorObjectsIntoStore userInfo:errorDetails];
            
            // Return NO
            return NO;
        }

    }
    // Return yes
    return YES;
}

// Add a single new StoredTrustFactorObject to the store
- (BOOL)addSingleObjectToStore:(Sentegrity_Stored_TrustFactor_Object *)newStoredTrustFactorObject withError:(NSError **)error {
    // Check that the passed StoredTrustFactorObject is valid
    if (!newStoredTrustFactorObject || newStoredTrustFactorObject == nil) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No storedTrustFactorObject provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Add the new StoredTrustFactorObject into the array
    [[self storedTrustFactorObjects] addObject:newStoredTrustFactorObject];
    
    // Return YES
    return YES;
}

// Replace multiple storedTrustFactorObjets in the master list
- (BOOL)replaceMultipleObjectsInStore:(NSArray *)existingStoredTrustFactorObjects withError:(NSError **)error {
    // Check if we received assertions
    if (!existingStoredTrustFactorObjects || existingStoredTrustFactorObjects.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Invalid storedTrustFactorObjects objects provided for replacement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStoredTrustFactorObjectsProvided userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of storedTrustFactorObjects
    for (Sentegrity_Stored_TrustFactor_Object *existingStoredTrustFactorObject in existingStoredTrustFactorObjects) {
        
        // Check to make sure the storedTrustFactorObject was added to the store
        if (![self replaceSingleObjectInStore:existingStoredTrustFactorObject withError:error]) {
            
            // Error out, unable to add storedTrustFactorObject into the store
            if (!*error || *error == nil) {
                // Create the error
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to replace storedTrustFactorObject in the store" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToAddStoreTrustFactorObjectsIntoStore userInfo:errorDetails];
            }
            
            // Return NO
            return NO;
        }
    }
    
    // Return yes
    return YES;
}

// Replace a single storedTrustFactorObject in the store
- (BOOL)replaceSingleObjectInStore:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error {
    
    if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
        // Error out, no storedTrustFactorObjects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Missing provided storedTrustFactorObject object during replacement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // MAke sure it already exists before replacement
    BOOL exists;
    Sentegrity_Stored_TrustFactor_Object *existing = [self getStoredTrustFactorObjectWithFactorID:storedTrustFactorObject.factorID doesExist:&exists withError:error];
    if (existing || existing != nil || exists) {
        // Remove the original storedTrustFactorObject from the array
        if (![self removeSingleObjectFromStore:existing withError:error]) {
            // Error out, unable to remove StoredTrustFactorObject
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Unable to remove StoredTrustFactorObject" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToRemoveAssertion userInfo:errorDetails];
            
            // Return NO
            return NO;
        }
    }
    
    // Add the new StoredTrustFactorObject into the array
    if (![self addSingleObjectToStore:storedTrustFactorObject withError:error]) {
        // Error out, unable to add the StoredTrustFactorObject into the store
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Unable to add StoredTrustFactorObject" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToAddStoreTrustFactorObjectsIntoStore userInfo:errorDetails];
        
        // Return NO
        return NO;
    }

    // Return YES
    return YES;
}

// Remove the single provided storedTrustFactorObject  from the store - returns whether it passed or failed
- (BOOL)removeSingleObjectFromStore:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error {
    // Check that the passed storedTrustFactorObject is valid
    if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
        // Error out, no assertion object provided
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No storedTrustFactorObjects provided for removal" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Return NO
        return NO;
    }
    
    // Check to see if the storedTrustFactorObject already exists
    BOOL exists;
    if ([self getStoredTrustFactorObjectWithFactorID:storedTrustFactorObject.factorID doesExist:&exists withError:error] != nil || exists) {
        
        // Remove the storedTrustFactorObject from the array
        [[self storedTrustFactorObjects] removeObject:storedTrustFactorObject];
        
    } else {
        // Error out, no matching storedTrustFactorObjects  found
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No matching storedTrustFactorObjects object found for removal" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoMatchingAssertionsFound userInfo:errorDetails];
        
        // Return NO
        return NO;
    }
    
    // Return YES
    return YES;
    
}

// Remove provided storedTrustFactorObjects from the store - returns whether it passed or failed
- (BOOL)removeMultipleObjectsFromStore:(NSArray *)storedTrustFactorObjects withError:(NSError **)error {
    // Check if we received assertions
    if (!storedTrustFactorObjects || storedTrustFactorObjects.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No storedTrustFactorObjects provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of assertions
    for (Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject in storedTrustFactorObjects) {
        
        // Check to make sure the storedTrustFactorObject was added to the store
        if (![self removeSingleObjectFromStore:storedTrustFactorObject withError:error]) {
            
            // Error out, unable to add storedTrustFactorObject into the store
            if (!*error || *error == nil) {
                // Create the error
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to remove storedTrustFactorObject from the store" forKey:NSLocalizedDescriptionKey];
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
- (Sentegrity_Stored_TrustFactor_Object *)createStoredTrustFactorObjectFromTrustFactorOutput:(Sentegrity_TrustFactor_Output_Object *)trustFactorOutputObject withError:(NSError **)error {
    // Check that the passed trustFactorOutputObject is valid
    if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No trustFactorOutputObject provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Create a new storedTrustFactorObject object for the provided trustFactorOutputObject
    Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [[Sentegrity_Stored_TrustFactor_Object alloc] init];
    [storedTrustFactorObject setFactorID:trustFactorOutputObject.trustFactor.identification];
    [storedTrustFactorObject setRevision:trustFactorOutputObject.trustFactor.revision];
    [storedTrustFactorObject setHistory:trustFactorOutputObject.trustFactor.history];
    [storedTrustFactorObject setLearned:NO]; // Beta2: don't set that it has learned
    [storedTrustFactorObject setFirstRun:[NSDate date]];
    [storedTrustFactorObject setRunCount:[NSNumber numberWithInt:0]]; // Beta2: Set the run count to 0 because we're incrementing on comparison
    
    // Return the assertion object
    return storedTrustFactorObject;
}

// Get the stored trust factor object by its factorID
- (Sentegrity_Stored_TrustFactor_Object *)getStoredTrustFactorObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error {
    // Check the factor id passed is valid
    if (!factorID || factorID == nil) {
        // Error out, no factorID set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No factorID provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoFactorIDReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Check if stored object is valid
    if (!self.storedTrustFactorObjects || self.storedTrustFactorObjects.count < 1) {
        // No assertions
        *exists = NO;
        return nil;
    }
    
    // Run through all the stored trustfactor objects and check for a matching factorID
    for (Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject in self.storedTrustFactorObjects) {
        // Look for the matching assertion with the same factorID
        if ([storedTrustFactorObject.factorID isEqualToNumber:factorID]) {
            *exists = YES;
            return storedTrustFactorObject;
        }
    }
    
    // No trustfactor found
    *exists = NO;
    return nil;
}



@end
