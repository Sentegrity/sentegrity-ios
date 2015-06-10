//
//  ProtectMode.m
//  SenTest
//
//  Created by Jason Sinchak on 5/23/15.
//

#import <Foundation/Foundation.h>
#import "ProtectMode.h"
#import "CoreDetection.h"
#import <UIKit/UIKit.h>
#import "ViewController.h"


@implementation ProtectMode

// Singleton shared instance
+ (id)sharedProtectMode {
    static ProtectMode *sharedProtectMode = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProtectMode = [[self alloc] init];
    });
    return sharedProtectMode;
}

// Init (Defaults)
- (id)init {
    if (self = [super init]) {
        // Set defaults here if need be
        [self setCurrentPolicy:nil];
        [self setTrustFactorsToWhitelist:nil];
        _trustFactorsToWhitelist = [[NSMutableArray alloc]init];
    }
    return self;
}
// Analyze attributing trustFactors
- (BOOL)analyzeResults:(Sentegrity_TrustScore_Computation *)computationResults withBaseline:(Sentegrity_Baseline_Analysis *)baselineAnalysisResults withPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    //check for errors
    if (!computationResults || computationResults == nil) {
        // Error out, no trustFactorOutputObject were able to be added
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No computationResults to analyze" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SACannotPerformAnalysis userInfo:errorDetails];
        
        // Don't return anything
        return false;
    }
    
    if (!baselineAnalysisResults || baselineAnalysisResults == nil) {
        // Error out, no trustFactorOutputObject were able to be added
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No baselineAnalysisResults to analyze" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SACannotPerformAnalysis userInfo:errorDetails];
        
        // Don't return anything
        return false;
    }
    
    if (!policy || policy == nil) {
        // Error out, no trustFactorOutputObject were able to be added
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No policy for use during result analysis" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SACannotPerformAnalysis userInfo:errorDetails];
        
        // Don't return anything
        return false;
    }
    
    if(computationResults.deviceTrusted==NO){
        
        //set policy
        [self setCurrentPolicy:policy];
    
        //run through all trustfactors that attributed to protect mode
        for(Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in baselineAnalysisResults.trustFactorOutputObjectsForProtectMode)
        {
            //find trustFactors that match the class at fault
            if([trustFactorOutputObject.trustFactor.classID integerValue] == computationResults.protectModeClassification)
            {
                
                [_trustFactorsToWhitelist addObject:trustFactorOutputObject];
                
            }
        
        }
        
            //check protect mode action
            switch (computationResults.protectModeAction) {
                case 0:
                    //do nothing but provide score to app
                    break;
                case 1:
                    [self activateProtectModeWipeWithError:error];
                    break;
                case 2:
                    [self activateProtectModeUserWithError:error];
                    break;
                case 3:
                    [self activateProtectModePolicyWithError:error];
                    break;
                default:
                    break;
            
            }
    }

    
    return true;
    
}

- (void)activateProtectModePolicyWithError:(NSError **)error{

    NSLog(@"Protect Mode: Policy");
    
    //take crypto disable action
    
    //prompt for admin pin and wait
    
    //for testing purposes
    if(![self deactivateProtectModePolicyWithPIN:@"user" withError:error]){
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error during policy protect mode deactivation" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToDeactivateProtectMode userInfo:errorDetails];
    }
    
}

- (void)activateProtectModeUserWithError:(NSError **)error{
    
    NSLog(@"Protect Mode: User");
    
    //take crypto disable action
    
    //prompt for user pin and wait
    
    //for testing purposes
    if(![self deactivateProtectModeUserWithPIN:@"user" withError:error]){
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error during user protect mode deactivation" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToDeactivateProtectMode userInfo:errorDetails];
    }
}

- (void)activateProtectModeWipeWithError:(NSError **)error{
  
    NSLog(@"Protect Mode: Wipe");
    
    //take crypto disable action
    
    //show wipe screen
    
}


- (BOOL)deactivateProtectModePolicyWithPIN:(NSString *)policyPIN withError:(NSError **)error {
    
    //check error
    if(!policyPIN || policyPIN==nil){

        // Don't return anything
        return NO;
    }
    
    if([policyPIN isEqualToString:@"admin"])
    {
        NSLog(@"Deactivating Protect Mode: Policy");
        
        //take re-enable crypto action
        
        //whitelist
        if(![self whitelistAttributingTrustFactorOutputObjectsWithError:*error]){
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Error during assertion whitelisting" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWhitelistAssertions userInfo:errorDetails];
            return NO;
        }
        
    }
    return YES;
    
}

- (BOOL)deactivateProtectModeUserWithPIN:(NSString *)userPIN withError:(NSError **)error{
    
    //check error
    if(!userPIN || userPIN==nil){
        
        // Don't return anything
        return NO;
    }
    
    if([userPIN isEqualToString:@"user"])
    {
        NSLog(@"Deactivating Protect Mode: User");
        
        //take re-enable crypto action
        
        //whitelist
        if(![self whitelistAttributingTrustFactorOutputObjectsWithError:*error]){
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Error during assertion whitelisting" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWhitelistAssertions userInfo:errorDetails];
            return NO;
        }
        

    }
    return YES;
    
}


- (BOOL)whitelistAttributingTrustFactorOutputObjectsWithError:(NSError *)error{
    
    BOOL exists=NO;
    
    //get shared stores
    Sentegrity_Assertion_Store *globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getGlobalStore:&exists withError:&error];
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getLocalStore:&exists withAppID:_currentPolicy.appID withError:&error];

    //check for errors
    if(!globalStore || globalStore == nil || !localStore || localStore==nil || _trustFactorsToWhitelist.count<1 || !exists){
        return NO;
    }
    
    // Create stored object
    Sentegrity_Stored_TrustFactor_Object *updatedStoredTrustFactorObject;
    
    
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in _trustFactorsToWhitelist)
    {
        updatedStoredTrustFactorObject = trustFactorOutputObject.storedTrustFactorObject;
        
        // Get a copy of the assertion store assertions dictionary
        NSMutableDictionary *assertionsCopy = [updatedStoredTrustFactorObject.assertions mutableCopy];
        
        //append the assertions to be whitelisted
        [assertionsCopy addEntriesFromDictionary:trustFactorOutputObject.assertionsToWhitelist];
        
        // Set the assertions back
        [updatedStoredTrustFactorObject setAssertions:[assertionsCopy copy]];
        
        //check for local
        if(trustFactorOutputObject.trustFactor.local.intValue==1)
        {
            
            //Check for matching stored assertion object in the local store
            Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:&error];
            
            //If could not find in the local store then skip
            if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists==NO) { continue;}
                
            //Try to set the storedTrustFactorObject back in the store, skip if fail
            if (![localStore replaceSingleObjectInStore:updatedStoredTrustFactorObject withError:&error]) {
                continue;
            }
            
        }
        else//global
        {
            //Check for matching stored assertion object in the local store
            Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [globalStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:&error];
            
            //If could not find in the local store then skip
            if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists==NO) { continue;}
            
            //Try to set the storedTrustFactorObject back in the store, skip if fail
            if (![globalStore replaceSingleObjectInStore:updatedStoredTrustFactorObject withError:&error]) {
                continue;
            }
        }

    }
    
    //update stores
   Sentegrity_Assertion_Store *localStoreOutput = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore withAppID:_currentPolicy.appID withError:&error];
   Sentegrity_Assertion_Store *globalStoreOutput =  [[Sentegrity_TrustFactor_Storage sharedStorage] setGlobalStore:globalStore withError:&error];
    
    if (!localStoreOutput || localStoreOutput == nil || !globalStoreOutput || globalStoreOutput == nil) {
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error writing assertion stores" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWriteStore userInfo:errorDetails];
        
        // Don't return anything
        return NO;
    }

    return YES;
    
}


@end

