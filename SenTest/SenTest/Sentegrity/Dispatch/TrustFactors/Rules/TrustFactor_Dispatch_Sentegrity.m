//
//  TrustFactor_Dispatch_Sentegrity.m
//  SenTest
//
//  Created by Walid Javed on 1/28/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "TrustFactor_Dispatch_Sentegrity.h"
#import <sys/sysctl.h>
#import <dlfcn.h>

@implementation TrustFactor_Dispatch_Sentegrity

#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR

//------------------------------------------
// Assembly interface to sysctl
//------------------------------------------

#define sysCtlSz(nm,cnt,sz)   readSys((int *)nm,cnt,NULL,sz)
#define sysCtl(nm,cnt,lst,sz) readSys((int *)nm,cnt,lst, sz)

#else

//------------------------------------------
// C interface to sysctl
//------------------------------------------

#define sysCtlSz(nm,cnt,sz)   sysctl((int *)nm,cnt,NULL,sz,NULL,0)
#define sysCtl(nm,cnt,lst,sz) sysctl((int *)nm,cnt,lst, sz,NULL,0)

#endif


// TODO: What files should we validate?
+ (Sentegrity_TrustFactor_Output_Object *)tamper:(NSArray *)payload {
    
    Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject = [[Sentegrity_TrustFactor_Output_Object alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    //library count check
    
    //checksum check
    
    //debugger check
    NSNumber* debugCheck = [self debuggerCheck];
    // Check the result
    if (!debugCheck || debugCheck == nil ) {
        // Problem during debug check
        
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    else{
        [outputArray addObject:debugCheck];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];

    return trustFactorOutputObject;
}


// Helper functions

// Check for debugger
+ (NSNumber*)debuggerCheck{
    
    #define DBGCHK_P_TRACED 0x00000800
    
    // Current process name
    int ourPID = [self getOurPID];
 
    if (ourPID == 0){ //something is wrong, didn't find our PID
        return nil;
    }
    
    //[self denyAttach];
    
    //check for P_TRACE
    
    size_t sz = sizeof(struct kinfo_proc);

    struct kinfo_proc info;
    
    memset(&info, 0, sz);
    
    int    name[4];
    
    name [0] = CTL_KERN;
    name [1] = KERN_PROC;
    name [2] = KERN_PROC_PID;
    name [3] = ourPID;
    
    if (sysCtl(name,4,&info,&sz) != 0){
        return nil; //something is wrong
    }
    
    
    if (info.kp_proc.p_flag & DBGCHK_P_TRACED) {

        NSLog(@"being debuged");
        return [NSNumber numberWithInt:DBGCHK_P_TRACED];
        
    }
    else{
        return [NSNumber numberWithInt:0];
    }

}

// Deny debug attach
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

+(void)denyAttach
{
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}



@end
