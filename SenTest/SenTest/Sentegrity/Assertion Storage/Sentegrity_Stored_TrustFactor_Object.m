//
//  Sentegrity_Assertion_Store_Assertion_Object.m
//  SenTest
//
//  Created by Kramer on 3/1/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_Stored_TrustFactor_Object.h"
#import "Sentegrity_Constants.h"

@interface Sentegrity_Stored_TrustFactor_Object(Private)

// Include date helper method to determine number of days between two dates
// http://stackoverflow.com/questions/4739483/number-of-days-between-two-nsdates
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@end

@implementation Sentegrity_Stored_TrustFactor_Object


- (instancetype)checkLearningAndUpdate:(Sentegrity_TrustFactor_Output *)trustFactorOutputObject withError:(NSError **)error {

    // Validate trustfactor object
    if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
        // Error out, no assertion objects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Missing provided trustFactorOutput object" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return nil;
    }
    

        // Not learned, yet.  Add addtional objects to the hashvalue (output)
        
        // Check to see if the assertions dictionary exist or is empty
        if (!self.assertions || self.assertions == nil || self.assertions.count < 1) {
       
            // Empty hash value, set it to just our assertions output to the current dictionary
            self.assertions = trustFactorOutputObject.assertions;
            
        } else {
            // Not an empty hash value, we must append the new assertions by adding the dictionary to the existing dictionary
            [self.assertions addEntriesFromDictionary:trustFactorOutputObject.assertions];
        }

    
    // Increment the run count to ensure a valid learning check
    self.runCount = [NSNumber numberWithInt:(self.runCount.intValue + 1)];
    

    // Determine which kind of learning mode the trustfactor has
    switch (trustFactorOutputObject.trustFactor.learnMode.integerValue) {
        case 1:
            // Learn Mode 1: Only needs the TrustFactor to run once
            
            // Set learned to YES
            self.learned = YES;
            
            break;
        case 2:
            // Learn Mode 2: Checks the number of runs and date since first run of TrustFactor
            
            // Check if the run count has been met
            if (self.runCount.integerValue >= trustFactorOutputObject.trustFactor.learnRunCount.integerValue) {
                // This TrustFactor has run enough times to be learned
                
                // Now check the time since first run  (in days)
                if ([self daysBetweenDate:self.firstRun andDate:[NSDate date]] >= trustFactorOutputObject.trustFactor.learnTime.integerValue) {
                    // Far enough apart in days to be learned, set to YES
                    self.learned = YES;
                } else {
                    // Not run far enough apart in days to be learned, set to NO
                    self.learned = NO;
                }
                
            } else {
                // Not run enough times to be learned, set to NO and never check time
                self.learned = NO;
            }
            
            break;
        case 3:
            // Learn Mode 3: Checks the number of assertions we have and the date since first run of TrustFactor
            
            // Check the time since first run (in days)
            if ([self daysBetweenDate:self.firstRun andDate:[NSDate date]] >= trustFactorOutputObject.trustFactor.learnTime.integerValue) {
                // Far enough apart in days
                
                // Check if we have enough stored assertions to be learned
                if (self.assertions.count >= trustFactorOutputObject.trustFactor.learnAssertionCount.integerValue) {
                    // Enough input to call it learned, set to YES
                    self.learned = YES;
                } else {
                    // Not enough assertions to be learned, set to NO
                    self.learned = NO;
                }
            } else {
                // Not run far enough apart in days to be learned, set to NO
                self.learned = NO;
            }
        default:
            break;
    }
    
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

// Compare the assertion object values
- (BOOL)revisionsMatch:(Sentegrity_TrustFactor_Output *)trustFactorOutputObject withError:(NSError **)error {
    
    // Validate trustfactor object
    if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
        // Error out, no assertion objects received
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Missing provided trustFactorOutput object" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }
    
    
    // Check if the revision number is different - if so, return nil to create new
    if (self.revision != trustFactorOutputObject.trustFactor.revision) {

        return NO;
    }
    
    
    return YES;
}

@end
