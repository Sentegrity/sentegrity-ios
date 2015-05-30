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
    }
    return self;
}
// Analyze attributing trustFactors
- (void)analyzeResults:(Sentegrity_TrustScore_Computation *)computationResults withBaseline:(Sentegrity_Baseline_Analysis *)baselineAnalysisResults withPolicy:(Sentegrity_Policy *)policy withError:(NSError *)error {
    
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
        
            //check protect mode action
            switch (computationResults.protectModeAction) {
                case 0:
                    //do nothing but provide score to app
                    break;
                case 1:
                    [self activateProtectModeWipe];
                    break;
                case 2:
                    [self activateProtectModeUser];
                    break;
                case 3:
                    [self activateProtectModePolicy];
                    break;
                default:
                    break;
            }
            
        }
    }

    NSLog(@"\n\nCore Detection Score Results: \nDevice:%d, \nSystem:%d, \nUser:%d\n\n", computationResults.deviceScore, computationResults.systemScore, computationResults.userScore );
    NSLog(@"\n\nCore Detection Trust Results: \nDevice:%d, \nSystem:%d, \nUser:%d\n\n", computationResults.deviceTrusted, computationResults.systemTrusted, computationResults.userTrusted);
    NSLog(@"\n\nErrors: %@", error.localizedDescription);
    
   
    
}

- (void)activateProtectModePolicy{

    NSLog(@"Protect Mode: Policy");
    
    //take crypto disable action
    
    //prompt for admin pin and wait
    
    //for demo purposes
    [self deactivateProtectModePolicyWithPIN:@"admin"];
    
}

- (void)activateProtectModeUser{
    
    NSLog(@"Protect Mode: User");
    
    //take crypto disable action
    
    //prompt for user pin and wait
    
    //for demo purposes
    [self deactivateProtectModeUserWithPIN:@"user"];
    
}

- (void)activateProtectModeWipe{
  
    NSLog(@"Protect Mode: Wipe");
    
    //take crypto disable action
    
    //show wipe screen
    
}


- (BOOL)deactivateProtectModePolicyWithPIN:(NSString *)policyPIN{
    
    if([policyPIN isEqualToString:@"admin"])
    {
        NSLog(@"Deactivating Protect Mode: Policy");
        
        //take re-enable crypto action
        
        //whitelist
        [self whitelistAttributingTrustFactorOutputObjects];
        
        return YES;
    }
    else{return NO;}
    
}

- (BOOL)deactivateProtectModeUserWithPIN:(NSString *)userPIN{
    
    if([userPIN isEqualToString:@"user"])
    {
        NSLog(@"Deactivating Protect Mode: User");
        
        //take re-enable crypto action
    
        //whitelist
        [self whitelistAttributingTrustFactorOutputObjects];
    
        return YES;
    }
    else{return NO;}
    
}


- (void)whitelistAttributingTrustFactorOutputObjects{
    
    BOOL exists=YES;
    NSError *error;
    
    //get shared stores
    Sentegrity_Assertion_Store *globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getGlobalStore:&exists withError:&error];
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getLocalStoreWithAppID:_currentPolicy.appID doesExist:&exists withError:&error];
    
    //check for exists and fail
    
    // Create stored object
    Sentegrity_Stored_TrustFactor_Object *updatedStoredTrustFactorObject;
    
    
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in _trustFactorsToWhitelist)
    {
        updatedStoredTrustFactorObject = trustFactorOutputObject.storedTrustFactorObject;
        //append the assertions to be whitelisted
        [updatedStoredTrustFactorObject.assertions addEntriesFromDictionary:trustFactorOutputObject.assertionsToWhitelist];
        
        //check for local
        if(trustFactorOutputObject.trustFactor.local.intValue==1)
        {
            
            //Check for matching stored assertion object in the local store
            Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:&error];
            
            //If could not find in the local store then skip
            if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists==NO) { continue;}
                
            //Try to set the storedTrustFactorObject back in the store, skip if fail
            if (![localStore setStoredTrustFactorObject:updatedStoredTrustFactorObject withError:&error]) {
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
            if (![globalStore setStoredTrustFactorObject:updatedStoredTrustFactorObject withError:&error]) {
                continue;
            }
        }

    }
    
    //update stores
    localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore forAppID:_currentPolicy.appID overwrite:YES withError:&error];
    globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] setGlobalStore:globalStore overwrite:YES withError:&error];
    
}


@end
    
