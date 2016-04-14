//
//  Sentegrity_TrustScore_Computation.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustScore_Computation.h"
#import "Sentegrity_Constants.h"

// Categories
#import "Sentegrity_Classification+Computation.h"
#import "Sentegrity_Subclassification+Computation.h"


@implementation Sentegrity_Results_Analysis : NSObject 

+ (Sentegrity_TrustScore_Computation *)analyzeResultsForComputation:(Sentegrity_TrustScore_Computation *)computationResults WithPolicy:(Sentegrity_Policy *)policy WithError:(NSError **)error {
    
    // Defaults

    
    computationResults.deviceTrusted = YES;
    computationResults.userTrusted = YES;
    computationResults.systemTrusted = YES;
    computationResults.shouldAttemptTransparentAuthentication = YES;
    
    // Set the result code, these should not be 0 by the end of core detection otherwise something is wrong
    computationResults.coreDetectionResult = 0;
    computationResults.preAuthenticationAction = 0;
    computationResults.postAuthenticationAction = 0;

    
    // Check system threshold
    if (computationResults.systemScore < policy.systemThreshold.integerValue) {
        // System is not trusted
        computationResults.systemTrusted = NO;
        computationResults.deviceTrusted = NO;
        computationResults.shouldAttemptTransparentAuthentication = NO;
    }
    
    // Check User Threshold
    if (computationResults.userScore < policy.userThreshold.integerValue) {
        // User is not trusted
        computationResults.userTrusted = NO;
        computationResults.deviceTrusted = NO;
        computationResults.shouldAttemptTransparentAuthentication = NO;
    }
    
    // If it still makes sense to attempt transparent auth
    if(computationResults.shouldAttemptTransparentAuthentication==YES){
        
        // Determine if we should attempt transparent auth based on the current potential TrustFactors
        // Check entropy and prioritize high entropy trustfactors
        BOOL entropyRequirementsMeetForTransparentAuth;
        entropyRequirementsMeetForTransparentAuth = [[TransparentAuthentication sharedTransparentAuth] analyzeEligibleTransparentAuthObjects:computationResults withPolicy:policy withError:error];
        
        // If there is not enough entropy don't even attempt transparent
        if (entropyRequirementsMeetForTransparentAuth==NO){
            computationResults.shouldAttemptTransparentAuthentication = NO;
            computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthEntropyLow;
            computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
            computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
            // Make sure we set action codes because we won't be executing transparent auth module
            
        }
    }

    
    
    // Check if the system is trusted, with highest attributing first, only one classification can be attributing and
    // indicate which actions to take
    
    if (!computationResults.systemTrusted) {
        

        if (computationResults.systemBreachScore <= computationResults.systemSecurityScore) // SYSTEM_BREACH is attributing
        {
            
            // Set the result code since this class is attributing
            computationResults.coreDetectionResult = CoreDetectionResult_DeviceCompromise;
            
            // Copy over the policy settings for this classification
            computationResults.attributingClassID = [computationResults.systemBreachClass.identification integerValue] ;
            
            // Set action codes from the policy for this classification
            computationResults.preAuthenticationAction = [computationResults.systemBreachClass.preAuthenticationAction integerValue];
            computationResults.postAuthenticationAction = [computationResults.systemBreachClass.postAuthenticationAction integerValue];
            
            // Set dashboard info
            computationResults.systemGUIIconID = [computationResults.systemBreachClass.identification intValue];
            computationResults.systemGUIIconText = computationResults.systemBreachClass.desc;
            
            // SYSTEM_POLICY is attributing
        } else if (computationResults.systemPolicyScore <= computationResults.systemSecurityScore) {
            
            // Set the result code since this class is attributing
            computationResults.coreDetectionResult = CoreDetectionResult_PolicyViolation;
            
            // Copy over the policy settings for this classification
            computationResults.attributingClassID = [computationResults.systemBreachClass.identification integerValue] ;
            
            // Set action codes from the policy for this classification
            computationResults.preAuthenticationAction = [computationResults.systemBreachClass.preAuthenticationAction integerValue];
            computationResults.postAuthenticationAction = [computationResults.systemBreachClass.postAuthenticationAction integerValue];
            
            // Set dashboard info
            computationResults.systemGUIIconID = [computationResults.systemBreachClass.identification intValue];
            computationResults.systemGUIIconText = computationResults.systemBreachClass.desc;
            
            //SYSTEM_SECURITY is attributing
        } else {
            
            // Set the result code since this class is attributing
            computationResults.coreDetectionResult = CoreDetectionResult_HighRiskDevice;
            
            // Copy over the policy settings for this classification
            computationResults.attributingClassID = [computationResults.systemSecurityClass.identification integerValue] ;
            
            // Set action codes from the policy for this classification
            computationResults.preAuthenticationAction = [computationResults.systemSecurityClass.preAuthenticationAction integerValue];
            computationResults.postAuthenticationAction = [computationResults.systemSecurityClass.postAuthenticationAction integerValue];
            
            // Set dashboard info
            computationResults.systemGUIIconID = [computationResults.systemSecurityClass.identification intValue];
            computationResults.systemGUIIconText = computationResults.systemSecurityClass.desc;
        }
        
    } else {
        
        // Set dashboard and detailed system view info
        computationResults.systemGUIIconID = 0;
        computationResults.systemGUIIconText = @"Device Trusted";
    }
    
    // Check if the user is trusted
    if (!computationResults.userTrusted) {
        
        // See which classification inside user attributed the most and set actions accordingly
        
        // USER_POLICY is attributing
        if (computationResults.userPolicyScore <= computationResults.userAnomalyScore) {
            
            // Set dashboard and detailed user view info
            computationResults.userGUIIconID = [computationResults.userPolicyClass.identification intValue];
            computationResults.userGUIIconText = computationResults.userPolicyClass.desc;
            
            // Check if the system is trusted before setting this classification as attributing
            if (computationResults.systemTrusted) {
                
                // System is trusted
                // Set the result code since this class is attributing
                computationResults.coreDetectionResult = CoreDetectionResult_PolicyViolation;
                
                // Copy over the policy settings for this classification
                computationResults.attributingClassID = [computationResults.userPolicyClass.identification integerValue] ;
                
               // Set action codes from the policy for this classification
                computationResults.preAuthenticationAction = [computationResults.userPolicyClass.preAuthenticationAction integerValue];
                computationResults.postAuthenticationAction = [computationResults.userPolicyClass.postAuthenticationAction integerValue];
                
            }
            else{
                
                // else we dont override the system attributing classIDs, etc.
                
            }
            
            //USER_ANOMALY is attributing
        } else {
            
            // Set dashboard and detailed user view info
            computationResults.userGUIIconID = [computationResults.userAnomalyClass.identification intValue];
            computationResults.userGUIIconText = computationResults.userAnomalyClass.desc;
            
            // Set protect mode action to the class specified action ONLY if system did not already
            if (computationResults.systemTrusted) {
                
                // System is trusted
                // Set the result code since this class is attributing
                computationResults.coreDetectionResult = CoreDetectionResult_UserAnomaly;
                
                // Set action codes from the policy for this classification
                computationResults.attributingClassID = [computationResults.userAnomalyClass.identification integerValue] ;
                
                // Set action codes
                computationResults.preAuthenticationAction = [computationResults.userAnomalyClass.preAuthenticationAction integerValue];
                computationResults.postAuthenticationAction = [computationResults.userAnomalyClass.postAuthenticationAction integerValue];
                
            }
            else{
                
                // else we dont override the system attributing classIDs, etc. but we do update the user GUI info
                
                
            }
            
        }
        
    } else {
        
        // Set dashboard and detailed system view info
        computationResults.userGUIIconID = 0;
        computationResults.userGUIIconText = @"User Trusted";
        
        
    }
    
    return computationResults;
}


@end
