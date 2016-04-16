//
//  Sentegrity_Assertion_Storage.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

//TODO: Find a good way to save and retrieve the global store security token

#import "Sentegrity_TrustFactor_Storage.h"
#import "Sentegrity_Constants.h"

// DCObjectMapping
#import "DCKeyValueObjectMapping.h"
#import "DCArrayMapping.h"
#import "DCParserConfiguration.h"
#import "NSObject+ObjectMap.h"

@implementation Sentegrity_TrustFactor_Storage

// Singleton method
+ (id)sharedStorage {
    static Sentegrity_TrustFactor_Storage *sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [[self alloc] init];
    });
    return sharedStorage;
}



// Assertion Store File Path
- (NSString *)assertionStoreFilePath {
    
    // Get the documents directory paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Get the path to our startup file
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, kAssertionStoreFileName];
}



// Get the startup file
- (Sentegrity_Assertion_Store *)getAssertionStoreWithError:(NSError **)error {
    
    // Check if the assertion file exists
    
    // Zero out the error
    error = nil;
    
    // Print out the assertion file path
    //NSLog(@"Assertion File Path: %@", filePath);
    
    // Did we already create a startup store instance of the object?
    if(self.currentStore == nil || !self.currentStore){
        
        // Check if the assertion file exists, if not we will create a new one
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self assertionStoreFilePath]]) {
            
            // Startup file does NOT exist (yet)
            Sentegrity_Assertion_Store *assertionStore = [[Sentegrity_Assertion_Store alloc] init];
            
            // Set the current store
            self.currentStore = assertionStore;
            
            // Save the file
            [self setAssertionStoreWithError:error];
            
            // Check for errors
            if (*error || *error != nil) {
                
                // Encountered an error saving the file
                return nil;
                
            }
            
            // Saved the file, no errors, return the reference
            return assertionStore;
            
        } else {
            
            // Assertion file does exist, just not yet parsed
            
            // Get the contents of the file
            NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self assertionStoreFilePath]]
                                                                       options:NSJSONReadingMutableContainers error:error];
            
            // Check the parsed startup file
            if (jsonParsed.count < 1 || jsonParsed == nil) {
                
                // Check if the error is set
                if (!*error || *error == nil) {
                    
                    // Assertion store came back empty, and so did the error
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Parse Assertion Store Failed", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to parse assertion store, unknown error", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try fixing the format of the assertion store", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnknownError userInfo:errorDetails];
                    
                    // Log it
                    NSLog(@"Parse Assertion Store Failed: %@", errorDetails);
                    
                    // Don't return anything
                    return nil;
                }
            }
            
                // Map Sentegrity Assertion Store Class
            DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[Sentegrity_Stored_TrustFactor_Object class] forAttribute:kStoredTrustFactorObjectMapping onClass:[Sentegrity_Assertion_Store class]];
            DCArrayMapping *mapper2 = [DCArrayMapping mapperForClassElements:[Sentegrity_Stored_Assertion class] forAttribute:kAssertionObjectMapping onClass:[Sentegrity_Stored_TrustFactor_Object class]];
                
                // Set up the parser configuration for json parsing
            DCParserConfiguration *config = [DCParserConfiguration configuration];
                [config addArrayMapper:mapper];
                [config addArrayMapper:mapper2];
                
                // Set up the date parsing configuration
                config.datePattern = OMDateFormat;
                
                // Set the parser and include the configuration
                DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[Sentegrity_Assertion_Store class] andConfiguration:config];
                
                // Get the policy from the parsing
                Sentegrity_Assertion_Store *store = [parser parseDictionary:jsonParsed];

            
            // Make sure the class is valid
            if (!store || store == nil) {
                
                // Assertion store Class is invalid!
                
                // Assertion store came back empty, and so did the error
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Parse Assertion Store Failed", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to parse assertion store, unknown error", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try fixing the format of the assertion store", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnknownError userInfo:errorDetails];
                
                // Log it
                NSLog(@"Parse Assertion Store Failed: %@", errorDetails);
                
                // Don't return anything
                return nil;

                
            }
            
            // Return the object
            self.currentStore = store;
            return self.currentStore;
            
        }
        
        
    }
    else{
        return self.currentStore;
    }
    
    // Not found
    return nil;
}


    
// Set the assertion file
- (void)setAssertionStoreWithError:(NSError **)error {
    
    // Zero out the error
    error = nil;
    
    // Make sure the class is valid
    if (!self.currentStore || self.currentStore == nil) {
        
        // Startup Class is invalid!
        
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Assertion Store File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Assertion Store Class reference is invalid", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid assertion store object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
    }
    
    // Save the assertion store file to disk (as json)
    NSData *data = [self.currentStore JSONData];
    
    // Validate the data
    if (!data || data == nil) {
        
        
        // No valid assertion store
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Assertion Store File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Assertion store class reference does not parse to JSON correctly", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid JSON assertion store object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
    }
    
    // Write the data out to the path
    BOOL outFileWrite = [data writeToFile:[self assertionStoreFilePath] options:kNilOptions error:error];
    
    // Validate that the write was successful
    if (!outFileWrite ) {
        
        // Check if error passed back was empty
        if (!*error || *error == nil) {
            
            // Unable to write out startup file!!
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Write Assertion Store file", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to write assertion file", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing correct assertion store to write out.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToWriteStore userInfo:errorDetails];
            
        }
        
        // Log Error
        NSLog(@"Failed to Write Store: %@", *error);
        
    }
    
}



@end
