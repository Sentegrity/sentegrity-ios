//
//  Sentegrity_Parser.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Import files
#import "Sentegrity_Policy_Parser.h"
#import "Sentegrity_Policy.h"
#import "Sentegrity_DNEModifiers.h"
#import "Sentegrity_Classification.h"
#import "Sentegrity_Constants.h"
#import "Sentegrity_Subclassification.h"
#import "Sentegrity_TrustFactor.h"
#import "Sentegrity_Constants.h"

#import "DCKeyValueObjectMapping.h"
#import "DCArrayMapping.h"
#import "DCParserConfiguration.h"

#import "NSObject+ObjectMap.h"

@implementation Sentegrity_Policy_Parser

// Singleton instance
+ (id)sharedPolicy {
    static Sentegrity_Policy_Parser *sharedPolicy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPolicy = [[self alloc] init];
    });
    return sharedPolicy;
}


// Get the startup file
- (Sentegrity_Policy *)getPolicy:(NSError **)error {
    
    // Check if the startup file exists
    
    // Zero out the error
    *error = nil;
    
    // Print out the startup file path
    //NSLog(@"Startup File Path: %@", filePath);
    
    // Did we already create a startup store instance of the object?
    if(self.currentPolicy == nil || !self.currentPolicy){
        
        NSString *policyPath = [self policyFilePath];
        // Validate the policy path provided
        if (!policyPath || policyPath == nil) {
            // Invalid policy path provided
            
            // Block callback is nil (something is really wrong)
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Parse Policy Failed", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An invalid policy path was provided", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid policy path", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidPolicyPath userInfo:errorDetails];
            
            // Log it
            NSLog(@"Parse Policy Failed: %@", errorDetails);
            
            return nil;
        }
        
        
        // Policy file exists but not yet parsed

        // Get the policy
        Sentegrity_Policy *policy = [self parsePolicyJSONWithError:error];
        
        // Validate the policy
        if ((!policy || policy == nil) && *error != nil) {
            
            // Unable to parse the policy, but passing the error up
            return policy;
            
        } else if ((!policy || policy == nil) && *error == nil) {
            
            // Policy came back empty, and so did the error
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Parse Policy Failed", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to parse policy, unknown error", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid policy path and valid policy", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnknownError userInfo:errorDetails];
            
            // Log it
            NSLog(@"Parse Poilicy Failed: %@", errorDetails);
            
            // Don't return anything
            return nil;
        }
        
        return self.currentPolicy;
        
    }
    else{
        return self.currentPolicy;
    }
}


// Policy File Path
- (NSString *)policyFilePath {
    
    // Get the documents directory paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Get the path to our startup file
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, kPolicyFileName];
}

// Parse a policy json with a valid path
- (Sentegrity_Policy *)parsePolicyJSONWithError:(NSError **)error {
    
    // Load the json
    NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self policyFilePath]]
                                                               options:NSJSONReadingMutableContainers error:error];
    
    // Check the parsed startup file
    if (jsonParsed.count < 1 || jsonParsed == nil) {
        
        // Check if the error is set
        if (!*error || *error == nil) {
            
            // No such file
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSFileReadCorruptFileError
                                     userInfo:@{@"More Information": @"Policy File JSON may not be formatted correctly"}];
        }
        
        // Fail
        NSLog(@"Policy File JSON formatting problem");
        
        // Return nothing
        return nil;
    }
    // Map DNEModifiers
    DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[Sentegrity_DNEModifiers class] forAttribute:kDNEModifiers onClass:[Sentegrity_Policy class]];
    // Map Classifications
    DCArrayMapping *mapper2 = [DCArrayMapping mapperForClassElements:[Sentegrity_Classification class] forAttribute:kClassifications onClass:[Sentegrity_Policy class]];
    // Map Subclassifications
    DCArrayMapping *mapper3 = [DCArrayMapping mapperForClassElements:[Sentegrity_Subclassification class] forAttribute:kSubClassifications onClass:[Sentegrity_Policy class]];
    // Map TrustFactors
    DCArrayMapping *mapper4 = [DCArrayMapping mapperForClassElements:[Sentegrity_TrustFactor class] forAttribute:kTrustFactors onClass:[Sentegrity_Policy class]];
    
    // Map Classifications id
    DCObjectMapping *idToIdentificationClassifications = [DCObjectMapping mapKeyPath:@"id" toAttribute:@"identification" onClass:[Sentegrity_Classification class]];
    DCObjectMapping *idToIdentificationSubClassifications = [DCObjectMapping mapKeyPath:@"id" toAttribute:@"identification" onClass:[Sentegrity_Subclassification class]];
    DCObjectMapping *idToIdentificationTrustFactors = [DCObjectMapping mapKeyPath:@"id" toAttribute:@"identification" onClass:[Sentegrity_TrustFactor class]];
    
    // Set up the parser configuration for json parsing
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    [config addArrayMapper:mapper];
    [config addArrayMapper:mapper2];
    [config addArrayMapper:mapper3];
    [config addArrayMapper:mapper4];
    [config addObjectMapping:idToIdentificationClassifications];
    [config addObjectMapping:idToIdentificationSubClassifications];
    [config addObjectMapping:idToIdentificationTrustFactors];
    
    // Set up the date parsing configuration
    config.datePattern = OMDateFormat;
    
    // Set the parser and include the configuration
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[Sentegrity_Policy class] andConfiguration:config];
    
    // Get the policy from the parsing
    Sentegrity_Policy *policy = [parser parseDictionary:jsonParsed];

    
    // Make sure the class is valid
    if (!policy || policy == nil) {
        
        // Policy Class is invalid!
        
        // No valid policy provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Getting policy file Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Policy Class file is invalid", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check policy file and retry", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupFile userInfo:errorDetails];
        
    }
    
    // Return the object
    self.currentPolicy= policy;
    return self.currentPolicy;

}




@end
