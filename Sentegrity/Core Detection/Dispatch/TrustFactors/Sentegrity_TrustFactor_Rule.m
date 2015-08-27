//
//  TrustFactor_Dispatch.m
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Rule.h"


// This class is designed to cache the results of datasets between the TrustFactor_Dispatch_[Rule] and Sentegrity_TrustFactor_Dataset_[Category]

@implementation Sentegrity_TrustFactor_Rule


// Share payload validation routine for TFs that should have payload items
+ (BOOL)validatePayload:(NSArray *)payload {
    
    // Check if the payload is empty
    if (!payload || payload == nil || payload.count < 1) {
        return NO;
    }
    
    // Return Valid
    return YES;
}

// CPU usage
static float cpuUsage;
+ (float)CPUUsage{
    
    if(!cpuUsage) //dataset not populated
    {
        cpuUsage = [CPU_Info getCPUUsage];
        
        return cpuUsage;
        
    }else
    {
        return cpuUsage;
    }
    
    
}

// Battery state
static NSString* batteryState;
+ (NSString *)batteryState{
    
    if(!batteryState || batteryState == nil) //dataset not populated
    {
        UIDevice *Device = [UIDevice currentDevice];
        
        Device.batteryMonitoringEnabled = YES;
        
        UIDeviceBatteryState battery = [Device batteryState];
        NSString* state;
        
        switch (battery) {
            case UIDeviceBatteryStateCharging:
                state = @"pluggedCharging"; // plugged in, less than 100%
                break;
            case UIDeviceBatteryStateFull:
                state = @"pluggedFull"; // plugged in, at 100%
                break;
            case UIDeviceBatteryStateUnplugged:
                state = @"unplugged"; // on battery, discharging
                break;
            default:
                state = @"unknown";
                break;
        }
        
        batteryState = state;
        
        return batteryState;
        
    }else
    {
        return batteryState;
    }
    
}


// Time of day
static NSString* timeDateString;
+ (NSString *)timeDateString{
    
    if(!timeDateString || timeDateString==nil) //dataset not populated
    {
        //day of week
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSInteger dayOfWeek = [comps weekday];
        
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
        NSInteger hourOfDay = [components hour];
        NSInteger minutes = [components minute];
        
        
        //round up if needed
        if(minutes > 30){
            hourOfDay = hourOfDay+1;
        }
        
    
        
        // Hours partitioned across 24, adjust accordingly but it does impact multiple rules
        NSInteger blocksize = 6;
        
        NSInteger blockOfDay = floor(hourOfDay / (24/blocksize))+1;
        
        NSString *string =  [NSString stringWithFormat:@"D%ld-H%ld",(long)dayOfWeek,(long)blockOfDay];

        // set it
        timeDateString = string;
        
        return timeDateString;

    }else
    {
        return timeDateString;
    }
    
}


// Application dataset caching

static NSArray* userAppInfo;
+ (NSArray *)userAppInfo {
    
    if(!userAppInfo || userAppInfo==nil) //dataset not populated
    {
        // Get the list of user apps
        @try {
            
            userAppInfo = [App_Info getUserAppInfo];
            return userAppInfo;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return userAppInfo;
    }
}



// Process dataset caching

static NSArray* processData;
+ (NSArray *)processInfo {
    
    if(!processData || processData==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            processData = [Process_Info getProcessInfo];
            return processData;
            
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

static NSNumber *ourPID;
+ (NSNumber *)getOurPID {
      // Get the PID 
      @try {
          
          ourPID = [Process_Info getOurPID];
          return ourPID;
          
      }
      @catch (NSException * ex) {
          // Error
          return nil;
      }
}



// Route dataset caching

static NSArray* routeData;
+ (NSArray *)routeInfo {
    
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


// dataXfer count dataset caching

static NSDictionary* dataXferInfo;
+ (NSDictionary *)dataXferInfo {
    
    if(!dataXferInfo || dataXferInfo==nil) //dataset not populated
    {
        
        @try {
            
            dataXferInfo = [Netstat_Info getInterfaceBytes];
            return dataXferInfo;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return dataXferInfo;
    }
}

// Netstat dataset caching

static NSArray* netstatData;
+ (NSArray *)netstatInfo {
    
    if(!netstatData || netstatData==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            netstatData = [Netstat_Info getTCPConnections];
            return netstatData;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return netstatData;
    }
}

// Location dataset caching
// setters required due to async operation (main thread)

static CLLocation* currentLocation = nil;
+ (void)setLocation:(CLLocation *)location {
    currentLocation = location;
}

static int locationDNEStatus = 0;
+ (void)setLocationDNEStatus:(int)dneStatus {
    locationDNEStatus = dneStatus;
}

+ (int)locationDNEStatus {
    return locationDNEStatus;
}

+ (CLLocation *)locationInfo {

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a location yet?
    if(currentLocation == nil){
        
        //Nope, wait for location data
        bool exit=NO;
        while (exit==NO){
            
            if(currentLocation != nil){
                NSLog(@"Got a location after waiting..");
                exit=YES;
                return currentLocation;

            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
                                // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Location timer expired");
                exit=YES;
                [self setLocationDNEStatus:DNEStatus_expired];
                return currentLocation;

            }
            
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got a location without waiting...");
    return currentLocation;
    
}

// Placemark dataset caching
// setters required due to async operation (main thread)

static CLPlacemark* currentPlacemark = nil;
+ (void)setPlacemark:(CLPlacemark *)placemark {
    currentPlacemark = placemark;
}

static int placemarkDNEStatus = 0;
+ (void)setPlacemarkDNEStatus:(int)dneStatus {
    placemarkDNEStatus = dneStatus;
}

+ (int)placemarkDNEStatus {
    return placemarkDNEStatus;
}

+ (CLPlacemark *)placemarkInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a placemark yet?
    if(currentPlacemark == nil){
        
        //Nope, wait for placemark data
        bool exit=NO;
        while (exit==NO){
            
            if(currentPlacemark != nil){
                NSLog(@"Got a placemark after waiting..");
                exit=YES;
                return currentPlacemark;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Placemark timer expired");
                exit=YES;
                [self setPlacemarkDNEStatus:DNEStatus_expired];
                return currentPlacemark;
                    
            }
            
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got placemark data
    NSLog(@"Got a placemark without waiting...");
    return currentPlacemark;
    
}


// Activity dataset caching
// setters required due to async operation (main thread)

// Current Activity
static CMMotionActivity *currentActivity = nil;
+ (void)setCurrentActivity:(CMMotionActivity *)activity {
    currentActivity = activity;
}

+ (CMMotionActivity *)currentActivityInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have any activities yet?
    if(currentActivity == nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(currentActivity != nil){
                NSLog(@"Got current activity after waiting..");
                exit=YES;
                return currentActivity;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Current activity timer expired");
                exit=YES;
                [self setActivityDNEStatus:DNEStatus_expired];
                return currentActivity;
                
            }
            
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got current activity without waiting...");
    return currentActivity;
    
}


// General Activity DNE

static int activityDNEStatus = 0;
+ (void)setActivityDNEStatus:(int)dneStatus {
    activityDNEStatus = dneStatus;
}

+ (int)activityDNEStatus {
    return activityDNEStatus;
}

// Previous Activities

static NSArray* previousActivities = nil;
+ (void)setPreviousActivities:(NSArray *)activities {
    previousActivities = activities;
}

+ (NSArray *)previousActivitiesInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have any activities yet?
    if(previousActivities == nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(previousActivities != nil){
                NSLog(@"Got previous activities after waiting..");
                exit=YES;
                return previousActivities;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Previous activities timer expired");
                exit=YES;
                [self setActivityDNEStatus:DNEStatus_expired];
                return previousActivities;
                    
            }
            
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got previous activities without waiting...");
    return previousActivities;
    
}


// Motion dataset caching
// setters required due to async operation (main thread)

static NSArray* motion = nil;
+ (void)setMotion:(NSArray *)currentMotion {
    motion = currentMotion;
}

static int motionDNEStatus = 0;
+ (void)setMotionDNEStatus:(int)dneStatus {
    motionDNEStatus = dneStatus;
}

+ (int)motionDNEStatus {
    return motionDNEStatus;
}

+ (NSArray *)motionInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a location yet?
    if(motion == nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(motion != nil){
                NSLog(@"Got motion after waiting..");
                exit=YES;
                return motion;
                
            }
           
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Motion timer expired");
                exit=YES;
                [self setMotionDNEStatus:DNEStatus_expired];
                return motion;
                    

            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got motion without waiting...");
    return motion;
    
}


//WiFi dataset caching

static NSDictionary *wifiData;
+ (NSDictionary *)wifiInfo {
    
    if(!wifiData || wifiData==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            wifiData = [Wifi_Info getWifi];
            return wifiData;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return wifiData;
    }
}

static BOOL wifiEnabled;
+ (BOOL)wifiEnabled {
    if(!wifiEnabled) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            wifiEnabled= [Wifi_Info isWiFiEnabled];
            return wifiEnabled;
            
        }
        @catch (NSException * ex) {
            // Error
            return NO;
        }
        
    }
    else //already populated
    {
        return wifiEnabled;
    }

}

static int wifiConnected = 0;
+ (int)wifiConnected {
    return wifiConnected;
}




// Bluetooth dataset caching
// setters required due to async operation (main thread)

static NSArray* bluetoothDevices = nil;
+ (void)setBluetooth:(NSArray *)devices {
    bluetoothDevices = devices;
}

static int bluetoothDNEStatus = 0;
+ (void)setBluetoothDNEStatus:(int)dneStatus {
    bluetoothDNEStatus = dneStatus;
}

+ (int)bluetoothDNEStatus {
    return bluetoothDNEStatus;
}

+ (NSArray *)bluetoothInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    
    //Do we any devices yet?
    if(bluetoothDevices == nil || bluetoothDevices.count <= 1){
        
        //Nope, wait for devices
        bool exit=NO;
        while (exit==NO){
            
            // If its greater than 1 we return, otherwise keep scanning until timer
            if(bluetoothDevices.count > 1){
                NSLog(@"Got bluetooth devices after waiting..");
                exit=YES;
                return bluetoothDevices;
                
            }
            
            //scanning until we hit the timer
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5 ){
                NSLog(@"Bluetooth timer expired");
                exit=YES;
                //[self setBluetoothDNEStatus:DNEStatus_expired];
                return bluetoothDevices;
                    
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
    }
    //we've already got location data
    NSLog(@"Got bluetooth devices without waiting...");
    return bluetoothDevices;
    
}




@end

