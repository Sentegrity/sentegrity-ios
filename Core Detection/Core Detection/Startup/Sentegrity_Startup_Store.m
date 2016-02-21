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
- (Sentegrity_Startup *)getStartupFile:(NSError **)error {
    
    // Check if the startup file exists
    
    // Zero out the error
    *error = nil;
    
    // Print out the startup file path
    //NSLog(@"Startup File Path: %@", filePath);
    
    // Check if the startup file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self startupFilePath]]) {
        
        // Startup file does NOT exist (yet)
        Sentegrity_Startup *startup = [[Sentegrity_Startup alloc] init];
        
        // Set the salts
        [startup setUserSalt:kDefaultUserSalt];
        [startup setDeviceSalt:kDefaultDeviceSalt];
        
        // Set the OS Version
        [startup setLastOSVersion:[[UIDevice currentDevice] systemVersion]];
        
        // Save the file
        [self setStartupFile:startup withError:error];
        
        // Check for errors
        if (*error || *error != nil || !startup || startup == nil) {
            
            // Encountered an error saving the file
            return nil;
            
        }
        
        // Saved the file, no errors, return the reference
        return startup;
        
    } else {
        
        // Startup file does exist
        
        // Get the contents of the file
        NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self startupFilePath]]
                                                                   options:NSJSONReadingMutableContainers error:error];
        
        // Check the policy plist
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
        DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[Sentegrity_History class] forAttribute:kRunHistory onClass:[Sentegrity_Startup class]];
        
        // Set up the parser configuration for json parsing
        DCParserConfiguration *config = [DCParserConfiguration configuration];
        [config addArrayMapper:mapper];
        
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
        return startup;
        
    }
    
    // Not found
    return nil;
}

// Set the startup file
- (void)setStartupFile:(Sentegrity_Startup *)startup withError:(NSError **)error {
    
    // Zero out the error
    *error = nil;
    
    // Make sure the class is valid
    if (!startup || startup == nil) {
        
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
    NSData *data = [startup JSONData];
    
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
    Sentegrity_Startup *startup = [self getStartupFile:&error];
    
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
    [self setStartupFile:startup withError:&error];
    
    // Validate no errors
    if (error || error != nil) {
        
        // Log it
        NSLog(@"Setting Startup File Failed");
        
        // Return
        return;
        
    }
    
}

@end