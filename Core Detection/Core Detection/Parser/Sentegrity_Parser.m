//
//  Sentegrity_Parser.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Import files
#import "Sentegrity_Parser.h"
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

@interface Sentegrity_Parser()

// Check if a file exists
- (BOOL)fileExists:(NSURL *)filePathURL;

@end

@implementation Sentegrity_Parser

// Parse a policy plist with a valid path
- (id)parsePolicyPlistWithPath:(NSURL *)filePathURL withError:(NSError **)error {
    // First, check if the file exists
    if (![self fileExists:filePathURL]) {
        // Check if the error is set
        if (error) {
            // No such file
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSFileNoSuchFileError
                                     userInfo:nil];
        }
        // Fail out
        return nil;
    }
    
    // Load the plist
    NSDictionary *policyPlist = [[NSDictionary alloc] initWithContentsOfFile:filePathURL.path];
    
    // Check the policy plist
    if (policyPlist.count < 1 || policyPlist == nil) {
        // Check if the error is set
        if (error) {
            // No such file
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSFileReadCorruptFileError
                                     userInfo:nil];
        }
        // Fail
        return nil;
    }
    
    // Parse the plist and put it into the sentegrity policy class
    Sentegrity_Policy *policy = [[Sentegrity_Policy alloc] init];
    [policy setPolicyID:[policyPlist valueForKey:kPolicyID]];
    [policy setRevision:[policyPlist valueForKey:kRevision]];
    [policy setUserThreshold:[policyPlist valueForKey:kUserThreshold]];
    [policy setSystemThreshold:[policyPlist valueForKey:kSystemThreshold]];
    [policy setContactURL:[policyPlist valueForKey:KContactURL]];
    [policy setContactPhone:[policyPlist valueForKey:KContactPhone]];
    [policy setContactEmail:[policyPlist valueForKey:KContactEmail]];
    
    // Get the sub-dictionary of the dnemodifiers
    NSDictionary *modifiers = [NSDictionary dictionaryWithDictionary:[policyPlist valueForKey:kDNEModifiers]];
    
    // Set up our modifier
    Sentegrity_DNEModifiers *dne = [[Sentegrity_DNEModifiers alloc] init];
    
    // DNEModifiers
    [dne setUnauthorized:[modifiers valueForKey:kUnauthorized]];
    [dne setUnsupported:[modifiers valueForKey:kUnsupported]];
    [dne setUnavailable:[modifiers valueForKey:kUnavailable]];
    [dne setDisabled:[modifiers valueForKey:kDisabled]];
    [dne setExpired:[modifiers valueForKey:kExpired]];
    [dne setError:[modifiers valueForKey:kError]];
    
    // Set the DNEModifiers
    [policy setDNEModifiers:dne];
    
    // Classifications
    NSArray *classifications = [[NSArray alloc] initWithArray:[policyPlist valueForKey:kClassifications]];
    NSMutableArray *classificationsArray = [[NSMutableArray alloc] initWithCapacity:classifications.count];
    
    // Validation
    if (classifications && classifications.count > 0) {
        // Run through all the classifications
        for (NSDictionary *classifiers in classifications) {
            Sentegrity_Classification *classer = [[Sentegrity_Classification alloc] init];
            [classer setIdentification:[classifiers objectForKey:kIdentification]];
            [classer setType:[classifiers objectForKey:kType]];
            [classer setComputationMethod:[classifiers objectForKey:kComputationMethod]];
            [classer setName:[classifiers objectForKey:kName]];
            [classer setDesc:[classifiers objectForKey:kDesc]];
            [classer setProtectModeAction:[classifiers objectForKey:kProtectModeAction]];
            [classer setProtectModeMessage: [classifiers objectForKey:kProtectModeMessage]];
            
            // Add it to the array
            [classificationsArray addObject:classer];
        }
        
        // Set the Classifications
        [policy setClassifications:classificationsArray];
    }
    
    // Subclassifications
    NSArray *subclassifications = [[NSArray alloc] initWithArray:[policyPlist valueForKey:kSubClassifications]];
    NSMutableArray *subclassificationsArray = [[NSMutableArray alloc] initWithCapacity:subclassifications.count];
    
    // Validation
    if (subclassifications && subclassifications.count > 0) {
        
        // Run through all the subclassifications
        for (NSDictionary *subclassifiers in subclassifications){
            Sentegrity_Subclassification *subclasser = [[Sentegrity_Subclassification alloc] init];
            [subclasser setIdentification: [subclassifiers objectForKey:kSCIdentification]];
            [subclasser setName: [subclassifiers objectForKey:kSCName]];
            [subclasser setDneUnauthorized:[subclassifiers objectForKey:kSCDNEUnauthorized]];
            [subclasser setDneUnsupported:[subclassifiers objectForKey:kSCDNEUnsupported]];
            [subclasser setDneUnavailable:[subclassifiers objectForKey:kSCDNEUnavailable]];
            [subclasser setDneDisabled:[subclassifiers objectForKey:kSCDNEDisabled]];
            [subclasser setDneNoData:[subclassifiers objectForKey:kSCDNENoData]];
            [subclasser setDneExpired:[subclassifiers objectForKey:kSCDNEExpired]];
            [subclasser setWeight:[subclassifiers objectForKey:kSCWeight]];
            
            // Add it to the array
            [subclassificationsArray addObject:subclasser];
        }
        
        // Set the Subclassifications
        [policy setSubclassifications:subclassificationsArray];
    }
    
    // TrustFactors
    NSArray *trustFactors = [[NSArray alloc] initWithArray:[policyPlist valueForKey:kTrustFactors]];
    NSMutableArray *trustFactorsArray = [[NSMutableArray alloc] initWithCapacity:trustFactors.count];
    
    // Validation
    if (trustFactors && trustFactors.count > 0) {
        // Run through all the TrustFactors
        for(NSDictionary *trustFactorClassifier in trustFactors){
            Sentegrity_TrustFactor *trustFactorClasser = [[Sentegrity_TrustFactor alloc] init];
            [trustFactorClasser setIdentification:[trustFactorClassifier objectForKey:kTFIdentification]];
            [trustFactorClasser setNotFoundIssueMessage:[trustFactorClassifier objectForKey:kTFNotFoundIssueMessage]];
            [trustFactorClasser setNotFoundSuggestionMessage:[trustFactorClassifier objectForKey:kTFNotFoundSuggestionMessage]];
            [trustFactorClasser setLowConfidenceIssueMessage:[trustFactorClassifier objectForKey:kTFLowConfidenceIssueMessage]];
            [trustFactorClasser setLowConfidenceSuggestionMessage:[trustFactorClassifier objectForKey:kTFLowConfidenceSuggestionMessage]];
            [trustFactorClasser setClassID:[trustFactorClassifier objectForKey:kTFClassID]];
            [trustFactorClasser setSubClassID:[trustFactorClassifier objectForKey:kTFSubclassID]];
            [trustFactorClasser setName:[trustFactorClassifier objectForKey:kTFName]];
            [trustFactorClasser setWeight:[trustFactorClassifier objectForKey:kTFWeight]];
            [trustFactorClasser setDnePenalty:[trustFactorClassifier objectForKey:kTFDNEPenalty]];
            [trustFactorClasser setPartialWeight:[trustFactorClassifier objectForKey:kTFPartialWeight]];
            [trustFactorClasser setLearnMode:[trustFactorClassifier objectForKey:kTFLearnMode]];
            [trustFactorClasser setLearnTime:[trustFactorClassifier objectForKey:kTFLearnTime]];
            [trustFactorClasser setLearnAssertionCount:[trustFactorClassifier objectForKey:kTFLearnAssertionCount]];
            [trustFactorClasser setLearnRunCount:[trustFactorClassifier objectForKey:kTFLearnRunCount]];
            [trustFactorClasser setDecayMode:[trustFactorClassifier objectForKey:kTFDecayMode]];
            [trustFactorClasser setDecayMetric:[trustFactorClassifier objectForKey:kTFDecayMetric]];
            [trustFactorClasser setDispatch:[trustFactorClassifier objectForKey:kTFDispatch]];
            [trustFactorClasser setImplementation:[trustFactorClassifier objectForKey:kTFImplementation]];
            [trustFactorClasser setWhitelistable:[trustFactorClassifier objectForKey:kTFWhitelistable]];
            [trustFactorClasser setPrivateAPI:[trustFactorClassifier objectForKey:kTFPrivateAPI]];
            [trustFactorClasser setPayload:[trustFactorClassifier objectForKey:kTFPayload]];
            
            // Add it to the array
            [trustFactorsArray addObject:trustFactorClasser];
        }
        
        // Set the TrustFactors
        [policy setTrustFactors:trustFactorsArray];
    }
    
    //    // Classifications Output
    //    for (Sentegrity_Classifications *classObject in classificationsArray) {
    //        NSLog(@"Classification ID: %@", classObject.identification);
    //        NSLog(@"Classification Name: %@", classObject.name);
    //        NSLog(@"Classification Weight: %@", classObject.weight);
    //        NSLog(@"Classification ProtectMode: %@", classObject.protectMode);
    //        NSLog(@"Classification ProtectViolationName: %@", classObject.protectViolationName);
    //        NSLog(@"Classification ProtectInfo: %@", classObject.protectInfo);
    //        NSLog(@"Classification ContactPhone: %@", classObject.contactPhone);
    //        NSLog(@"Classification ContactURL: %@", classObject.contactURL);
    //        NSLog(@"Classification ContactEmail: %@", classObject.contactEmail);
    //        NSLog(@" ");
    //
    //    }
    //
    //
    //    // Subclassifications Output
    //    for(Sentegrity_Subclassifications *classObject in subclassificationsArray){
    //        NSLog(@"Subclassification ID: %@", classObject.identification);
    //        NSLog(@"Subclassification ClassID: %@", classObject.classID);
    //        NSLog(@"Subclassification Name: %@", classObject.name);
    //        NSLog(@"Subclassification DNEMessage: %@", classObject.dneMessage);
    //        NSLog(@"Subclassification Weight: %@", classObject.weight);
    //        NSLog(@" ");
    //    }
    //
    //    //TrustFactors Output
    //    for(Sentegrity_TrustFactors *classObject in trustFactorsArray){
    //        NSLog(@"TrustFactors ID: %@", classObject.identification);
    //        NSLog(@"TrustFactors Desc: %@", classObject.desc);
    //        NSLog(@"TrustFactors ClassID: %@", classObject.classID);
    //        NSLog(@"TrustFactors SubclassID: %@", classObject.subClassID);
    //        NSLog(@"TrustFactors Priority: %@", classObject.priority);
    //        NSLog(@"TrustFactors Name: %@", classObject.name);
    //        NSLog(@"TrustFactors Weight: %@", classObject.weight);
    //        NSLog(@"TrustFactors DNEPenalty: %@", classObject.dnePenalty);
    //        NSLog(@"TrustFactors LearnMode: %@", classObject.learnMode);
    //        NSLog(@"TrustFactors LearnTime: %@", classObject.learnTime);
    //        NSLog(@"TrustFactors LearnAssertionCount: %@", classObject.learnAssertionCount);
    //        NSLog(@"TrustFactors LearnRunCount: %@", classObject.learnRunCount);
    //        NSLog(@"TrustFactors Managed: %@", classObject.managed);
    //        NSLog(@"TrustFactors Local: %@", classObject.local);
    //        NSLog(@"TrustFactors History: %@", classObject.history);
    //        NSLog(@"TrustFactors Dispatch: %@", classObject.dispatch);
    //        NSLog(@"TrustFactors Implementation: %@", classObject.implementation);
    //        NSLog(@"TrustFactors Baseline: %@", classObject.baseline);
    //        NSLog(@"TrustFactors Payload: %@", classObject.payload);
    //        NSLog(@" ");
    //    }
    
    // Return the policy class
    return policy;
}

// Parse a policy json with a valid path
- (id)parsePolicyJSONWithPath:(NSURL *)filePathURL withError:(NSError **)error {
    
    // Load the json
    NSError *error2;
    NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePathURL.path]
                                                               options:NSJSONReadingMutableContainers error:&error2];
    
    // Check the policy plist
    if (jsonParsed.count < 1 || jsonParsed == nil) {
        
        // Check if the error is set
        if (error2) {
            // No such file
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSFileReadCorruptFileError
                                     userInfo:@{@"More Information": @"JSON may not be formatted correctly"}];
        }
        
        // Fail
        NSLog(@"JSON format problem");
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
    
    // Return the policy
    return policy;
}

// Parse the assertion store with the store path
- (Sentegrity_Assertion_Store *)parseAssertionStoreWithPath:(NSURL *)assertionStorePathURL withError:(NSError **)error {
    
    // First, check if the file exists
    if (![self fileExists:assertionStorePathURL]) {
        // Check if the error is set
        if (error) {
            // No such file
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSFileNoSuchFileError
                                     userInfo:nil];
        }
        // Fail out
        return nil;
    }
    
    // Load the store
    // BETA2: Nick's addtion = Store is assumed to be JSON
    NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:assertionStorePathURL.path]
                                                               options:NSJSONReadingMutableContainers error:error];
    
    // Check the parsed store
    if (jsonParsed.count < 1 || jsonParsed == nil) {
        // Fail
        return nil;
    }
    
    // BETA2: Nick's Addtions = Added additional JSON array mapping to map stored trustfactor object array object parsing to assertion storage
    
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
    
    // Return the store
    return store;
}

#pragma mark - Private Methods

// Check if a file exists at a given path
- (BOOL)fileExists:(NSURL *)filePathURL {
    
    // Check if the file exists
    return [[NSFileManager defaultManager] fileExistsAtPath:filePathURL.path];
}


@end
