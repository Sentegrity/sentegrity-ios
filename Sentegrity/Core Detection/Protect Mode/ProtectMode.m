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
        // Error
        return NO;
    }
    
    if([[policyPIN lowercaseString] isEqualToString:@"admin"])
    {
        NSLog(@"Deactivating Protect Mode: Admin");
        
        if(trustFactorsToWhitelist.count>0){
            
            //whitelist
            if([self whitelistAttributingTrustFactorOutputObjects]==NO){
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Error during assertion whitelisting" forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                
                return NO;
            }
            
        }
        
        
        return YES;
        
    }
    else{
        return NO;
    }
    
    
}

- (BOOL)deactivateProtectModeUserWithPIN:(NSString *)userPIN {
    
    NSError *error;
    
    //check error
    if(!userPIN || userPIN==nil){
        // Error
        return NO;
    }
    
    if([[userPIN lowercaseString] isEqualToString:@"user"])
    {
        NSLog(@"Deactivating Protect Mode: User");
        
        if(trustFactorsToWhitelist.count>0){
            
            //whitelist
            if([self whitelistAttributingTrustFactorOutputObjects]==NO){
                NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
                [errorDetails setValue:@"Error during assertion whitelisting" forKey:NSLocalizedDescriptionKey];
                error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                
                return NO;
            }
            
        }
        
        
        return YES;
        
    }
    else{
        return NO;
    }
    
}



- (BOOL)whitelistAttributingTrustFactorOutputObjects{
    
    NSError *error;
    
    BOOL exists=NO;
    
    //get shared stores
    Sentegrity_Assertion_Store *localStore = [[Sentegrity_TrustFactor_Storage sharedStorage] getLocalStore:&exists withAppID:policy.appID withError:&error];
    
    //check for errors
    if(!localStore || localStore==nil || !exists){
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error writing local assertion store" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWriteStore userInfo:errorDetails];
        return NO;
    }
    
    
    NSArray *existingStoredAssertionObjects = [NSArray array];
    NSArray *mergedStoredAssertionObjects = [NSArray array];
    
    
    for (Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in trustFactorsToWhitelist)
    {
        // Make sure assertionObjects is not empty or we cant merge
        if(trustFactorOutputObject.storedTrustFactorObject.assertionObjects==nil){
            
            trustFactorOutputObject.storedTrustFactorObject.assertionObjects = trustFactorOutputObject.assertionObjectsToWhitelist;
            
        }else{ // merge
            
            existingStoredAssertionObjects = trustFactorOutputObject.storedTrustFactorObject.assertionObjects;
            mergedStoredAssertionObjects = [existingStoredAssertionObjects arrayByAddingObjectsFromArray:trustFactorOutputObject.assertionObjectsToWhitelist];
            
            //Set the merged list back to storedTrustFactorObject
            trustFactorOutputObject.storedTrustFactorObject.assertionObjects = mergedStoredAssertionObjects;
        }
        
        
        //Check for matching stored assertion object in the local store
        Sentegrity_Stored_TrustFactor_Object *storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:&error];
        
        //If could not find in the local store then skip
        if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists==NO) { continue;}
        
        //Try to set the storedTrustFactorObject back in the store, skip if fail
        if (![localStore replaceSingleObjectInStore:trustFactorOutputObject.storedTrustFactorObject withError:&error]) {
            continue;
        }
        
        
    }
    
    //update stores
    Sentegrity_Assertion_Store *localStoreOutput = [[Sentegrity_TrustFactor_Storage sharedStorage] setLocalStore:localStore withAppID:policy.appID withError:&error];
    
    if (!localStoreOutput || localStoreOutput == nil ) {
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"Error writing local assertion store" forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"Sentegrity" code:SAUnableToWriteStore userInfo:errorDetails];
        
        return NO;
        
    }
    
    return YES;
    
    
}


@end

