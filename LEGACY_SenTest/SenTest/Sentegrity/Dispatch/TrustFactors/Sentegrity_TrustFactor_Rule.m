//
//  TrustFactor_Dispatch.m
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

// Import sysctl - For Processes
#import <sys/sysctl.h>

@implementation Sentegrity_TrustFactor_Rule

#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR

//------------------------------------------
// Assembly level interface to sysctl
//------------------------------------------

#define sysCtlSz(nm,cnt,sz)   readSys((int *)nm,cnt,NULL,sz)
#define sysCtl(nm,cnt,lst,sz) readSys((int *)nm,cnt,lst, sz)

#else

//------------------------------------------
// C level interface to sysctl
//------------------------------------------

#define sysCtlSz(nm,cnt,sz)   sysctl((int *)nm,cnt,NULL,sz,NULL,0)
#define sysCtl(nm,cnt,lst,sz) sysctl((int *)nm,cnt,lst, sz,NULL,0)

#endif

/* Default Rule Implementation */
/*
 // Create the trustfactor output object
 Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
 
 // Set the default status code to OK (default = DNEStatus_ok)
 [trustFactorOutputObject setStatusCode:DNEStatus_ok];
 
 // Validate the payload
 if (![self validatePayload:payload]) {
 // Payload is EMPTY
 
 // Set the DNE status code to NODATA
 [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
 
 // Return with the blank output object
 return trustFactorOutputObject;
 }
 
 // Create the output array
 NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
 
 
 // Set the trustfactor output to the output array (regardless if empty)
 [trustFactorOutputObject setOutput:outputArray];
 
 // Return the trustfactor output object
 return trustFactorOutputObject;
*/

//Return ourPID for TFs like debug
static NSString* ourName;
static int ourPID=0;
+ (int)getOurPID{
    
    //check if we're populated, otherwise processInformation has not run yet (this would only happen if a TF seeking PID happens to run before any other regular process TFs)
    if(ourPID==0){
        [self processInformation];
    }
    
    //return PID
    return ourPID;
}

// Validate the given payload
+ (BOOL)validatePayload:(NSArray *)payload {
 
    // Check if the payload is empty
    if (!payload || payload == nil || payload.count < 1) {
        return NO;
    }
    
    // Return Valid
    return YES;
}

// List of process information including PID's, Names, PPID's, and Status'
static NSArray* processData;
+ (NSArray *)processInformation {
    
    if(!processData || processData==nil) //dataset not populated
    {
        //Get bundle name and set
        ourName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
        // Get the list of processes and all information about them
        @try {
            // Make a new integer array holding all the kernel processes
            int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        
            // Make a new size of 4
            size_t miblen = 4;
        
            size_t size = 0;
            int st = sysCtl(mib, (int)miblen, NULL, &size);
        
            // Set up the processes and new process struct
            struct kinfo_proc *process = NULL;
            struct kinfo_proc *newprocess = NULL;
        
            // do, while loop rnning through all the processes
            do {
                size += size / 10;
                newprocess = realloc(process, size);
            
                if (!newprocess) {
                    if (process) free(process);
                    // Error
                    return nil;
                }
            
                process = newprocess;
                st = sysCtl(mib, (int)miblen, process, &size);
            
            } while (st == -1 && errno == ENOMEM);
        
            if (st == 0) {
                if (size % sizeof(struct kinfo_proc) == 0) {
                    int nprocess = (int)(size / sizeof(struct kinfo_proc));
                
                    if (nprocess) {
                        NSMutableArray *array = [[NSMutableArray alloc] init];
                    
                        for (int i = nprocess - 1; i >= 0; i--) {
                        
                            NSString *processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                            NSString *processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                            NSString *processPriority = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_priority];
                            NSDate   *processStartDate = [NSDate dateWithTimeIntervalSince1970:process[i].kp_proc.p_un.__p_starttime.tv_sec];
                            NSString       *processParentID = [[NSString alloc] initWithFormat:@"%d", [self parentPIDForProcess:(int)process[i].kp_proc.p_pid]];
                            NSString       *processStatus = [[NSString alloc] initWithFormat:@"%d", (int)process[i].kp_proc.p_stat];
                            NSString       *processFlags = [[NSString alloc] initWithFormat:@"%d", (int)process[i].kp_proc.p_flag];
                        
                            // Check to make sure all values are valid (if not, make them)
                            if (processID == nil || processID.length <= 0) {
                                // Invalid value
                                processID = @"Unknown";
                            }
                            if (processName == nil || processName.length <= 0) {
                                // Invalid value
                                processName = @"Unknown";
                            }
                            if (processPriority == nil || processPriority.length <= 0) {
                                // Invalid value
                                processPriority = @"Unknown";
                            }
                            if (processStartDate == nil) {
                                // Invalid value
                                processStartDate = [NSDate date];
                            }
                            if (processParentID == nil || processParentID.length <= 0) {
                                // Invalid value
                                processParentID = @"Unknown";
                            }
                            if (processStatus == nil || processStatus.length <= 0) {
                                // Invalid value
                                processStatus = @"Unknown";
                            }
                            if (processFlags == nil || processFlags.length <= 0) {
                                // Invalid value
                                processFlags = @"Unknown";
                            }
                        
                            // Create an array of the objects
                            NSArray *ItemArray = [NSArray arrayWithObjects:processID, processName, processPriority, processStartDate, processParentID, processStatus, processFlags, nil];
                        
                            // Create an array of keys
                            NSArray *KeyArray = [NSArray arrayWithObjects:@"PID", @"Name", @"Priority", @"StartDate", @"ParentID", @"Status", @"Flags", nil];
                        
                            // Create the dictionary
                            NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                        
                            // Add the objects to the array
                            [array addObject:dict];
                        
                            //check if this is our process and record PID
                            if([ourName isEqualToString:processName]) {
                                ourPID = process[i].kp_proc.p_pid;
                            }
                        }
                    
                        // Make sure the array is usable
                        if (array.count <= 0) {
                            // Error, nothing in array
                            return nil;
                        }
                    
                        // Free the process
                        free(process);
                    
                        // Successful
                        
                        // Set static var for dataset
                        processData = array;
                        
                        //return
                        return array;
                    }
                }
            }
        
            // Something failed
            return nil;
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
    }
    else //already populated
    {
        return processData;
    }
}

// Parent ID for a certain PID
+ (int)parentPIDForProcess:(int)pid {
    // Get the parent ID for a certain process
    @try {
        // Set up the variables
        struct kinfo_proc info;
        size_t length = sizeof(struct kinfo_proc);
        int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, pid };
        
        if (sysCtl(mib, 4, &info, &length) < 0)
            // Unknown value
            return -1;
        
        if (length == 0)
            // Unknown value
            return -1;
        
        // Make an int for the PPID
        int PPID = info.kp_eproc.e_ppid;
        
        // Check to make sure it's valid
        if (PPID <= 0) {
            // No PPID found
            return -1;
        }
        
        // Successful
        return PPID;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Get the current platform version ID

static NSString *platformVersion;
+ (NSString*)platformVersion {

    return nil;

}

@end
