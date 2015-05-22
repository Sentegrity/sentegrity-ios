//
//  TrustFactor_Dispatch_Process.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Process.h"
#import <sys/sysctl.h>

static NSMutableArray *processList;

@implementation TrustFactor_Dispatch_Process


//Implementations

+ (Sentegrity_TrustFactor_Output_Object *)knownBad:(NSArray *)payload {
    
    //CREATE RETURN OBJECT
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    //SET REUSABLE DATA ACQUISITION METHOD
    if (!processList)
        [self updateProcessList];

    //CREATE OUTPUT ARRAY
    NSMutableArray *output = [[NSMutableArray alloc] init];
    
    
    //hold name of current proc being analyzed
    NSString *procName;
    
    for (NSDictionary *processData in processList)
    {
        procName = [processData objectForKey:@"ProcessName"];
        //iterate through bad proc names provided via payload
        for (NSString *badProcName in payload)
        {
            if([badProcName isEqualToString:procName])
            {
               //make sure we don't add more than one instance of the proc
                if (![output containsObject:procName])
                [output addObject:procName];
                
            }
        }
        
            
    }
    
    //SET OUTPUT (regardless if empty)
    [trustFactorOutputObject setOutput:output];
    
    //OVERRIDE STATUS CODE (default = DNEStatus_ok)
    
    
    //RETURN
    return trustFactorOutputObject;

}

+ (Sentegrity_TrustFactor_Output_Object *)newRoot:(NSArray *)payload {
    
    //CREATE RETURN OBJECT
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    //SET REUSABLE DATA ACQUISITION METHOD
    if (!processList)
        [self updateProcessList];
    
    //CREATE OUTPUT ARRAY
    NSMutableArray *output = [[NSMutableArray alloc] init];
    
    
    //[*****TBD*****]
    
    
    //SET OUTPUT (regardless if empty)
    [trustFactorOutputObject setOutput:output];
    
    //OVERRIDE STATUS CODE (default = DNEStatus_ok)
    
    
    //RETURN
    return trustFactorOutputObject;
}


+ (Sentegrity_TrustFactor_Output_Object *)highRiskApp:(NSArray *)payload {
    
    //CREATE RETURN OBJECT
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    //SET REUSABLE DATA ACQUISITION METHOD
    if (!processList)
        [self updateProcessList];
    
    //CREATE OUTPUT ARRAY
    NSMutableArray *output = [[NSMutableArray alloc] init];
    
    
    //[*****TBD*****]
    
    
    //SET OUTPUT (regardless if empty)
    [trustFactorOutputObject setOutput:output];
    
    //OVERRIDE STATUS CODE (default = DNEStatus_ok)
    
    
    //RETURN
    return trustFactorOutputObject;
}


//Acquisition Helpers
+ (BOOL)updateProcessList {

    //general process info
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
    size_t size;
    int st = sysctl(mib, (int)miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    //*** process path MIB info, broken ***
    
    //get buffer size
    //int mib2[3] = {CTL_KERN, KERN_ARGMAX, 0};
    //size_t argmaxsize = sizeof(size_t);
    //size_t size2;
    //int ret = sysctl(mib2, 2, &size2, &argmaxsize, NULL, 0);
    
    //if (ret != 0) {
    //    NSLog(@"Error '%s' (%d) getting KERN_ARGMAX", strerror(errno), errno);
    //    return nil;
    //}
    
    //get info for each process in list
    
    do {
        
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess){
            
            if (process){
                free(process);
            }
            
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, (int)miblen, process, &size, NULL, 0);
        
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = (int)size / sizeof(struct kinfo_proc);
            
            if (nprocess){
                
                //init if not already
                if (!processList)
                    processList = [[NSMutableArray alloc] init];
                
                
                for (int i = nprocess - 1; i >= 0; i--){
                    
                    //process ID
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    
                    //process name
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    
                    //process user ID
                    NSNumber * processUID = [NSNumber numberWithInt:process[i].kp_eproc.e_ucred.cr_uid];
                    
                    //*** process path, broken ***
                    //get the path information we actually want
                    //mib2[1] = KERN_PROCARGS2;
                    //mib2[2] = (int)process[i].kp_proc.p_pid;
                    
                    //char *procargv = malloc(size2);
                    //ret = sysctl(mib2, 3, procargv, &size2, NULL, 0);
                    
                    //if (ret != 0) {
                    //    NSLog(@"Error '%s' (%d) for pid %d", strerror(errno), errno, process[i].kp_proc.p_pid);
                    //   free(procargv);
                    //   return nil;
                    //}
                    
                    // procargv is actually a data structure.
                    // The path is at procargv + sizeof(int)
                    //NSString *processPath = [NSString stringWithCString:(procargv + sizeof(int))
                    //                                    encoding:NSASCIIStringEncoding];
                    
                    //free(procargv);
                    
                    //dict of info
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, processUID, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName", @"ProcessUID", nil]];

                    [processList addObject:dict];

                }
                
                free(process);
                return 1;
            }
        }
    }
    
    return 0;
    
}


@end
