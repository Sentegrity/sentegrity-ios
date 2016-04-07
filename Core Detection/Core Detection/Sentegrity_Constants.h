//
//  Sentegrity_Constants.h
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

/**
 *  Constant definitions for Core Detection
 */

#ifndef Sentegrity_Constants_h
#define Sentegrity_Constants_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

// TODO: Beta only
#define kUniqueDeviceID                 @"1234567890"

// Allows Private API's?
#define kAllowsPrivateAPIs              1

#pragma mark - Defaults

#define kDefaultAppID                   @"default"
#define kDefaultGlobalStoreName         @"global"
#define kDefaultTrustFactorOutput       @"0"

// Startup File Name
#define kStartupFileName                @"startup"

// Policy File Name
#define kPolicyFileName                 @"policy"

// Assertion Store File Name
#define kAssertionStoreFileName         @"store"

// TODO: Default salts
#define kDefaultDeviceSalt              @"sdkfljasdf89dsjd"
#define kDefaultUserSalt                @"faklsjfads8sadjd8d"

#pragma mark - Assertion Storage

#define kStoredTrustFactorObjectMapping @"storedTrustFactorObjects"
#define kAssertionObjectMapping         @"assertionObjects"

#pragma mark - Startup File Keys

#define kRunHistory                     @"runHistoryObjects"
#define kTransparentAuthKeys            @"transparentAuthKeyObjects"

#pragma mark - Policy Keys

#define kPolicyID                       @"policyID"
#define kTransparentAuthDecayMetric     @"transparentAuthDecayMetric"
#define kTransparentAuthEnabled         @"transparentAuthEnabled"
#define kcontinueOnError                @"continueOnError"
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

#pragma mark - Dispatch Routines

#define kTrustFactorDispatch            @"TrustFactor_Dispatch_%@"

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
 * TrustFactor DidNotExecute Status Code
 */
typedef enum {
    DNEStatus_ok                                    = 0,
    DNEStatus_unauthorized                          = 1,
    DNEStatus_unsupported                           = 2,
    DNEStatus_unavailable                           = 3,
    DNEStatus_disabled                              = 4,
    DNEStatus_expired                               = 5,
    DNEStatus_error                                 = 6,
    DNEStatus_nodata                                = 7,
    DNEStatus_invalid                               = 8
} DNEStatusCode;

/*!
 * Class ID of TrustFactor
 */
typedef enum {
    systemBreach                                    = 0,
    systemPolicy                                    = 1,
    systemSecurity                                  = 2,
    userPolicy                                      = 3,
    userAnomaly                                     = 4
} attributingClassID;

#pragma mark - Core Detection Result Codes

/*!
 * Core Detection Result Codes
 * These indicates the result of core detection and are mainly for logging or GUI use
 */
typedef enum {
    CoreDetectionResult_UserAnomaly                            = 1,
    CoreDetectionResult_PolicyViolation                        = 2,
    CoreDetectionResult_HighRiskDevice                         = 3,
    CoreDetectionResult_TransparentAuthSuccess                 = 4,
    CoreDetectionResult_TransparentAuthNewKey                  = 5,
    CoreDetectionResult_CoreDetectionError                     = 6,
    CoreDetectionResult_TransparentAuthError                   = 7,
    CoreDetectionResult_DeviceCompromise                       = 8,
    
} CoreDetectionResultCode;

#pragma mark - Core Detection Action Codes

/*!
 * Pre Authentication Action Codes
 * These indicate what the application that Sentegrity integrated with should do after core detection was complete
 */
typedef enum {
    preAuthenticationAction_PromptForUserPassword                            = 1,
    preAuthenticationAction_PromptForUserPasswordAndWarn                     = 2,
    preAuthenticationAction_BlockAndWarn                                     = 3,
    preAuthenticationAction_TransparentlyAuthenticate                        = 4
    
    
} preAuthenticationAction;


#pragma mark - Post Authentication Action Codes

/*!
 * Post Authentication Action
 * These indicate what should happen after a successful authentication event
 */
typedef enum {
    
    postAuthenticationAction_whitelistUserAssertions                            = 1,
    postAuthenticationAction_whitelistUserAndSystemAssertions                   = 2,
    postAuthenticationAction_whitelistSystemAssertions                          = 3,
    postAuthenticationAction_DoNothing                                          = 4,
    postAuthenticationAction_showSuggestions                                    = 5,
    postAuthenticationAction_whitelistUserAssertionsAndCreateTransparentKey     = 6,

} postAuthenticationAction;

#pragma mark - Authentication Response Codes

/*!
 * Authentication Result Code
 * These indicate what should happen after a successful authentication event
 */
typedef enum {
    
    authenticationResult_incorrectLogin                                   = 1,
    authenticationResult_irrecoverableError                               = 2,
    authenticationResult_Success                                          = 3,
    authenticationResult_recoverableError                                 = 4,

    
} authenticationResult;

#pragma mark - Error Cases

/*!
 * Error Domains
 */
static NSString * const transparentAuthDomain           = @"Transparent Authentication";
static NSString * const coreDetectionDomain             = @"Core Detection";
static NSString * const assertionStoreDomain            = @"Assertion Store";
static NSString * const trustFactorDispatcherDomain     = @"TrustFactor Dispatcher";
static NSString * const sentegrityDomain                = @"Sentegrity";


//TODO: This is bloated, cut it into multiple domains
/*! NSError codes in NSCocoaErrorDomain. Note that other frameworks (such as AppKit and CoreData) also provide additional NSCocoaErrorDomain error codes.
 */

/**
 *  Unknown Error Code
 */
enum {
    // Unkown Error
    SAUnknownError                                  = 0
};

/*!
 * Core Detection Error Codes
 */
enum {
    // No Policy Provided
    SACoreDetectionNoPolicyProvided                 = 1,
    
    // No Callback Block Provided
    SANoCallbackBlockProvided                       = 2,
    
    // No TrustFactors set to analyze
    SANoTrustFactorsSetToAnalyze                    = 3,
    
    // Invalid Startup File
    SAInvalidStartupFile                            = 322,
    
    // Invalid Startup Instance
    SAInvalidStartupInstance                        = 323,
    
    // No TrustFactor output objects provided from dispatcher
    SANoTrustFactorOutputObjectsFromDispatcher      = 4,
    
    // Unable to perform computation as no trustfactor objects provided
    SANoTrustFactorOutputObjectsForComputation      = 5,
    
    // Unable to perform computation as no trustfactor objects provided
    SAErrorDuringComputation                        = 6,
    
    // Unable to get the policy from the provided path
    SAInvalidPolicyPath                             = 7,
    
    // Unable to get the assertion store from provided path
    SAInvalidAssertionStorePath                     = 52,
    
    // No computation received
    SANoComputationReceived                         = 29,
    
    // Error performing core detection result analysis
    SACannotPerformAnalysis                         = 43,
    
    // Invalid From Time - Days Between Dates
    SAInvalidFromTimeDaysBetweenDates               = 3203,
    
    // Invalid To Time - Days Between Dates
    SAInvalidToTimeDaysBetweenDates                 = 3204
    
};


/*!
 * Protect Mode Error Codes
 */
enum {
    // Invalid Policy PIN provided
    SAInvalidPolicyPinProvided                      = 8,
    
    // Unable to deactivate protect mode due to error
    SAUnableToWhitelistAssertions                   = 9,
    
    // Invalid User PIN provided
    SAInvalidUserPinProvided                        = 10,
    
    // Unable to find a stored assertion during whitelisting
    SAErrorDuringWhitelisting                       = 41,
    
    // Unable to deactivate protect mode due to error
    SAUnableToDeactivateProtectMode                 = 44,
    
    // Post authentication action error
    SAUnableToPerformPostAuthenticationAction       = 53,
    
    
};

/*!
 * Dispatcher Error Codes
 */
enum {
    // Unable to set assertion objects from output
    SAUnableToSetAssertionObjectsFromOutput         = 50
};

/*!
 * Assertion Store Error Codes
 */
enum {
    // No assertions received
    SANoTrustFactorOutputObjectsReceived            = 18,
    
    // Unable to add assertion object into the assertion store
    SAUnableToAddStoreTrustFactorObjectsIntoStore   = 21,
    
    // Invalid assertion objects provided
    SAInvalidStoredTrustFactorObjectsProvided       = 27,
    
    // Unable to remove assertion
    SAUnableToRemoveAssertion                       = 26,
    
    // Assertion does not exist
    SANoMatchingAssertionsFound                     = 25,
    
    // No FactorID received
    SAAssertionStoreNoFactorIDReceived              = 20,

    // Unable to add assertion into store, already exists
    SAUnableToAddAssertionIntoStoreAlreadyExists    = 24,
    
    // Cannot overwrite existing store
    SACannotOverwriteExistingStore                  = 35,
};

/*!
 * TrustFactor Storage Error Codes
 */
enum {
    // No security token provided
    SANoAppIDProvided                               = 17,
    
    // Unable to write the assertion store
    SAUnableToWriteStore                            = 42,
    
    
};

/**
 * Baseline Analysis Error Codes
 */
enum {
    // No assertions added to store
    SANoAssertionsAddedToStore                      = 19,
    
    // Unable to compare the assertion object
    SAUnableToCompareAssertion                      = 22,
    
    // Unable to find assertion object to compare
    SAUnableToFindAssertionToCompare                = 23,
    
    // Unable to set assertion to the store
    SAUnableToSetAssertionToStore                   = 28,
    
    // Cannot create new assertion for existing trustfactor
    SAUnableToCreateNewStoredAssertion              = 36,
    
    // Invalid due to no candidate assertions generated
    SAUnableToPerformBaselineAnalysisForTrustFactor = 38,
    
    // Error when trying to check TF learning and add candidate assertions in
    SAErrorDuringLearningCheck                      = 47,
    
    // Error when trying to decay a TFs stored assertions
    SAErrorDuringDecay                              = 46,

    // Invalie due to no candidate assertions generated
    SAInvalidDueToNoCandidateAssertions             = 37,
    
    
};

/*!
 * TrustFactor Dispatcher Error Codes
 */
enum {
    // No TrustFactors received when dispatching TrustFactors to generate candidate assertions
    SANoTrustFactorsReceived                        = 12,
    
    // Attempt to do a file system operation on a non-existent file
    SANoTrustFactorOutputObjectGenerated            = 13,
    
    // Invalid TrustFactor Name
    SAInvalidTrustFactorName                        = 14,
    
    // No dispatch or implementations received
    SANoImplementationOrDispatchReceived            = 30,
    
    // No dispatch class found
    SANoDispatchClassFound                          = 31,
    
    // No implementation selector found
    SANoImplementationSelectorFound                 = 32,
};

/*!
 * Sentegrity TrustScore Computation Error Codes
 */
enum {
    // No classifications found
    SANoClassificationsFound                        = 33,
    
    // No subclassifications found
    SANoSubClassificationsFound                     = 34,
    
};

/*!
 * Transparent Authentication Error Codes
 */
enum {
    // Invalid transparent key raw output
    SAInvalidTransparentKeyOutput                   = 47,
    
    // Invalid PBKDF2 transparent key derivation
    SAInvalidPBKDF2TransparentKeyDerivation         = 48,
    
    // Invalid hash of transparent key
    SAInvalidHashOfTransparentKey                   = 49,
    
    // Unable to decrypt MASTER KEY using transparent key
    SAUnableToDecryptMasterKeyUsingTransparentKey   = 50,
    
    // No transparent authentication trustfactor objects
    SANoTransparentAuthenticationTrustFactorObjects  = 51,
    
    // Unable to create new transparent key
    SAUnableToCreateNewTransparentKey                = 54,
    
};

/*!
 *  Crypto Codes
 */
enum {
    // Unable to create new user key and master key
    SAUnableToCreateNewUserAndMasterKey             = 55,
    
    // Unable to get Transparent Key for TrustFactor Output
    SAUnableToGetTransparentKeyTrustFactor          = 56,
    
    // Unable to get User Salt Key Data
    SAUnableToGetUserSaltKeyData                    = 57,
    
    // Unable to get User Derived Key
    SAUnableToGetUserDerivedKey                     = 58,
    
    // Unable to get decrypted master key
    SAUnableToGetDecryptedMasterKey                 = 59,
    
    // Unable to get transparent key master key salt string
    SAUnableToGetTransparentKeyMasterKeySalt        = 60
};

#endif
