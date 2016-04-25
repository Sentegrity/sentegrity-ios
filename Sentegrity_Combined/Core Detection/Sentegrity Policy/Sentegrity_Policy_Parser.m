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


// Get the policy file
- (Sentegrity_Policy *)getPolicy:(NSError **)error {
    
    
    // Did we already create a policy store instance of the object?
    if(self.currentPolicy == nil || !self.currentPolicy){
        
        //first we need to check for policy in the Documents folder
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self policyFilePathInDocumentsFolder]]) {

            //there is no policy in documents folder (this is first run of the app), let's create new policy from Main Bundle
            Sentegrity_Policy *policy = [self loadPolicyFromMainBundle:error];
            
            if (*error) {
                self.currentPolicy = nil;
                return nil;
            }
            
            //save policy in documents folder
            if([self saveNewPolicy:policy withError:error]) {
                //succesfully stored policy
                self.currentPolicy = policy;
            }
            
            if (*error) {
                self.currentPolicy = nil;
                return nil;
            }
            
            //return new policy
            return self.currentPolicy;
        }
        
        
        else {
            //we already have policy in documents folder, now just load it
            Sentegrity_Policy *policy = [self loadPolicyWithPath:[self policyFilePathInDocumentsFolder] andError:error];
            
            // Validate the policy
            if ((!policy || policy == nil) && *error != nil) {
                
                // Unable to parse the policy, but passing the error up
                return nil;
                
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
                
                return nil;
            }
            else {
                //policy succesfully loaded
                self.currentPolicy = policy;
                return self.currentPolicy;
            }
        }
    }
    
    else {
        // aready loaded policy
        return self.currentPolicy;
    }
}



- (Sentegrity_Policy *)loadPolicyFromMainBundle:(NSError **) error {

    // Get the policy path
    NSURL *policyPath = [self policyFilePathInMainBundle];
    
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
        
        // Return nil
        return nil;
    }
    
    
    // Policy file exists but not yet parsed
    
    // Get the policy
    Sentegrity_Policy *policy = [self loadPolicyWithPath:[self policyFilePathInMainBundle].path andError:error];
    
    // Validate the policy
    if ((!policy || policy == nil) && *error != nil) {
        
        // Unable to parse the policy, but passing the error up
        return nil;
        
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
        
        return nil;
    }
    else {
        //policy succesfully loaded
        return policy;
    }

}

// save policy file
- (BOOL)saveNewPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error;
 {
    
    // Make sure the class is valid
    if (!policy || policy == nil) {
        
        
        // No valid policy provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Policy File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Policy Class reference is invalid", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid policy object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidPolicyInstance userInfo:errorDetails];
        
        // Return NO
        return NO;
        
    }
    
    // Save the policy file to disk (as json)
    NSData *data = [policy JSONData];
    
    // Validate the data
    if (!data || data == nil) {
        
        // Problem parsing to JSON
        
        // No valid policy provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Policy File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Policy Class reference does not parse to JSON correctly", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid JSON policy object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidPolicyInstance userInfo:errorDetails];
        
        // Return NO
        return NO;
        
    }
    
    // Write the data out to the path
    BOOL outFileWrite = [data writeToFile:[self policyFilePathInDocumentsFolder] options:kNilOptions error:error];
    
    // Validate that the write was successful
    if (!outFileWrite ) {
        
        // Check if error passed back was empty
        if (!*error || *error == nil) {
            
            // Unable to write out policy file!!
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Write Policy file", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to write policy file", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing correct store to write out.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToWriteStore userInfo:errorDetails];
            
            // Return NO
            return NO;
            
        }
        
        // Log Error
        NSLog(@"Failed to Write Store: %@", *error);
        
        return NO;
        
    }
    
    // return Success
    return YES;
    
}
    
    
    
// Policy File Path
- (NSURL *)policyFilePathInMainBundle {
    
    // Get the bundle
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:kCoreDetectionBundle withExtension:kCoreDetectionBundleExtension]];

    // Get the file URL path
    NSURL *policyPath = [NSURL fileURLWithPath:[bundle pathForResource:kCDBPolicy ofType:@""]];
    
    // Validate the policy path provided
    if (![[NSFileManager defaultManager] fileExistsAtPath:[policyPath path]]) {
        // Unable to find the policy path
        NSLog(@"Unable to find the policy path!");
        return nil;
    }
    
    // Return the policy path
    return policyPath;
}

- (NSString *)policyFilePathInDocumentsFolder {
    
    // Get the documents directory paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Get the path to our policy file
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, kCDBPolicy];
}



- (Sentegrity_Policy *) loadPolicyWithPath: (NSString *) path andError: (NSError **) error {
    
    // Load JSON object
    NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:error];
    
    // parse json object to Sentegrity_Policy
    return [self parsePolicyJSONobject:jsonParsed withError:error];
}


// Parse a policy json
- (Sentegrity_Policy *)parsePolicyJSONobject:(NSDictionary *) jsonParsed withError:(NSError **)error {
    
    // Check the parsed policy file
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
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidPolicyFile userInfo:errorDetails];
        
    }
    
    // Return the object
    return policy;

}


@end
