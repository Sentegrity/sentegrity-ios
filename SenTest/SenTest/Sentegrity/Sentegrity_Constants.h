//
//  Sentegrity_Constants.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#ifndef SenTest_Constants_h
#define SenTest_Constants_h

// TODO: Beta only
#define kUniqueDeviceID @"1234567890"

#pragma mark - Defaults

#define kDefaultAppID @"default"
#define kDefaultGlobalStoreName @"global"
#define kDefaultTrustFactorOutput @"0"

#pragma mark - Assertion Storage

#define kAssertionStorePath @"/Assertion_Stores/"
#define kPolicyPath @"/Policies/"
#define kResumePath @"/Resume/"
#define kStoredTrustFactorObjectMapping @"storedTrustFactorObjects"

#pragma mark - Policy Keys

#define kPolicyID @"policyID"
#define kRevision @"revision"
#define kRuntime @"runtime"
#define kUserThreshold @"userThreshold"
#define kSystemThreshold @"systemThreshold"
#define kDNEModifiers @"DNEModifiers"
#define kClassifications @"classifications"
#define kSubClassifications @"subclassification"
#define kTrustFactors @"trustFactors"

#pragma mark - DNEModifier Keys

#define kUnauthorized @"unauthorized"
#define kUnsupported @"unsupported"
#define kDisabled @"disabled"
#define kExpired @"expired"
#define kError @"error"

#pragma mark - Classification Keys

#define kIdentification @"id"
#define kName @"name"
#define kWeight @"weight"
#define kProtectMode @"protectMode"
#define kProtectViolationName @"protectViolationName"
#define kProtectInfo @"protectInfo"
#define kContactPhone @"contactPhone"
#define kContactURL @"contactURL"
#define kContactEmail @"contactEmail"

#pragma mark - Subclassification Keys

#define kSCIdentification @"id"
#define kSCClassID @"classID"
#define kSCName @"name"
#define kSCDNEMessage @"dneMessage"
#define kSCWeight @"weight"

#pragma mark - TrustFactor Keys

#define kTFIdentification @"id"
#define kTFDescription @"desc"
#define kTFRevision @"revision"
#define kTFClassID @"classID"
#define kTFSubclassID @"subClassID"
#define kTFPriority @"priority"
#define kTFName @"name"
#define kTFPenalty @"penalty"
#define kTFDNEPenalty @"dnepenalty"
#define kTFLearnMode @"learnMode"
#define kTFLearnTime @"learnTime"
#define kTFLearnAssertionCount @"learnAssertionCount"
#define kTFLearnRunCount @"learnRunCount"
#define kTFThreshold @"threshold"
#define kTFManaged @"managed"
#define kTFLocal @"local"
#define kTFHistory @"history"
#define kTFProvision @"provision"
#define kTFDispatch @"dispatch"
#define kTFImplementation @"implementation"
#define kTFInverse @"inverse"
#define kTFPayload @"payload"

#pragma mark - Dispatch Routines

#define kTrustFactorDispatch @"TrustFactor_Dispatch_%@"

#define kRoutinebadFiles @"badFiles"
#define kRoutinefileSizeChange @"fileSizeChange"
#define kRoutinebadProcesses @"badProcesses"
#define kRoutinenewRootProcess @"newRootProcess"
#define kRoutinebadProcessPath @"badProcessPath"
#define kRoutinehighRiskApp @"highRiskApp"
#define kRoutinebadNetDst @"badNetDst"
#define kRoutinepriviledgedNetServices @"priviledgedNetServices"
#define kRoutinenewNetService @"newNetService"
#define kRoutineunencryptedTraffic @"unencryptedTraffic"
#define kRoutinesandboxVerification @"sandboxVerification"
#define kRoutinebadURIHandlers @"badURIHandlers"
#define kRoutinesubscribeTamper @"subscribeTamper"
#define kRoutinevulnerableSubscriber @"vulnerableSubscriber"
#define kRoutinepolicyTamper @"policyTamper"
#define kRoutinesystemProtectMode @"systemProtectMode"
#define kRoutineuserProtectMode @"userProtectMode"
#define kRoutineselfTamper @"selfTamper"
#define kRoutinesentegrityVersion @"sentegrityVersion"
#define kRoutineapSoho @"apSoho"
#define kRoutineapHotspotter @"apHotspotter"
#define kRoutinewifiEncType @"wifiEncType"
#define kRoutinessidAllowed @"ssidAllowed"
#define kRoutinevulnerablePlatform @"vulnerablePlatform"
#define kRoutineplatformVersionAllowed @"platformVersionAllowed"
#define kRoutinepowerPercent @"powerPercent"
#define kRoutineshortUptime @"shortUptime"
#define kRoutinetimeAllowed @"timeAllowed"
#define kRoutineaccessTime @"accessTime"
#define kRoutinelocationAllowed @"locationAllowed"
#define kRoutinelocation @"location"
#define kRoutinedeviceMovement @"deviceMovement"
#define kRoutinedevicePosition @"devicePosition"
#define kRoutinebluetoothPaired @"bluetoothPaired"
#define kRoutinebluetoothLEScan @"bluetoothLEScan"
#define kRoutineupnpScan @"upnpScan"
#define kRoutinebonjourScan @"bonjourScan"
#define kRoutineactivity @"activity"
#define kRoutinevpnUp @"vpnUp"
#define kRoutinenoRoute @"noRoute"

#pragma mark - Routine Outputs

#define kFileNamesFound @"FILE_NAMES_FOUND"
#define kReturnValue @"RETURN"

#pragma mark - TrustScore Computation

#define kBreachIndicator @"BREACH_INDICATOR"
#define kSystemSecurity  @"SYSTEM_SECURITY"
#define kPolicyViolation @"POLICY_VIOLATION"
#define kUserAnomally    @"USER_ANOMALLY"

#pragma mark - DNE Status Cases for TrustFactor output

typedef enum {
    DNEStatus_ok           = 0, // OK
    DNEStatus_unauthorized = 1, // Unauthorized - Permissions
    DNEStatus_unsupported  = 2, // Unsupported OS or Device
    DNEStatus_disabled     = 3, // Disabled
    DNEStatus_expired      = 4, // Expired
    DNEStatus_error        = 5, // Error
    DNEStatus_nodata       = 6  // No data found or received
} DNEStatusCode;

#pragma mark - Error Cases

/* NSError codes in NSCocoaErrorDomain. Note that other frameworks (such as AppKit and CoreData) also provide additional NSCocoaErrorDomain error codes.
 */
enum {
    // Unkown Error
    SAUknownError = 10,
    // No TrustFactors received when dispatching TrustFactors to generate candidate assertions
    SANoTrustFactorsReceived = 12,
    // Attempt to do a file system operation on a non-existent file
    SANoTrustFactorOutputObjectGenerated = 13,
    // Invalid TrustFactor Name
    SAInvalidTrustFactorName = 14,
    // No TrustFactors set to analyze
    SANoTrustFactorsSetToAnalyze = 15,
    // No policy provided
    SANoPolicyProvided = 16,
    // No security token provided
    SANoAppIDProvided = 17,
    // No assertions received
    SANoTrustFactorOutputObjectsReceived = 18,
    // No assertions added to store
    SANoAssertionsAddedToStore = 19,
    // No FactorID received
    SANoFactorIDReceived = 20,
    // Unable to add assertion object into the assertion store
    SAUnableToAddStoreTrustFactorObjectsIntoStore = 21,
    // Unable to compare the assertion object
    SAUnableToCompareAssertion = 22,
    // Unable to find assertion object to compare
    SAUnableToFindAssertionToCompare = 23,
    // Unable to add assertion into store, already exists
    SAUnableToAddAssertionIntoStoreAlreadyExists = 24,
    // Assertion does not exist
    SANoMatchingAssertionsFound = 25,
    // Unable to remove assertion
    SAUnableToRemoveAssertion = 26,
    // Invalid assertion objects provided
    SAInvalidStoredTrustFactorObjectsProvided = 27,
    // Unable to set assertion to the store
    SAUnableToSetAssertionToStore = 28,
    // No computation received
    SANoComputationReceived = 29,
    // No dispatch or implementations received
    SANoImplementationOrDispatchReceived = 30,
    // No dispatch class found
    SANoDispatchClassFound = 31,
    // No implementation selector found
    SANoImplementationSelectorFound = 32,
    // No classifications found
    SANoClassificationsFound = 33,
    // No subclassifications found
    SANoSubClassificationsFound = 34,
    // Cannot overwrite existing store
    SACannotOverwriteExistingStore = 35,
    // Cannot create new assertion for existing trustfactor
    SAUnableToCreateNewStoredAssertion = 36,
    // Invalie due to no candidate assertions generated
    SAInvalidDueToNoCandidateAssertions = 37,
    // Invalid due to no candidate assertions generated
    SAUnableToPerformBaselineAnalysisForTrustFactor = 38,
    // Unable to perform computation as no trustfactor objects provided
    SANoTrustFactorOutputObjectsForComputation = 39,
    // Unable to perform computation as no trustfactor objects provided
    SAErrorDuringComputation = 40,
    // Unable to find a stored assertion during whitelisting
    SAErrorDuringWhitelisting = 41,
    // Unable to write the assertion store
    SAUnableToWriteStore = 42,
    // Error performing core detection result analysis
    SACannotPerformAnalysis = 43,
    // Unable to deactivate protect mode due to error
    SAUnableToDeactivateProtectMode = 44,
    // Unable to deactivate protect mode due to error
    SAUnableToWhitelistAssertions = 45
};

#endif
