//
//  Sentegrity_Network_Manager.m
//  Sentegrity
//
//  Created by Ivo Leko on 08/04/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "Sentegrity_Network_Manager.h"
#import "Sentegrity_HTTPSessionManager.h"
#import "Sentegrity_Startup_Store.h"
#import "Sentegrity_Policy_Parser.h"
#import "Sentegrity_Startup.h"
#import "NSObject+ObjectMap.h"


@interface Sentegrity_Network_Manager()
@property (nonatomic, strong) Sentegrity_HTTPSessionManager *sessionManager;

@end

@implementation Sentegrity_Network_Manager

+ (Sentegrity_Network_Manager *) shared {
    static Sentegrity_Network_Manager* _sharedSentegrity_Network_Manager = nil;
    static dispatch_once_t onceTokenSentegrity_Network_Manager;
    
    dispatch_once(&onceTokenSentegrity_Network_Manager, ^{
        _sharedSentegrity_Network_Manager = [[Sentegrity_Network_Manager alloc] init];
        
        //create our session manager based on AFNetworking
        _sharedSentegrity_Network_Manager.sessionManager = [[Sentegrity_HTTPSessionManager alloc] init];
        
    });
    
    return _sharedSentegrity_Network_Manager;
}



- (void) uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback: (RunHistoryBlock) callback {
    
    NSError *error;
    
    //get current startup
    Sentegrity_Startup *currentStartup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
    
    //if any error, stop it
    if (error) {
        if (callback)
            callback(NO, NO, NO, error);
        return;
    }
    
    //get current policy
    Sentegrity_Policy *currentPolicy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
    
    //if any error, stop it
    if (error) {
        if (callback)
            callback(NO, NO, NO, error);
        return;
    }
    
    //check if any runHistoryObjects exists (for example, it will be 0 if running app for the first time)
    if (currentStartup.runHistoryObjects.count == 0) {
        if (callback)
            callback(YES, NO, NO, nil);
        return;
    }
    
    //get current runCount, because it can be changed while waiting for server response
    NSInteger runCount = currentStartup.runCount;
    
    
    BOOL needToUploadData;
    
    // check if run count from last upload is higher/equal than defined upload run frequency in policy
    if (currentPolicy.statusUploadRunFrequency.integerValue
        <= (runCount - currentStartup.runCountAtLastUpload)) {
        needToUploadData = YES;
    }
    
    // check if delta time from last upload is higher than time defined in policy. If this is first upload, it will also proceed.
    else if ((currentPolicy.statusUploadTimeFrequency.integerValue * 86400.0)
        <= ([[NSDate date] timeIntervalSince1970] - [currentStartup dateTimeOfLastUpload])) {
        needToUploadData = YES;
    }
        
    
    if (needToUploadData) {
        
        //get JSONObject of entire startup (needed later)
        id currentStartupJSONobject = [NSJSONSerialization JSONObjectWithData:[currentStartup JSONData] options:kNilOptions error:nil];
        
        // prepare dictionary (JSON) for sending
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        //need to add history objects
        NSArray *oldRunHistoryObjects = [NSArray arrayWithArray: currentStartup.runHistoryObjects];
    
        //get runHistoryObjects as array of dictionary (for succesful transition to JSON)
        [dic setObject:currentStartupJSONobject[@"runHistoryObjects"] forKey:@"runHistoryObjects"];
        
        
        //get email
        NSString *email = currentStartup.email;
        if (!email)
            email = @"";
        
        //policy information
        [dic setObject:currentPolicy.revision forKey:@"policyRevision"];
        [dic setObject:currentPolicy.policyID forKey:@"policyID"];
        [dic setObject:email forKey:@"email"];

        //device salt
        [dic setObject:currentStartup.deviceSaltString forKey:@"deviceSalt"];

        [self.sessionManager uploadReport:dic withCallback:^(BOOL success, NSDictionary *responseObject, NSError *error) {
            if (!success) {
                //request failed
                if (callback)
                    callback (NO, NO, NO, error);
            }
            else {
                //succesfully uploaded, need to update status variables
                currentStartup.dateTimeOfLastUpload = [[NSDate date] timeIntervalSince1970];
                currentStartup.runCountAtLastUpload = runCount;
                
                //need to remove old run history objects
                [self removeOldRunHistoryObjects:oldRunHistoryObjects fromStartup:currentStartup];
                
                
                NSDictionary *newPolicy = responseObject[@"data"][@"newPolicy"];
                if (newPolicy && ![newPolicy isEqual:[NSNull null]]) {
                    
                    // new policy exists, need to replace old policy with this one
                    Sentegrity_Policy *policy = [[Sentegrity_Policy_Parser sharedPolicy] parsePolicyJSONobject:newPolicy withError:&error];
                    
                    if (error) {
                        //something went wrong...
                        if (callback)
                            callback (NO, YES, NO, error);
                        
                        return;
                    }
                    
                    // save new policy
                    [[Sentegrity_Policy_Parser sharedPolicy] saveNewPolicy:policy withError:&error];
                    
                    if (error) {
                        //something went wrong...
                        if (callback)
                            callback (NO, YES, NO, error);
                        
                        return;
                    }
                    
                    //everything succesfull
                    if (callback) {
                        //if we got new policy that specified we should use private APIs set new flag to NSUserDefaults
                        if ([policy.allowPrivateAPIs intValue]==1) {
                            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"allowPrivate"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        
                        callback (YES, YES, YES, nil);
                    }
                }
                else {
                    //succesfully uploaded, but there is no new policy
                    if (callback)
                        callback (YES, YES, NO, nil);
                }
            }
        }];
    }
    else {
        // do not need to upload
        if (callback)
            callback (YES, NO, NO, nil);
    }
}

- (void) removeOldRunHistoryObjects: (NSArray *) oldRunHistoryObjects fromStartup: (Sentegrity_Startup *) startup  {
    
    //current runHistoryObjects
    NSMutableArray *currentRunHistoryObjects = [NSMutableArray arrayWithArray: startup.runHistoryObjects];
   
    //remove old objects (that are already sent) from array
    [currentRunHistoryObjects removeObjectsInArray:oldRunHistoryObjects];
    
    startup.runHistoryObjects = [NSArray arrayWithArray:currentRunHistoryObjects];
}

@end
