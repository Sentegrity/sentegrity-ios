//
//  Sentegrity_Constants.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#ifndef Sentegrity_Constants_h
#define Sentegrity_Constants_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

// TODO: Beta only
#define kUniqueDeviceID                 @"1234567890"

#pragma mark - Defaults

#define kDefaultAppID                   @"default"
#define kDefaultGlobalStoreName         @"global"
#define kDefaultTrustFactorOutput       @"0"

#pragma mark - Assertion Storage

#define kAssertionStorePath             @"/Assertion_Stores/"
#define kPolicyPath                     @"/Policies/"
#define kResumePath                     @"/Resume/"
#define kStoredTrustFactorObjectMapping @"storedTrustFactorObjects"
#define kAssertionObjectMapping         @"assertionObjects"

#pragma mark - Policy Keys

#define kPolicyID                       @"policyID"
#define kRevision                       @"revision"
#define kUserThreshold                  @"userThreshold"
#define kSystemThreshold                @"systemThreshold"
#define KContactPhone                   @"contactPhone"
#define KContactEmail                   @"contactEmail"
#define KContactURL                     @"contactURL"
#define kDNEModifiers                   @"DNEModifiers"
#define kClassifications                @"classifications"
#define kSubClassifications             @"subclassifications"
#define kTrustFactors                   @"trustFactors"

#pragma mark - DNEModifier Keys

#define kUnauthorized                   @"unauthorized"
#define kUnsupported                    @"unsupported"
#define kUnavailable                    @"unavailable"
#define kDisabled                       @"disabled"
#define kNoData                         @"noData"
#define kExpired                        @"expired"
#define kError                          @"error"


#pragma mark - Classification Keys

#define kIdentification                 @"id"
#define kUser                           @"user"
#define kName                           @"name"
#define kDesc                           @"desc"
#define kWeight                         @"weight"
#define kProtectModeAction              @"protectModeAction"
#define kProtectModeMessage             @"protectModeMessage"


#pragma mark - Subclassification Keys


#define kSCIdentification               @"id"
#define kSCName                         @"name"
#define kSCDNEUnauthorized              @"dneUnauthorized"
#define kSCDNEUnsupported               @"dneUnsupported"
#define kSCDNEUnavailable               @"dneUnavailable"
#define kSCDNEDisabled                  @"dneDisabled"
#define kSCDNENoData                    @"dneNoData"
#define kSCDNEExpired                   @"dneExpired"
#define kSCWeight                       @"weight"

#pragma mark - TrustFactor Keys

#define kTFIdentification               @"id"
#define kTFIssueMessage                 @"issueMessage"
#define kTFSuggestionMessage            @"suggestionMessage"
#define kTFRevision                     @"revision"
#define kTFClassID                      @"classID"
#define kTFSubclassID                   @"subClassID"
#define kTFPriority                     @"priority"
#define kTFName                         @"name"
#define kTFPenalty                      @"penalty"
#define kTFDNEPenalty                   @"dnepenalty"
#define kTFRuleType                     @"ruleType"
#define kTFLearnMode                    @"learnMode"
#define kTFLearnTime                    @"learnTime"
#define kTFLearnAssertionCount          @"learnAssertionCount"
#define kTFLearnRunCount                @"learnRunCount"
#define kTFThreshold                    @"threshold"
#define kTFDecayMode                    @"decayMode"
#define kTFDecayMetric                  @"decayMetric"
#define kTFDispatch                     @"dispatch"
#define kTFImplementation               @"implementation"
#define kTFWhitelistable                @"whitelistable"
#define kTFPrivateAPI                   @"privateAPI"
#define kTFPayload                      @"payload"

#pragma mark - Dispatch Routines

#define kTrustFactorDispatch            @"TrustFactor_Dispatch_%@"

#pragma mark - Routine Outputs

#define kFileNamesFound                 @"FILE_NAMES_FOUND"
#define kReturnValue                    @"RETURN"

#pragma mark - TrustScore Computation

#define KSystemBreach                   @"SYSTEM_BREACH"
#define kSystemSecurity                 @"SYSTEM_SECURITY"
#define kSystemPolicy                   @"SYSTEM_POLICY"
#define kUserPolicy                     @"USER_POLICY"
#define kUserAnomally                   @"USER_ANOMALY"

#pragma mark - Date and Time Defaults

/*!
 Date and Time format - very important (this is the default of DCKeyValueObjectMapping
 */
#define kDateFormat                     @"eee MMM dd HH:mm:ss ZZZZ yyyy"

#pragma mark - DNE Status Cases for TrustFactor output

/*!
 TrustFactor DidNotExecute Status Code
 */
typedef enum {
DNEStatus_ok                                    = 0,
DNEStatus_unauthorized                          = 1,
DNEStatus_unsupported                           = 2,
DNEStatus_unavailable                           = 3,
DNEStatus_disabled                              = 4,
DNEStatus_expired                               = 5,
DNEStatus_error                                 = 6,
DNEStatus_nodata                                = 7
} DNEStatusCode;

/*!
 Class ID of TrustFactor
 */
typedef enum {
systemBreach                                    = 0,
systemPolicy                                    = 1,
systemSecurity                                  = 2,
userPolicy                                      = 3,
userAnomaly                                     = 4
} attributingClassID;

#pragma mark - Error Cases

/*!
 Error Domain
 */
static NSString *sentegrityDomain               = @"Sentegrity";

/**
 *  Unknown Error Code
 */
enum {
    // Unkown Error
SAUnKnownError                                  = 0
};

/*!
 Core Detection Error Codes
 */
enum {
    // No Policy Provided
SANoPolicyProvided                              = 1,

    // No Callback Block Provided
SANoCallbackBlockProvided                       = 2,

    // No TrustFactors set to analyze
SANoTrustFactorsSetToAnalyze                    = 3,

    // No TrustFactor output objects provided from dispatcher
SANoTrustFactorOutputObjectsFromDispatcher      = 4,

    // Unable to perform computation as no trustfactor objects provided
SANoTrustFactorOutputObjectsForComputation      = 5,

    // Unable to perform computation as no trustfactor objects provided
SAErrorDuringComputation                        = 6,

    // Unable to get the policy from the provided path
SAInvalidPolicyPath                             = 7
};

//TODO: This is bloated, cut it into multiple domains
/*! NSError codes in NSCocoaErrorDomain. Note that other frameworks (such as AppKit and CoreData) also provide additional NSCocoaErrorDomain error codes.
 */
enum {
    // No TrustFactors received when dispatching TrustFactors to generate candidate assertions
SANoTrustFactorsReceived                        = 12,
    // Attempt to do a file system operation on a non-existent file
SANoTrustFactorOutputObjectGenerated            = 13,
    // Invalid TrustFactor Name
SAInvalidTrustFactorName                        = 14,
    // No security token provided
SANoAppIDProvided                               = 17,
    // No assertions received
SANoTrustFactorOutputObjectsReceived            = 18,
    // No assertions added to store
SANoAssertionsAddedToStore                      = 19,
    // No FactorID received
SANoFactorIDReceived                            = 20,
    // Unable to add assertion object into the assertion store
SAUnableToAddStoreTrustFactorObjectsIntoStore   = 21,
    // Unable to compare the assertion object
SAUnableToCompareAssertion                      = 22,
    // Unable to find assertion object to compare
SAUnableToFindAssertionToCompare                = 23,
    // Unable to add assertion into store, already exists
SAUnableToAddAssertionIntoStoreAlreadyExists    = 24,
    // Assertion does not exist
SANoMatchingAssertionsFound                     = 25,
    // Unable to remove assertion
SAUnableToRemoveAssertion                       = 26,
    // Invalid assertion objects provided
SAInvalidStoredTrustFactorObjectsProvided       = 27,
    // Unable to set assertion to the store
SAUnableToSetAssertionToStore                   = 28,
    // No computation received
SANoComputationReceived                         = 29,
    // No dispatch or implementations received
SANoImplementationOrDispatchReceived            = 30,
    // No dispatch class found
SANoDispatchClassFound                          = 31,
    // No implementation selector found
SANoImplementationSelectorFound                 = 32,
    // No classifications found
SANoClassificationsFound                        = 33,
    // No subclassifications found
SANoSubClassificationsFound                     = 34,
    // Cannot overwrite existing store
SACannotOverwriteExistingStore                  = 35,
    // Cannot create new assertion for existing trustfactor
SAUnableToCreateNewStoredAssertion              = 36,
    // Invalie due to no candidate assertions generated
SAInvalidDueToNoCandidateAssertions             = 37,
    // Invalid due to no candidate assertions generated
SAUnableToPerformBaselineAnalysisForTrustFactor = 38,
    // Unable to find a stored assertion during whitelisting
SAErrorDuringWhitelisting                       = 41,
    // Unable to write the assertion store
SAUnableToWriteStore                            = 42,
    // Error performing core detection result analysis
SACannotPerformAnalysis                         = 43,
    // Unable to deactivate protect mode due to error
SAUnableToDeactivateProtectMode                 = 44,
    // Unable to deactivate protect mode due to error
SAUnableToWhitelistAssertions                   = 45,
    // Error when trying to decay a TFs stored assertions
SAErrorDuringDecay                              = 46,
    // Error when trying to check TF learning and add candidate assertions in
SAErrorDuringLearningCheck                      = 47
};

#endif
