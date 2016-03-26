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
    if(self.currentStore == nil || !self.currentStore){
        
        // Check if the startup file exists, if not we will create a new one
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self startupFilePath]]) {
            
            // Startup file does NOT exist (yet)
            Sentegrity_Startup *startup = [self createNewStatupFile];

            // Set the current store
            self.currentStore = startup;
            
            // Save the file
            [self setStartupStoreWithError:error];
            
            // Check for errors
            if (*error || *error != nil) {
                
                // Encountered an error saving the file
                return nil;
                
            }
            
            // Saved the file, no errors, return the reference
            return startup;
            
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
            self.currentStore = startup;
            return self.currentStore;
            
        }

        
    }
    else{
        return self.currentStore;
    }
    
    // Not found
    return nil;
}


// Create a new startup file
- (Sentegrity_Startup *)createNewStatupFile {
    
    // Startup file does NOT exist (yet)
    Sentegrity_Startup *startup = [[Sentegrity_Startup alloc] init];
    
    /*
     * Set first time defaults for the application
     */
    
    
    /*
     * Set device salt
     */
    NSData *deviceSaltData = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
    [startup setDeviceSaltString:[[Sentegrity_Crypto sharedCrypto] convertDataToString:deviceSaltData]];
    
    /*
     * Set the user key salt
     */
    NSData *userKeySaltData = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
    NSString *userSaltString = [[Sentegrity_Crypto sharedCrypto] convertDataToString:userKeySaltData];
    [startup setUserKeySaltString:userSaltString];
    
    /*
     * Set the transparent auth global PBKDF2 salt (used for all PBKDF2 transparent key hashes)
     */
    NSData *transparentAuthGlobalPBKDF2Salt = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
    [startup setTransparentAuthGlobalPBKDF2SaltString:[[Sentegrity_Crypto sharedCrypto] convertDataToString:transparentAuthGlobalPBKDF2Salt]];
    
    /*
     * Set the transparent auth global PBKDF2 round estimate
     */
    
    // How many rounds to use so that it takes 0.1s (100ms) ?
    NSString *testTransparentAuthOutput = @"TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0";
    int transparentAuthEstimateRounds = [[Sentegrity_Crypto sharedCrypto] benchmarkPBKDF2UsingExampleString:testTransparentAuthOutput forTimeInMS:100];
    [startup setTransparentAuthPBKDF2rounds:transparentAuthEstimateRounds];
    
    /*
     * Set the user auth PBKDF2 round estimate
     */
    
    // How many rounds to use so that it takes 0.1s (100ms) ?
    NSString *testUserPassword = @"abcdef";
    int userEstimateRounds = [[Sentegrity_Crypto sharedCrypto] benchmarkPBKDF2UsingExampleString:testTransparentAuthOutput forTimeInMS:100];
    [startup setUserKeyPBKDF2rounds:userEstimateRounds];
    
    
    /*
     * Set the OS Version
     */
    [startup setLastOSVersion:[[UIDevice currentDevice] systemVersion]];
    
    /*
     * First time user provisoning:
     * Prompt for user password (simulated for demo)
     * Generated the one and only permanent master key for secure container user
     * Encrypt master with user key
     * Store user key encrypter master key blob
     */
    
    // Prompt for password (simulated for demo)
    NSString *userPassword = @"user";
    
    // Generate user key
    
    NSData *userKeyData = [[Sentegrity_Crypto sharedCrypto] createPBKDF2KeyFromString:userPassword withSaltString:userSaltString withRounds:userEstimateRounds];
    
    // Convert user key to sha1 for storage
    NSString *userKeyPBKDF2HashString = [[Sentegrity_Crypto sharedCrypto] createSHA1HashOfData:userKeyData];
    
    // Set user key pbkdf2 hash string
    [startup setUserKeyPBKDF2Hash:userKeyPBKDF2HashString];
    
    
    // Generate a master key
    NSData *newMasterKey = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
    
    NSString *userKeyEncryptedMasterKeyBlobString = [[Sentegrity_Crypto sharedCrypto] provisionNewUserKeyEncryptedMasterKeyUsingUserKeyData:userKeyData withUserSaltData:userKeySaltData withMasterKeyData:newMasterKey];
    
    //Set user key encrypted master key blob
    [startup setUserKeyEncryptedMasterKeyBlobString:userKeyEncryptedMasterKeyBlobString];

    return startup;
    
}

// Set the startup file
- (void)setStartupStoreWithError:(NSError **)error {
    
    // Zero out the error
    *error = nil;
    
    // Make sure the class is valid
    if (!self.currentStore || self.currentStore == nil) {
        
        // Startup Class is invalid!
        
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Startup File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Startup Class reference is invalid", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid startup object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
    }
    
    // Save the startup file to disk (as json)
    NSData *data = [self.currentStore JSONData];
 
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
            
        }
        
        // Log Error
        NSLog(@"Failed to Write Store: %@", *error);

    }
    
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
    Sentegrity_Startup *startup = [self getStartupStore:&error];
    
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
    [self setStartupStoreWithError:&error];
    
    // Validate no errors
    if (error || error != nil) {
        
        // Log it
        NSLog(@"Setting Startup File Failed");
        
        // Return
        return;
        
    }
    
}

- (void)setHistoryFileWithComputationResult:(Sentegrity_TrustScore_Computation *)computationResults withError:(NSError **)startupError{
    
    // Get our startup file
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:startupError];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        // Error out, no trustFactorOutputObject were able to be added
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                       };
        
        // Set the error
        *startupError = [NSError errorWithDomain:@"Sentegrity" code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get startup file: %@", errorDetails);
        
    }
    
    
    // Create a run history object for this run
    Sentegrity_History_Object *runHistoryObject = [[Sentegrity_History_Object alloc] init];
    [runHistoryObject setDeviceScore:computationResults.systemScore];
    [runHistoryObject setTrustScore:computationResults.deviceScore];
    [runHistoryObject setUserScore:computationResults.userScore];
    [runHistoryObject setTimestamp:[NSDate date]];
    
    [runHistoryObject setCoreDetectionResult:computationResults.CoreDetectionResultCode];
    [runHistoryObject setViolationAction:computationResults.violationActionCode];
    [runHistoryObject setAuthenticationAction:computationResults.authenticationActionCode];
    
    [runHistoryObject setSystemIssues:computationResults.systemIssues];
    [runHistoryObject setUserIssues:computationResults.userIssues];
    
    [runHistoryObject setSystemAnalysisResults:computationResults.systemAnalysisResults];
    [runHistoryObject setUserAnalysisResults:computationResults.userAnalysisResults];
    
    [runHistoryObject setViolationAction:computationResults.violationActionCode];
    [runHistoryObject setAuthenticationAction:computationResults.authenticationActionCode];
    [runHistoryObject setAuthenticationResponseCode:computationResults.authenticationResponseCode];
    
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
    [[Sentegrity_Startup_Store sharedStartupStore] setStartupStoreWithError:startupError];
    
    // Check for errors
    if (startupError || startupError != nil) {
        
        // Unable to set startup file!
        
        // Log Error
        //NSLog(@"Failed to set startup file: %@", startupError.debugDescription);
        
        
    }


}

@end