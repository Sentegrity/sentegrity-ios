//
//  TrustFactor_Dispatch.m
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"

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


// Import sysctl - For Processes
@implementation Sentegrity_TrustFactor_Rule

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

// PROCESS: Process info
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
                        return processData;
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

// PROCESS: PID Info
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


//NETWORKING


// Route Data
static NSArray* routeData;
+ (NSArray *)routeData {
    
    if(!routeData || routeData==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            routeData = [Route_Info getRoutes];
            return routeData;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
    }
    else //already populated
    {
        return routeData;
    }
}

// Get Current IP Address
+ (NSString *)currentIPAddress {
    // Get the current IP Address
    
    // Check which interface is currently in use
    if ([self connectedToWiFi]) {
        // WiFi is in use
        
        // Get the WiFi IP Address
        NSString *WiFiAddress = [self wiFiIPAddress];
        
        // Check that you get something back
        if (WiFiAddress == nil || WiFiAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Wifi address
        return WiFiAddress;
    } else if ([self connectedToCellNetwork]) {
        // Cell Network is in use
        
        // Get the Cell IP Address
        NSString *CellAddress = [self cellIPAddress];
        
        // Check that you get something back
        if (CellAddress == nil || CellAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Cell address
        return CellAddress;
    } else {
        // No interface in use
        return nil;
    }
}

// Get the External IP Address
+ (NSString *)externalIPAddress {
    @try {
        // Check if we have an internet connection then try to get the External IP Address
        if (![self connectedToCellNetwork] && ![self connectedToWiFi]) {
            // Not connected to anything, return nil
            return nil;
        }
        
        // Get the external IP Address based on dynsns.org
        NSError *error = nil;
        NSString *theIpHtml = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        if (!error) {
            NSUInteger  an_Integer;
            NSArray * ipItemsArray;
            NSString *externalIP;
            NSScanner *theScanner;
            NSString *text = nil;
            
            theScanner = [NSScanner scannerWithString:theIpHtml];
            
            while ([theScanner isAtEnd] == NO) {
                
                // find start of tag
                [theScanner scanUpToString:@"<" intoString:NULL] ;
                
                // find end of tag
                [theScanner scanUpToString:@">" intoString:&text] ;
                
                // replace the found tag with a space
                //(you can filter multi-spaces out later if you wish)
                theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:
                             [ NSString stringWithFormat:@"%@>", text]
                                                                 withString:@" "] ;
                ipItemsArray = [theIpHtml  componentsSeparatedByString:@" "];
                an_Integer = [ipItemsArray indexOfObject:@"Address:"];
                
                externalIP =[ipItemsArray objectAtIndex:++an_Integer];
            }
            
            // Check that you get something back
            if (externalIP == nil || externalIP.length <= 0) {
                // Error, no address found
                return nil;
            }
            
            // Return External IP
            return externalIP;
        } else {
            // Error, no address found
            return nil;
        }
    }
    @catch (NSException *exception) {
        // Error, no address found
        return nil;
    }
}

// Get Cell IP Address
+ (NSString *)cellIPAddress {
    // Get the Cell IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        struct sockaddr_in *s4;
        char buf[64];
        
        // If it's 0, then it's good
        if (!getifaddrs(&Interfaces))
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is Cell
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"pdp_ip0"])
                    {
                        s4 = (struct sockaddr_in *)Temp->ifa_addr;
                        
                        if (inet_ntop(Temp->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL) {
                            // Failed to find it
                            IPAddress = nil;
                        } else {
                            // Got the Cell IP Address
                            IPAddress = [NSString stringWithUTF8String:buf];
                        }
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Get WiFi IP Address
+ (NSString *)wiFiIPAddress {
    // Get the WiFi IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        // Set up int for success or fail
        int Status = 0;
        
        // Get all the network interfaces
        Status = getifaddrs(&Interfaces);
        
        // If it's 0, then it's good
        if (Status == 0)
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is WiFi
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"en0"])
                    {
                        // Get the WiFi IP Address
                        IPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)Temp->ifa_addr)->sin_addr)];
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Connected to WiFi?
+ (BOOL)connectedToWiFi {
    // Check if we're connected to WiFi
    NSString *WiFiAddress = [self wiFiIPAddress];
    // Check if the string is populated
    if (WiFiAddress == nil || WiFiAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // WiFi in use
        return true;
    }
}

// Connected to Cellular Network?
+ (BOOL)connectedToCellNetwork {
    // Check if we're connected to cell network
    NSString *CellAddress = [self cellIPAddress];
    // Check if the string is populated
    if (CellAddress == nil || CellAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // Cellular Network in use
        return true;
    }
}

+ (NSString *)wiFiRouterAddress {
    // Get the WiFi Router Address
    @try {
        // Set the ip address variable
        NSString *routerIP = nil;
        // Set the router array variable with the routing information
        NSArray *routeArray = [Route_Info getRoutes];
        
        // Return the first route which will be WiFi if it is connected
        routerIP = [[routeArray objectAtIndex:0] objectForKey:@"Gateway"];
        
        return routerIP;
        
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}


@end

@implementation Route_Info

-initWithRtm: (struct rt_msghdr2*) rtm
{
    int i;
    struct sockaddr* sa = (struct sockaddr*)(rtm + 1);
    
    memcpy(&(m_rtm), rtm, sizeof(struct rt_msghdr2));
    for(i = 0; i < RTAX_MAX; i++)
    {
        [self setAddr:&(sa[i]) index:i];
    }
    
    return self;
}

// Class Methods
+ (NSArray*) getRoutes
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    Route_Info* route = nil;
    
    size_t len;
    int mib[6];
    char *buf;
    register struct rt_msghdr2 *rtm;
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = 0;
    mib[4] = NET_RT_DUMP2;
    mib[5] = 0;
    
    sysctl(mib, 6, NULL, &len, NULL, 0);
    buf = malloc(len);
    if (buf && sysctl(mib, 6, buf, &len, NULL, 0) == 0)
    {
        
        
        for (char * ptr = buf; ptr < buf + len; ptr += rtm->rtm_msglen)
        {
            rtm = (struct rt_msghdr2 *)ptr;
            route = [self getRoute:rtm];
            if(route != nil)
            {
                NSString *interface = [route getInterface];
                NSString *gateway = [route getGateway];
                int defaultRouteCheck = 0;
                
                if([[route getDestination] isEqualToString:@"default"]){
                    defaultRouteCheck = 1;
                }
                
                NSNumber *defaultRoute = [[NSNumber alloc] initWithInt:defaultRouteCheck];
                
                // Create an array of the objects
                NSArray *ItemArray = [NSArray arrayWithObjects:defaultRoute,gateway,interface, nil];
                
                // Create an array of keys
                NSArray *KeyArray = [NSArray arrayWithObjects:@"IsDefault", @"Gateway", @"Interface", nil];
                // Example: isDefault (0 or 1), Gateway = 127.0.0.1 (or link#4), Interface = en0
                
                // Create the dictionary
                NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                
                // Add the objects to the array
                [array addObject:dict];
                
            }
        }
        
        free(buf);
    }
    
    return array;
}


+ (Route_Info*) getRoute:(struct rt_msghdr2 *)rtm
{
    //sockaddr are after the message header
    struct sockaddr* dst_sa = (struct sockaddr *)(rtm + 1);
    Route_Info* route = nil;
    
    if(rtm->rtm_addrs & RTA_DST)
    {
        if(dst_sa->sa_family == AF_INET && !((rtm->rtm_flags & RTF_WASCLONED) && (rtm->rtm_parentflags & RTF_PRCLONING)))
        {
            route = [[Route_Info alloc] initWithRtm:rtm];
        }
    }
    
    return route;
}

// Instance Methods

-(void) setAddr:(struct sockaddr*)sa index:(int)rtax_index
{
    if(rtax_index >= 0 && rtax_index < RTAX_MAX)
    {
        memcpy(&(m_addrs[rtax_index]), sa, sizeof(struct sockaddr));
    }
}

-(NSString*) getDestination
{
    return [self getAddrStringByIndex:RTAX_DST];
}

-(NSString*) getNetmask
{
    return [self getAddrStringByIndex:RTAX_NETMASK];
}

-(NSString*) getGateway
{
    return [self getAddrStringByIndex:RTAX_GATEWAY];
}

-(NSString*) getInterface
{
    char ifName[128];
    memset(ifName, 0, sizeof(ifName));
    if_indextoname(m_rtm.rtm_index,ifName);
    
    return [NSString stringWithFormat:@"%s", ifName];
}


-(NSString*) getAddrStringByIndex: (int)rtax_index
{
    NSString * routeString = nil;
    struct sockaddr* sa = &(m_addrs[rtax_index]);
    int flagVal = 1 << rtax_index;
    
    if(!(m_rtm.rtm_addrs & flagVal))
    {
        return nil;
    }
    
    if(rtax_index >= 0 && rtax_index < RTAX_MAX)
    {
        switch(sa->sa_family)
        {
            case AF_INET:
            {
                struct sockaddr_in* si = (struct sockaddr_in *)sa;
                if(si->sin_addr.s_addr == INADDR_ANY)
                    routeString = @"default";
                else
                    routeString = [NSString stringWithCString:(char *)inet_ntoa(si->sin_addr) encoding:NSASCIIStringEncoding];
            }
                break;
                
            case AF_LINK:
            {
                struct sockaddr_dl* sdl = (struct sockaddr_dl*)sa;
                if(sdl->sdl_nlen + sdl->sdl_alen + sdl->sdl_slen == 0)
                {
                    routeString = [NSString stringWithFormat: @"link #%d", sdl->sdl_index];
                }
                else
                    routeString = [NSString stringWithCString:link_ntoa(sdl) encoding:NSASCIIStringEncoding];
            }
                break;
                
            default:
            {
                char a[3 * sa->sa_len];
                char *cp;
                char *sep = "";
                int i;
                
                if(sa->sa_len == 0)
                {
                    routeString = nil;
                }
                else
                {
                    a[0] = '\0';
                    for(i = 0, cp = a; i < sa->sa_len; i++)
                    {
                        cp += sprintf(cp, "%s%02x", sep, (unsigned char)sa->sa_data[i]);
                        sep = ":";
                    }
                    routeString = [NSString stringWithCString:a encoding:NSASCIIStringEncoding];
                }
            }
        }
    }
    
    return routeString;
}

@end
