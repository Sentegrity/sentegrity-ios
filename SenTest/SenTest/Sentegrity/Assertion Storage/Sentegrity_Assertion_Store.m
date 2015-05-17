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
        [self setStoredTrustFactorObjects:[NSArray array]];
    }
    return self;
}

// Add StoredTrustFactorObjects to the master list
- (BOOL)addStoredTrustFactorObjects:(NSArray *)storedTrustFactorObjects withError:(NSError **)error {
    // Check if we received StoredTrustFactorObjects
    if (!storedTrustFactorObjects || storedTrustFactorObjects.count < 1) {
        // Error out, no StoredTrustFactorObjects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No StoredTrustFactorObjects provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of storedTrustFactorObjects
    for (Sentegrity_Stored_TrustFactor_Object *StoredTrustFactorObject in storedTrustFactorObjects) {
        
        // Check to make sure the StoredTrustFactorObject was added to the store
        if (![self addStoredTrustFactorObject:StoredTrustFactorObject withError:error]) {
            
            // Error out, unable to add StoredTrustFactorObject into the store
            if (!*error || *error == nil) {
                // Create the error
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to add StoredTrustFactorObject into the store" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToAddStoreTrustFactorObjectsIntoStore userInfo:errorDetails];
            }
            
            // Return NO
            return NO;
        }
    }
    
    // Return yes
    return YES;
}

// Add single StoredTrustFactorObject into the master list
- (BOOL)addStoredTrustFactorObject:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error {
    // Check that the passed StoredTrustFactorObject is valid
    if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
        // Error out, no trustfactors set
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No storedTrustFactorObject provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    
    // We've gotten to this point
    // JS - why do we make a copy here instead of modify the instance itself?
    NSMutableArray *StoredTrustFactorObjectsArray = [self.storedTrustFactorObjects mutableCopy];
    
    // Add the StoredTrustFactorObject into the array
    [StoredTrustFactorObjectsArray addObject:storedTrustFactorObject];
    
    // Set the StoredTrustFactorObjects
    [self setStoredTrustFactorObjects:StoredTrustFactorObjectsArray];

    // Return YES
    return YES;
}

// Replace multiple storedTrustFactorObjets in the master list
- (BOOL)setStoredTrustFactorObjects:(NSArray *)storedTrustFactorObjects withError:(NSError **)error {
    // Check if we received assertions
    if (!storedTrustFactorObjects || storedTrustFactorObjects.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Invalid storedTrustFactorObjects objects provided for replacement" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStoredTrustFactorObjectsProvided userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of storedTrustFactorObjects
    for (Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject in storedTrustFactorObjects) {
        
        // Check to make sure the storedTrustFactorObject was added to the store
        if (![self setStoredTrustFactorObject:storedTrustFactorObject withError:error]) {
            
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
- (BOOL)setStoredTrustFactorObject:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error {
    
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
        if (![self removeStoredTrustFactorObject:existing withError:error]) {
            // Error out, unable to remove StoredTrustFactorObject
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Unable to remove StoredTrustFactorObject" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToRemoveAssertion userInfo:errorDetails];
            
            // Return NO
            return NO;
        }
    }
    
    // Add the new StoredTrustFactorObject into the array
    if (![self addStoredTrustFactorObject:storedTrustFactorObject withError:error]) {
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



// JS - is this depricated?
- (NSArray *)compareStoredTrustFactorObjectsInStoreWithTrustFactorOutputObjects:(NSArray *)trustFactorOutputObjects withError:(NSError **)error
{
    // Check if we received assertions
    if (!trustFactorOutputObjects || trustFactorOutputObjects.count < 1) {
        // Error out, no assertions received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No assertions provided" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Create our mutable array of created compared assertions
    NSMutableArray *comparedObjects = [NSMutableArray arrayWithCapacity:trustFactorOutputObjects.count];
    
    // Run through this array of trustfactor output objects
    for (Sentegrity_TrustFactor_Output *trustFactorOutputObject in trustFactorOutputObjects) {
        
        // Compared stored trustfactor objects
        Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObjects = nil; //[self findMatchingStoredTrustFactorObjectInStore:trustFactorOutputObject withError:error];
        
        // Check to make sure the object was added to the store
        if (!storedTrustFactorObjects || storedTrustFactorObjects == nil) {
            
            // Error out, unable to add assertion into the store
            if (!*error || *error == nil) {
                // Create the error
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Unable to compare storedTrustFactorObjects" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToCompareAssertion userInfo:errorDetails];
            }
            
            // Return NO
            return nil;
        }
        
        // Add it to the compared objects array
        [comparedObjects addObject:storedTrustFactorObjects];
    }
    
    // Return the compared assertions
    return comparedObjects;
}

// Remove the single provided storedTrustFactorObject  from the store - returns whether it passed or failed
- (BOOL)removeStoredTrustFactorObject:(Sentegrity_Stored_TrustFactor_Object *)storedTrustFactorObject withError:(NSError **)error {
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
        // Remove it
        NSMutableArray *storedTrustFactorObjectArray = [self.storedTrustFactorObjects mutableCopy];
        
        // Remove the storedTrustFactorObject from the array
        [storedTrustFactorObjectArray removeObject:storedTrustFactorObject];
        
        // Set the storedTrustFactorObjects
        [self setStoredTrustFactorObjects:storedTrustFactorObjectArray];
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
- (BOOL)removeStoredTrustFactorObjects:(NSArray *)storedTrustFactorObjects withError:(NSError **)error {
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
        if (![self removeStoredTrustFactorObject:storedTrustFactorObject withError:error]) {
            
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
- (Sentegrity_Stored_TrustFactor_Object *)createStoredTrustFactorObjectFromTrustFactorOutput:(Sentegrity_TrustFactor_Output *)trustFactorOutputObject withError:(NSError **)error {
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
    [storedTrustFactorObject setAssertions:trustFactorOutputObject.assertions];
    
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
