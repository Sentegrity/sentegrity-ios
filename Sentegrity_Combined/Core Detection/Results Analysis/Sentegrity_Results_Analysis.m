  //
//  Sentegrity_TrustScore_Computation.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustScore_Computation.h"
#import "Sentegrity_Constants.h"
#import "LocalAuthentication/LAContext.h"
#import "Sentegrity_Startup_Store.h"

// Categories
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"

// Auth Modules
#import "Sentegrity_Authentication.h"


@implementation Sentegrity_Results_Analysis : NSObject 

+ (Sentegrity_TrustScore_Computation *)analyzeResultsForComputation:(Sentegrity_TrustScore_Computation *)computationResults WithPolicy:(Sentegrity_Policy *)policy WithError:(NSError **)error {
    
    // Default trust results
    computationResults.deviceTrusted = YES;
    computationResults.userTrusted = YES;
    computationResults.systemTrusted = YES;
    
    // Auth method defaults
    computationResults.authenticationModuleEmployed = nil;

    // Set the result code, these should not be 0 by the end of core detection otherwise something is wrong
    computationResults.coreDetectionResult = 0;
    computationResults.authenticationAction = 0;
    computationResults.postAuthenticationAction = 0;
    

    // Check device trust threshold (only trust if the overall score > threshold
    if (computationResults.systemScore < policy.systemThreshold.integerValue  ) {
        // System is not trusted
        computationResults.deviceTrusted = NO;
        computationResults.systemTrusted = NO;
    }
    

    
    // Check if the system is trusted, with highest attributing first, only one classification can be attributing and
    // indicate which actions to take
    
    if (computationResults.systemTrusted == NO) {
        

        if (computationResults.systemBreachScore <= computationResults.systemSecurityScore) // SYSTEM_BREACH is attributing
        {
            
            // Set the result code since this class is attributing
            computationResults.coreDetectionResult = CoreDetectionResult_DeviceCompromise;
            
            // Copy over the policy settings for this classification
            computationResults.attributingClassID = [computationResults.systemBreachClass.identification integerValue];
            computationResults.warnTitle = computationResults.systemBreachClass.warnTitle;
            computationResults.warnDesc = computationResults.systemBreachClass.warnDesc;
            
            // Set action codes from the policy for this classification
            computationResults.authenticationAction = [computationResults.systemBreachClass.authenticationAction integerValue];
            computationResults.postAuthenticationAction = [computationResults.systemBreachClass.postAuthenticationAction integerValue];
            
            // Set dashboard info
            computationResults.dashboardText = computationResults.systemBreachClass.dashboardText;
            
            // SYSTEM_POLICY is attributing
        } else if (computationResults.systemPolicyScore <= computationResults.systemSecurityScore) {
            
            // Set the result code since this class is attributing
            computationResults.coreDetectionResult = CoreDetectionResult_PolicyViolation;
            
            // Copy over the policy settings for this classification
            computationResults.attributingClassID = [computationResults.systemPolicyClass.identification integerValue] ;
            computationResults.warnTitle = computationResults.systemPolicyClass.warnTitle;
            computationResults.warnDesc = computationResults.systemPolicyClass.warnDesc;
            
            // Set action codes from the policy for this classification
            computationResults.authenticationAction = [computationResults.systemPolicyClass.authenticationAction integerValue];
            computationResults.postAuthenticationAction = [computationResults.systemPolicyClass.postAuthenticationAction integerValue];
            
            // Set dashboard info
            computationResults.dashboardText = computationResults.systemPolicyClass.dashboardText;
            
            //SYSTEM_SECURITY is attributing
        } else {
            
            // Set the result code since this class is attributing
            computationResults.coreDetectionResult = CoreDetectionResult_HighRiskDevice;
            
            // Copy over the policy settings for this classification
            computationResults.attributingClassID = [computationResults.systemSecurityClass.identification integerValue] ;
            computationResults.warnTitle = computationResults.systemSecurityClass.warnTitle;
            computationResults.warnDesc = computationResults.systemSecurityClass.warnDesc;
            
            // Set action codes from the policy for this classification
            computationResults.authenticationAction = [computationResults.systemSecurityClass.authenticationAction integerValue];
            computationResults.postAuthenticationAction = [computationResults.systemSecurityClass.postAuthenticationAction integerValue];
            
            // Set dashboard info
            computationResults.dashboardText = computationResults.systemSecurityClass.dashboardText;
        }
        
    } else {
        
        // Set dashboard and detailed system view info
        //computationResults.systemGUIIconID = 0;
        //computationResults.systemGUIIconText = @"Device Trusted";
    }
    
    // if the system is trusted evaluate the user
    if (computationResults.systemTrusted == YES) {
        
        
        // Check for user policy violation
        if (computationResults.userPolicyScore < 100) {
            
            // Set dashboard text
            computationResults.dashboardText = computationResults.userPolicyClass.dashboardText;

             // Set the result code since this class is attributing
             computationResults.coreDetectionResult = CoreDetectionResult_PolicyViolation;
             
             // Copy over the policy settings for this classification
             computationResults.attributingClassID = [computationResults.userPolicyClass.identification integerValue] ;
            computationResults.warnTitle = computationResults.systemBreachClass.warnTitle;
            computationResults.warnDesc = computationResults.systemBreachClass.warnDesc;
             
            // Set action codes from the policy for this classification
             computationResults.authenticationAction = [computationResults.userPolicyClass.authenticationAction integerValue];
             computationResults.postAuthenticationAction = [computationResults.userPolicyClass.postAuthenticationAction integerValue];

            
        // No policy violation, check user anomaly risk rating and determine auth mode
        } else {
            
            //Check if we should skip fingerprint if present in policy
            // First check if the user disabled touchID during enrollment and skip other check
            
            NSError *error1;
            Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error1];
            BOOL skipFingerprint=NO;
            
            if (![startup touchIDDisabledByUser]) {
                
                
                //Perform check to determine if the device has no passcode and no fingerprint enrolled
                //Skip fingerprint module if its in the policy
                LAContext *myContext = [[LAContext alloc] init];
                NSNumber *passcodeStatus = [[Sentegrity_TrustFactor_Datasets sharedDatasets] getPassword];
                NSError *error1;
                
                
                //if passcode is set
                if (passcodeStatus.integerValue == 1) {
                    
                    
                    //check if touchID is avaialable, and fingerprint is set
                    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error1]) {
                        //true, don't skip, ask for fingerprint
                        
                    }
                    else {
                        
                        skipFingerprint=YES;
                        /*
                         if (error1.code == (-7)) {
                         //no fingers are enrolled, show TouchID and ask user to add fingerprint back
                         skipFingerprint=NO;
                         }
                         else {
                         // no touchID support, continue and skip fingerprint module
                         skipFingerprint=YES;
                         }
                         */
                        
                    }
                    
                }else{
                    //passcode not set, skip fingerprint
                    skipFingerprint=YES;
                }
                
                
            }else{
                skipFingerprint=YES;
            }
            

            
            
            
            // Determine the userScore status based on where it falls in our range
            
            // Iterate through all authenticaiton modules loaded from policy and determine where the UserScore falls, order of modules in policy is the priority
            for (Sentegrity_Authentication *authModule in policy.authenticationModules) {
                
                // If the current user score is greater than or equal to the current auth modules activation range then we choose it, otherwise keep walking through until we find a range that works
                if(computationResults.userScore >=  authModule.activationRange.integerValue){

                    // We this module fits the range, see if transparent auth is the module since this must be treated differently
                    if(authModule.authenticationAction.integerValue == authenticationAction_TransparentlyAuthenticate || authModule.authenticationAction.integerValue == authenticationAction_TransparentlyAuthenticateAndWarn){
                        
                        // Attempt transparent authentication
                        [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Performing transparent authentication"];
                        
                        // Save the module employed such that prompt information can be read from it
                        computationResults.authenticationModuleEmployed = authModule;
                        
                        // Set the dashboard text
                        computationResults.dashboardText = authModule.dashboardText;
                        
                        // Determine if we should attempt transparent auth based on the current potential TrustFactors
                        // Check entropy and prioritize high entropy trustfactors
                        BOOL entropyRequirementsMeetForTransparentAuth;
                        entropyRequirementsMeetForTransparentAuth = [[TransparentAuthentication sharedTransparentAuth] analyzeEligibleTransparentAuthObjects:computationResults withPolicy:policy withError:error];
                        
                        // If there is not enough entropy don't even attempt transparent
                        if (entropyRequirementsMeetForTransparentAuth==NO){
                            computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthEntropyLow;
                            
                            // Don't set pre or post auth actions here , let the next auth method specified take over instead
                            
                            // Go to next auth module
                            continue;
                            
                        }else{ // We meet the entropy requirements to further attempt transparent auth
                            
                            
                            NSError *error;
                            computationResults = [[TransparentAuthentication sharedTransparentAuth] attemptTransparentAuthenticationForComputation:computationResults withPolicy:policy withError:&error];
                            
                            // Validate the computation results
                            if (!computationResults || computationResults == nil) {
                                
                                // Invalid analysis, bad computation results
                                NSDictionary *errorDetails = @{
                                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No computation object returned, error during transparent authentication", nil),
                                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs for details", nil)
                                                               };
                                
                                // Set the error
                                error = [NSError errorWithDomain:coreDetectionDomain code:SAErrorDuringComputation userInfo:errorDetails];
                                
                                // Log it
                                NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
                                
                            }
                            // If transparent auth worked (meaning it has a master key or wants to create a new key), continue to select the auth method required but don't override
                            
                            if  (computationResults.coreDetectionResult == CoreDetectionResult_TransparentAuthSuccess){
                                
                                computationResults.authenticationModuleEmployed = authModule;
                                
                                // set the actions and don't attempt other auth methods
                                computationResults.authenticationAction = [authModule.authenticationAction integerValue];
                                computationResults.postAuthenticationAction = [authModule.postAuthenticationAction integerValue];
                                
                                // Set dashboard and detailed user view info
                                computationResults.dashboardText = authModule.dashboardText;
                                
                                // Set action codes from the policy for this classification
                                computationResults.attributingClassID = [computationResults.userAnomalyClass.identification integerValue];
                                computationResults.warnTitle = authModule.warnTitle;
                                computationResults.warnDesc = authModule.warnDesc;
                                
                                break;
                            }
                            else if(computationResults.coreDetectionResult == CoreDetectionResult_TransparentAuthNewKey){
                                
                                //let next auth method take over but don't override postAuth method because we need new key made
                                computationResults.postAuthenticationAction = postAuthenticationAction_createTransparentKey;
                                continue;
                                
                                
                            }
                            else if (computationResults.coreDetectionResult == CoreDetectionResult_TransparentAuthError){
                                
                                //let next auth method take over
                                continue;
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    else if((authModule.authenticationAction.integerValue == authenticationAction_PromptForUserFingerprint || authModule.authenticationAction.integerValue == authenticationAction_PromptForUserFingerprintAndWarn) && skipFingerprint==YES){
                        // Skip fingerprint module if it is present in policy but device has no password or touchID support
                        continue;
                        
                    }
                    // All other auth modules handled here
                    else{
                        // Set result
                        computationResults.coreDetectionResult = CoreDetectionResult_UserAnomaly;
                        // Set dashboard and detailed user view info
                        computationResults.dashboardText = authModule.dashboardText;
                        
                        // Set method for runHistory upload
                        computationResults.authenticationModuleEmployed = authModule;
                        
                        // Set booleans from default YES
                        computationResults.userTrusted = NO;
                        computationResults.deviceTrusted = NO;
                        
                        // Set action codes from the policy for this classification
                        computationResults.attributingClassID = [computationResults.userAnomalyClass.identification integerValue] ;
                        computationResults.warnTitle = authModule.warnTitle;
                        computationResults.warnDesc = authModule.warnDesc;
                        
                        // Set preLoginAction to what the auth module wants
                        computationResults.authenticationAction = [authModule.authenticationAction integerValue];
                        
                        // Set post authentication action only if it was not already set by transparent auth, otherwise we could override postAuthenticationAction_createTransparentKey
                        if(computationResults.postAuthenticationAction == 0){
                           computationResults.postAuthenticationAction = [authModule.postAuthenticationAction integerValue];
                        }
                        
                        break;

                    }
 
                
                } // end if trustscore > current auth module range
                
            } // end auth module iteration
            
        } // end if not policy violation
        
    } else { // System is not trusted therefore don't do any user anomaly or risk-based auth determination
        
        // Set dashboard and detailed system view info
        // Don't think we need this anymore
        //computationResults.dashboardText = @"Authentication Disabled";
        
        
    }
    
    return computationResults;
}


@end
