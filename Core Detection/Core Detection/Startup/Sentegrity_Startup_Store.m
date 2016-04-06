//
//  Sentegrity_Startup_Store.m
//  Sentegrity
//
//  Created by Kramer on 2/18/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "Sentegrity_Startup_Store.h"

// Constants
#import "Sentegrity_Constants.h"

// UIKit
#import <UIKit/UIKit.h>

// DCObjectMapping
#import "DCKeyValueObjectMapping.h"
#import "DCArrayMapping.h"
#import "DCParserConfiguration.h"
#import "NSObject+ObjectMap.h"

// Crypto
#import "Sentegrity_Crypto.h"

@implementation Sentegrity_Startup_Store

// Singleton instance
+ (id)sharedStartupStore {
    static Sentegrity_Startup_Store *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    return sharedStore;
}

// Get the startup file
- (Sentegrity_Startup *)getStartupStore:(NSError **)error {
    
    // Check if the startup file exists
    
    // Zero out the error
    *error = nil;
    
    // Print out the startup file path
    //NSLog(@"Startup File Path: %@", filePath);
    
    // Did we already create a startup store instance of the object?
    if(self.currentStartupStore == nil || !self.currentStartupStore){
        
            Sentegrity_Startup *startup = [[Sentegrity_Startup alloc] init];
            self.currentStartupStore = startup;
        
        // Check if the startup file exists, if not we will create a new one
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self startupFilePath]]) {
        
            
            // Set the current store
            [self populateNewStatupFileWithError:error];
            
            // Save the file
            //[self setStartupStoreWithError:error];
            
            // Check for errors
            if (*error || *error != nil) {
                
                // Encountered an error saving the file
                return nil;
                
            }
            
            // Saved the file, no errors, return the reference
            return self.currentStartupStore;
            
        } else {
            
            // Startup file does exist, just not yet parsed
            
            // Get the contents of the file
            NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self startupFilePath]]
                                                                       options:NSJSONReadingMutableContainers error:error];
            
            // Check the parsed startup file
            if (jsonParsed.count < 1 || jsonParsed == nil) {
                
                // Check if the error is set
                if (!*error || *error == nil) {
                    
                    // No such file
                    *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                 code:NSFileReadCorruptFileError
                                             userInfo:@{@"More Information": @"Startup File JSON may not be formatted correctly"}];
                }
                
                // Fail
                NSLog(@"Startup File JSON formatting problem");
                
                // Return nothing
                return nil;
            }
            
            // Map History
            DCArrayMapping *runHistorymapper = [DCArrayMapping mapperForClassElements:[Sentegrity_History_Object class] forAttribute:kRunHistory onClass:[Sentegrity_Startup class]];
            DCArrayMapping *transparentAuthKeymapper = [DCArrayMapping mapperForClassElements:[Sentegrity_TransparentAuth_Object class] forAttribute:kTransparentAuthKeys onClass:[Sentegrity_Startup class]];
            
            // Set up the parser configuration for json parsing
            DCParserConfiguration *config = [DCParserConfiguration configuration];
            [config addArrayMapper:runHistorymapper];
            [config addArrayMapper:transparentAuthKeymapper];
            
            // Set up the date parsing configuration
            config.datePattern = OMDateFormat;
            
            // Set the parser and include the configuration
            DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[Sentegrity_Startup class] andConfiguration:config];
            
            // Get the Startup Class from the parsing
            Sentegrity_Startup *startup = [parser parseDictionary:jsonParsed];
            
            // Make sure the class is valid
            if (!startup || startup == nil) {
                
                // Startup Class is invalid!
                
                // No valid policy provided
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Getting Startup File Unsuccessful", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Startup Class file is invalid", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try removing the startup file and retrying", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupFile userInfo:errorDetails];
                
            }
            
            // Return the object
            self.currentStartupStore = startup;
            return self.currentStartupStore;
            
        }

        
    }
    else{
        return self.currentStartupStore;
    }
    
    // Not found
    return nil;
}


// Create a new startup file
- (void)populateNewStatupFileWithError:(NSError **)error {
    
    
    /*
     * Set first time defaults for the application
     */
    
    
    /*
     * Set device salt
     */
    NSData *deviceSaltData = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
    [self.currentStartupStore setDeviceSaltString:[[Sentegrity_Crypto sharedCrypto] convertDataToHexString:deviceSaltData withError:error]];
    // TODO: Utilize Error
    /*
     * Set the user key salt
     */
    NSData *userKeySaltData = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
    [self.currentStartupStore setUserKeySaltString:[[Sentegrity_Crypto sharedCrypto] convertDataToHexString:userKeySaltData withError:error]];
    // TODO: Utilize Error
    /*
     * Set the transparent auth global PBKDF2 salt (used for all PBKDF2 transparent key hashes)
     */
    NSData *transparentAuthGlobalPBKDF2Salt = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
    [self.currentStartupStore setTransparentAuthGlobalPBKDF2SaltString:[[Sentegrity_Crypto sharedCrypto] convertDataToHexString:transparentAuthGlobalPBKDF2Salt withError:error]];
    // TODO: Utilize Error
    /*
     * Set the transparent auth global PBKDF2 round estimate
     */
    
    // How many rounds to use so that it takes 0.05s (50ms) ?
    NSString *testTransparentAuthOutput = @"TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0";
    int transparentAuthEstimateRounds = [[Sentegrity_Crypto sharedCrypto] benchmarkPBKDF2UsingExampleString:testTransparentAuthOutput forTimeInMS:10 withError:error];
    // TODO: Utilize Error
    [self.currentStartupStore setTransparentAuthPBKDF2rounds:transparentAuthEstimateRounds];
    
    /*
     * Set the user auth PBKDF2 round estimate
     */
    
    // How many rounds to use so that it takes 0.05s (50ms) ?
    NSString *testUserPassword = @"abcdef";
    int userEstimateRounds = [[Sentegrity_Crypto sharedCrypto] benchmarkPBKDF2UsingExampleString:testUserPassword forTimeInMS:50 withError:error];
    // TODO: Utilize Error
    [self.currentStartupStore setUserKeyPBKDF2rounds:userEstimateRounds];
    
    /*
     * Set the OS Version
     */
    [self.currentStartupStore setLastOSVersion:[[UIDevice currentDevice] systemVersion]];
    
    /*
     * First time user provisoning:
     * Prompt for user password (simulated for demo)
     * Generated the one and only permanent master key for secure container user
     * Encrypt master with user key
     * Store user key encrypter master key blob
     */
    
    // Prompt for password (simulated for demo)
    NSString *userPassword = @"user";
    
    // Generate and store user key hash and user key encrypted master key blob
    BOOL createdUserAndMasterKey = [[Sentegrity_Crypto sharedCrypto] provisionNewUserKeyAndCreateMasterKeyWithPassword:userPassword withError:error];
    
    // TODO: Utilize Error
    
    if (!createdUserAndMasterKey || createdUserAndMasterKey==NO){
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Error creating new user and master key", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Very startup file and other inputs", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToCreateNewUserAndMasterKey userInfo:errorDetails];
        

    }
    
    // Default values
    [self.currentStartupStore setLastState:@""];
    NSArray *empty = [[NSArray alloc]init];
    [self.currentStartupStore setRunHistoryObjects:empty];
    [self.currentStartupStore setTransparentAuthKeyObjects:empty];
    
    // Save the store
    [self setStartupStoreWithError:error];
    
}

// Set the startup file
- (BOOL)setStartupStoreWithError:(NSError **)error {
    
    // Zero out the error
    error = nil;
    
    // Make sure the class is valid
    if (!self.currentStartupStore || self.currentStartupStore == nil) {
        
        // Startup Class is invalid!
        
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Startup File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Startup Class reference is invalid", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid startup object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Return NO
        return NO;
        
    }
    
    // Save the startup file to disk (as json)
    NSData *data = [self.currentStartupStore JSONData];
 
    // Validate the data
    if (!data || data == nil) {
        
        // Problem parsing to JSON
        
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Startup File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Startup Class reference does not parse to JSON correctly", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid JSON startup object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Return NO
        return NO;
        
    }
    
    // Write the data out to the path
    BOOL outFileWrite = [data writeToFile:[self startupFilePath] options:kNilOptions error:error];
    
    // Validate that the write was successful
    if (!outFileWrite ) {
        
        // Check if error passed back was empty
        if (!*error || *error == nil) {
            
            // Unable to write out startup file!!
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Write Startup file", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to write startup file", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing correct store to write out.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToWriteStore userInfo:errorDetails];
            
            // Return NO
            return NO;
            
        }
        
        // Log Error
        NSLog(@"Failed to Write Store: %@", *error);

    }
    
    // Return Success
    return YES;
    
}

// Startup File Path
- (NSString *)startupFilePath {
    
    // Get the documents directory paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Get the path to our startup file
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, kStartupFileName];
}

#pragma mark - Override Setter

// Override set current state
- (void)setCurrentState:(NSString *)currentState {
    
    // Create an error
    NSError *error;
    
    // Get the startup instance (from file)
    Sentegrity_Startup *startup = [self currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        // Log it
        NSLog(@"Setting Startup File Current State Failed");
        
        // Return
        return;
        
    }
    
    // Set the last state
    [startup setLastState:currentState];
    
    // Set the variable as well
    _currentState = currentState;
    
    // Save the startup file
    //[self setStartupStoreWithError:&error];
    
    // Validate no errors
    if (error || error != nil) {
        
        // Log it
        NSLog(@"Setting Startup File Failed");
        
        // Return
        return;
        
    }
    
}

- (void)setStartupFileWithComputationResult:(Sentegrity_TrustScore_Computation *)computationResults withError:(NSError **)error {
    
    // Get our startup file
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
        
    } // Done validating no errors
    
    // Create a run history object for this run
    Sentegrity_History_Object *runHistoryObject = [[Sentegrity_History_Object alloc] init];
    
    // Scores
    [runHistoryObject setDeviceScore:computationResults.systemScore];
    [runHistoryObject setTrustScore:computationResults.deviceScore];
    [runHistoryObject setUserScore:computationResults.userScore];
    [runHistoryObject setTimestamp:[NSDate date]];
    
    // Text issues from GUI
    [runHistoryObject setSystemIssues:computationResults.systemIssues];
    [runHistoryObject setUserIssues:computationResults.userIssues];
    
    // Sub category results (e.g., WiFi, Celluar, Motion, etc)
    [runHistoryObject setSystemAnalysisResults:computationResults.systemAnalysisResults];
    [runHistoryObject setUserAnalysisResults:computationResults.userAnalysisResults];
    
    // Results and status codes
    [runHistoryObject setCoreDetectionResult:computationResults.coreDetectionResult];
    [runHistoryObject setPreAuthenticationAction:computationResults.preAuthenticationAction];
    [runHistoryObject setPostAuthenticationAction:computationResults.postAuthenticationAction];
    [runHistoryObject setAuthenticationResult:computationResults.authenticationResult];
    
    // Check if the startup file already has an array of history objects
    if (!startup.runHistoryObjects || startup.runHistoryObjects.count < 1) {
        
        // Create a new array
        NSArray *historyArray = [NSArray arrayWithObject:runHistoryObject];
        
        // Set the array to the startup file
        [startup setRunHistoryObjects:historyArray];
        
    } else {
        
        // Startup History is an array with objects in it already
        NSArray *historyArray = [[startup runHistoryObjects] arrayByAddingObject:runHistoryObject];
        
        // Set the array to the startup file
        [startup setRunHistoryObjects:historyArray];
        
    }
    
    // Save all updates to the startup file, this includes version check during baseline analysis, any transparent auth changes, run history
    if (![[Sentegrity_Startup_Store sharedStartupStore] setStartupStoreWithError:error]) {
        
        // TODO: Something wonky here - Check for errors
        if (*error || *error != nil || *error != NULL) {
            
            // Unable to set startup file!
            
            // Log Error
            NSLog(@"Failed to set startup file: %@", [(NSError *)*error debugDescription]);
            
        } else {
            
            // Failed to set startup file for unknown reason
            NSLog(@"Fialed to set startup file for unknown reasons");
            
        }
        
    }

}

@end