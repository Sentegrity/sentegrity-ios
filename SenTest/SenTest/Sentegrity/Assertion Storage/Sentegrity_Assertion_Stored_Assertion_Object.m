//
//  Sentegrity_Assertion_Store_Assertion_Object.m
//  SenTest
//
//  Created by Kramer on 3/1/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Assertion_Stored_Assertion_Object.h"
#import "Sentegrity_Constants.h"

@interface Sentegrity_Assertion_Stored_Assertion_Object(Private)

// Include date helper method to determine number of days between two dates
// http://stackoverflow.com/questions/4739483/number-of-days-between-two-nsdates
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@end

@implementation Sentegrity_Assertion_Stored_Assertion_Object

// Compare the assertion object values
- (instancetype)compare:(Sentegrity_TrustFactor_Output *)trustFactorOutput withError:(NSError **)error {
    // TODO: Possibly have to wrap this compare function in a check to see the trustfactoroutput dne_status - make sure this isn't adding invalid information
    
    // Validate trustfactor object
    if (!trustFactorOutput || trustFactorOutput == nil) {
        // Error out, no assertion objects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Missing provided trustFactorOutput object" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoAssertionsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    
    // Compare self values against the values in the passed assertion
    
    // Check if the revision number is different - if so, clean it out completely
    if (self.revision != trustFactorOutput.revision) {
        // Create a new assertion object for the provided trustFactorOutput
        Sentegrity_Assertion_Stored_Assertion_Object *newStoredAssertionObject = [[Sentegrity_Assertion_Stored_Assertion_Object alloc] init];
        [newStoredAssertionObject setFactorID:trustFactorOutput.trustFactor.identification];
        [newStoredAssertionObject setRevision:trustFactorOutput.revision];
        [newStoredAssertionObject setHistory:trustFactorOutput.trustFactor.history];
        [newStoredAssertionObject setLearned:NO];  // BETA2: Setting learned to no on first run - or if changing revision number
        [newStoredAssertionObject setFirstRun:[NSDate date]];
        [newStoredAssertionObject setRunCount:[NSNumber numberWithInt:0]]; // Beta2: Set to 0 so we don't increment twice!
        
        // Create the object that holds the stored assertion within the larger assertion object
        Sentegrity_Assertion_Store_Assertion_Object_Stored_Value *storedAssertion = [[Sentegrity_Assertion_Store_Assertion_Object_Stored_Value alloc] init];
        // TODO: BETA2 Fix the hash value by setting the hash value to assertions instead of output
        [storedAssertion setHashValue:trustFactorOutput.output];
        [storedAssertion setHitCount:[NSNumber numberWithInt:0]]; // Beta2: Set to 0 so we don't increment twice
        [newStoredAssertionObject setStored:storedAssertion];
        
        // Return new assertion object
        return newStoredAssertionObject;
    }
    
    // Set the history to be what's in the trustfactor TODO: probably change setting the history to just match what's in the trustfactor
    self.history = [trustFactorOutput.trustFactor history];
    
    // Check if the rule is learned yet
    if (!self.learned) {
        // Not learned, yet.  Add addtional objects to the hashvalue (output)
        
        // Check to see if the hash value is empty
        if (!self.stored.hashValue || self.stored.hashValue == nil || self.stored.hashValue.count < 1) {
            // Empty hash value, set it to our output
            // TODO: BETA2 Fix the hash value by setting the hash value to assertions instead of output
            [self.stored setHashValue:trustFactorOutput.output];
        } else {
            // Not an empty hash value, let's set it to our output
            // TODO: BETA2 Fix the hash value by setting the hash value to assertions instead of output
            [self.stored setHashValue:[self.stored.hashValue arrayByAddingObjectsFromArray:trustFactorOutput.output]];
        }
    }
    
    // Increment the run count
    self.runCount = [NSNumber numberWithInt:(self.runCount.intValue + 1)];
    
    // Set if the policy is learned (learning mode)
    // BETA2: Determine which kind of learning mode the trustfactor has
    switch (trustFactorOutput.trustFactor.learnMode.integerValue) {
        case 1:
            // Learn Mode 1 = General baseline of 0
            
            // Set learned to YES
            self.learned = YES;
            
            break;
        case 2:
            // Learn Mode 2
            
            // Check if the run count has been met
            if (self.runCount.integerValue >= trustFactorOutput.trustFactor.learnRunCount.integerValue) {
                // Run enough times to be learned
                
                // Now check if we've been run far enough apart (in days)
                if ([self daysBetweenDate:self.firstRun andDate:[NSDate date]] >= trustFactorOutput.trustFactor.learnTime.integerValue) {
                    // Far enough apart in days to be learned, set to YES
                    self.learned = YES;
                } else {
                    // Not run far enough apart in days to be learned, set to NO
                    self.learned = NO;
                }
                
            } else {
                // Not run enough times to be learned, set to NO
                self.learned = NO;
            }
            
            break;
        case 3:
            // Learn Mode 3
            
            // Check if we've been run far enough apart (in days)
            if ([self daysBetweenDate:self.firstRun andDate:[NSDate date]] >= trustFactorOutput.trustFactor.learnTime.integerValue) {
                // Far enough apart in days
                
                // Check if we have enough stored assertions to be learned
                if (self.stored.hashValue.count >= trustFactorOutput.trustFactor.learnAssertionCount.integerValue) {
                    // Enough input to call it learned, set to YES
                    self.learned = YES;
                } else {
                    // Not enough input to be learned, set to NO
                    self.learned = NO;
                }
            } else {
                // Not run far enough apart in days to be learned, set to NO
                self.learned = NO;
            }
        default:
            break;
    }
    
    // Set the first run date if it's not already set
    if (!self.firstRun || self.firstRun == nil) {
        // Set the first run date (making sure that the trustfactor output run date is valid)
        if (!trustFactorOutput.runDate || trustFactorOutput.runDate == nil) {
            // Unable to get the trustfactor output run date, set the run date to be now
            self.firstRun = [NSDate date];
        } else {
            // Set the run date to be the trustfactor output run date
            self.firstRun = [trustFactorOutput runDate];
        }
    }
    
    // Set
    [self.stored setHitCount:[NSNumber numberWithInt:(self.stored.hitCount.intValue + 1)]];
    
    // Return self
    return self;
}

// Include date helper method to determine number of days between two dates
// http://stackoverflow.com/questions/4739483/number-of-days-between-two-nsdates
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
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
