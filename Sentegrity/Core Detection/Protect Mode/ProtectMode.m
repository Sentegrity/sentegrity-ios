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
#import "SCLAlertView.h"


@implementation ProtectMode

static Sentegrity_Policy *policy;

static NSArray *trustFactorsToWhitelist;

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
        [self setPolicy:nil];
        [self setTrustFactorsToWhitelist:nil];
        trustFactorsToWhitelist = [[NSMutableArray alloc]init];
    }
    return self;
}


- (void)setTrustFactorsToWhitelist:(NSArray *)trustFactorsToWhitelist1{
    
    trustFactorsToWhitelist = trustFactorsToWhitelist1;
}

- (void)setPolicy:(Sentegrity_Policy *)policy1{
    
    policy = policy1;
}

- (void)activateProtectModePolicy{
    
    NSLog(@"Protect Mode: Policy Executed");
    
}

- (void)activateProtectModeUser{
    

    NSLog(@"Protect Mode: User Executed");
    
    //take crypto disable action
    
    //prompt for user pin and wait
    
}

- (void)activateProtectModeWipe{
  
    NSLog(@"Protect Mode: Wipe Executed");
    
    //take crypto disable action
    
    //show wipe screen
    
}


- (BOOL)deactivateProtectModePolicyWithPIN:(NSString *)policyPIN {
    
    NSError *error;
    
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
        if(![self whitelistAttributingTrustFactorOutputObjects]){
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Error during assertion whitelisting" forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWhitelistAssertions userInfo:errorDetails];
            return NO;
        }
        return YES;
        
    }
    
    return NO;

    
}

- (BOOL)deactivateProtectModeUserWithPIN:(NSString *)userPIN {
    
    NSError *error;
    
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
        if(![self whitelistAttributingTrustFactorOutputObjects]){
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"Error during assertion whitelisting" forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWhitelistAssertions userInfo:errorDetails];
            return NO;
        }
        
        return YES;
    }
    
    return NO;
    
}



- (BOOL)whitelistAttributingTrustFactorOutputObjects{
    
    NSError *error;
    
    BOOL exists=NO;
    
    //get shared stores
    Sentegrity_Assertion_Store *globalStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getGlobalStore:&exists withError:&error];
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getLocalStore:&exists withAppID:policy.appID withError:&error];

    //check for errors
    if(!globalStore || globalStore == nil || !localStore || localStore==nil || trustFactorsToWhitelist.count<1 || !exists){
        return NO;
    }
    
    // Create stored object
    Sentegrity_Stored_TrustFactor_Object *updatedStoredTrustFactorObject;
    
    
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorsToWhitelist)
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
   Sentegrity_Assertion_Store *localStoreOutput = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore withAppID:policy.appID withError:&error];
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

