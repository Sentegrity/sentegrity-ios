//
//  Sentegrity_Constants.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#ifndef SenTest_Constants_h
#define SenTest_Constants_h

#pragma mark - Defaults

#define kDefaultPolicyName @"Default_Policy.plist"

#pragma mark - Assertion Storage

#define kDefaultAssertionStoragePath @"/AssertionStores"
#define kDefaultAssertionStoreNamePrefix @"Assertion_Store_"
#define kGlobalAssertionStoreSecurityToken @"2"

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
#define kTFManaged @"managed"
#define kTFLocal @"local"
#define kTFHistory @"history"
#define kTFDispatch @"dispatch"
#define kTFImplementation @"implementation"
#define kTFBaseline @"baseline"
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

#pragma mark - Error Cases

/* NSError codes in NSCocoaErrorDomain. Note that other frameworks (such as AppKit and CoreData) also provide additional NSCocoaErrorDomain error codes.
 */
enum {
    // Unkown Error
    SAUknownError = 10,
    // No TrustFactors received when dispatching TrustFactors to generate candidate assertions
    SANoTrustFactorsReceived = 12,
    // Attempt to do a file system operation on a non-existent file
    SANoAssertionGenerated = 13,
    // Invalid TrustFactor Name
    SAInvalidTrustFactorName = 14,
    // No TrustFactors set to analyze
    SANoTrustFactorsSetToAnalyze = 15,
    // No policy provided
    SANoPolicyProvided = 16,
    // No security token provided
    SANoSecurityTokenProvided = 17,
    // No assertions received
    SANoAssertionsReceived = 18,
    // No assertions added to store
    SANoAssertionsAddedToStore = 19,
    // No FactorID received
    SANoFactorIDReceived = 20,
    // Unable to add assertion object into the assertion store
    SAUnableToAddAssertionIntoStore = 21,
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
    SAInvalidAssertionsProvided = 27,
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
    SANoSubClassificationsFound = 34
};

#endif
