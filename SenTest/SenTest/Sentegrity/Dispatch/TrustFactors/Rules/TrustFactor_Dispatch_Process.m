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

// 2
+ (Sentegrity_TrustFactor_Output *)badProcesses:(NSArray *)processes {
    
    
    // Validate the process payload array
    if (!processes || processes.count < 1 || processes == nil) {

        // Create our return output
        Sentegrity_TrustFactor_Output *trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
        [trustFactorOutput setExecuted:NO];
        [trustFactorOutput setStatusCode:DNEStatus_error];
        
        // Return nothing
        return trustFactorOutput;
    }
    
    //populate process data if necessary (if we are the first in this dispatch to run)
    if (!processList)
        [self updateProcessList];

    // Create output array
    NSMutableArray *badProcs = [[NSMutableArray alloc] init];
    
    //hold name of current proc being analyzed
    NSString *procName;
    
    for (NSDictionary *processData in processList)
    {
        procName = [processData objectForKey:@"ProcessName"];
        
        //iterate through bad proc names provided via payload
        for (NSString *badProcName in processes)
        {
            if([badProcName isEqualToString:procName])
            {
               // NSLog(@"bad proc found");
                [badProcs addObject:procName];
            }
        }
        
            
    }
    
    // Create our return trustfactor object
    Sentegrity_TrustFactor_Output *trustFactorOutput = [[Sentegrity_TrustFactor_Output alloc] init];
    [trustFactorOutput setOutput:badProcs];
    [trustFactorOutput setExecuted:YES];
    [trustFactorOutput setStatusCode:DNEStatus_ok];
    
    //If we found bad processes generate assertions from each output (each bad processes name found)
    if(badProcs.count > 1)
    {
        [trustFactorOutput generateAssertionsFromOutput];
        return trustFactorOutput;
    }
    else  //otherwise generate one assertion using the baseline (i.e., we found no bad procs)
    {
       
        [trustFactorOutput generateBaselineAssertion];
        return trustFactorOutput;
    }


}


// 11
+ (Sentegrity_TrustFactor_Output *)newRootProcess:(NSArray *)rootprocesses {
    
    if (!processList)
        [self updateProcessList];
    return 0;
}




// 12
+ (Sentegrity_TrustFactor_Output *)badProcessPath:(NSArray *)processpaths {
    
    if (!processList)
        [self updateProcessList];
    return 0;
}




// 20
+ (Sentegrity_TrustFactor_Output *)highRiskApp:(NSArray *)riskyapps {
    
    if (!processList)
        [self updateProcessList];
    return 0;
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
