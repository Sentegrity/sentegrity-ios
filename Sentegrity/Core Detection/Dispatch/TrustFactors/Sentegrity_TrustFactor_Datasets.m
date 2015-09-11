//
//  TrustFactor_Dispatch.m
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//  Copyright (c) 2015 Walid Javed. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"


// This class is designed to cache the results of datasets between the TrustFactor_Dispatch_[Rule] and Sentegrity_TrustFactor_Dataset_[Category]

@implementation Sentegrity_TrustFactor_Datasets


#pragma mark Singleton Methods

// Singleton shared instance
+ (id)sharedDatasets {
    static Sentegrity_TrustFactor_Datasets *sharedTrustFactorDatasets = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTrustFactorDatasets = [[self alloc] init];
    });
    return sharedTrustFactorDatasets;
}

// Init (Defaults)
- (id)init {
    if (self = [super init]) {
        //Set epoch (runtime) to be used all over the place but consistent for the same run
        self.runTimeEpoch = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}


#pragma mark TF Implementation helpers

// Share payload validation routine for TFs that should have payload items
- (BOOL)validatePayload:(NSArray *)payload {
    
    // Check if the payload is empty
    if (!payload || payload == nil || payload.count < 1) {
        return NO;
    }
    
    // Return Valid
    return YES;
}

#pragma mark Dataset helpers

// CPU usage
- (float)getCPUUsage{
    
    if(!self.cpuUsage) //dataset not populated
    {
        self.cpuUsage = [CPU_Info getCPUUsage];
        
        return self.cpuUsage;
        
    }else
    {
        return self.cpuUsage;
    }
    
    
}

// Battery state
- (NSString *)getBatteryState{
    
    if(!self.batteryState || self.batteryState == nil) //dataset not populated
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
        
        self.batteryState = state;
        
        return self.batteryState;
        
    }else
    {
        return self.batteryState;
    }
    
}

// Device orientation
- (NSString *)getDeviceOrientation{
    
    if(!self.deviceOrientation || self.deviceOrientation == nil) //dataset not populated
    {
        UIDevice *device = [UIDevice currentDevice];
        UIDeviceOrientation orientation = device.orientation;
        
        NSString* orientationString;
        
        switch (orientation) {
            case UIDeviceOrientationPortrait:
                orientationString =  @"Portrait";
                break;
            case UIDeviceOrientationLandscapeRight:
                orientationString =  @"Landscape_Right";
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                orientationString =  @"Portrait_Upside_Down";
                break;
            case UIDeviceOrientationLandscapeLeft:
                orientationString =  @"Landscape_Left";
                break;
            case UIDeviceOrientationFaceUp:
                orientationString =  @"Face_Up";
                break;
            case UIDeviceOrientationFaceDown:
                orientationString =  @"Face_Down";
                break;
            case UIDeviceOrientationUnknown:
                //Error
                orientationString =  @"unknown";
                break;
            default:
                //Error
                orientationString =  @"error";
                break;
        }
        
        
        self.deviceOrientation = orientationString;
        
        return self.deviceOrientation;
        
    }else
    {
        return self.deviceOrientation;
    }
    
}

- (NSString *)getTimeDateStringWithHourBlockSize:(NSInteger)blockSize withDayOfWeek:(BOOL)day {
    if(!self.hourOfDay) //dataset not populated
    {
        //day of week
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSInteger weekDay = [comps weekday];
        
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
        
        NSInteger minutes = [components minute];
        
        // Set hourOfDay dataset
        NSInteger hours = [components hour];
        
        // Set dayOfWeek dataset
        self.dayOfWeek = weekDay;
        
        self.hourOfDay = hours;
        
        //round up if needed
        if(minutes > 30){
            self.hourOfDay = hours+1;
        }
        
        //Avoid midnight as 0/blocksize will equal 0 and ceil will not round up
        if(hours==0)
        {
            self.hourOfDay=1;
        }
        
        // Hours partitioned by dividing by block size, adjust accordingly but it does impact multiple rules
        int hourBlock = ceilf((float)self.hourOfDay / (float)blockSize);
        
        
        if(day==YES){
            return [NSString stringWithFormat:@"D%ld-H%ld",(long)weekDay,(long)hourBlock];
            
        }
        else{
            return [NSString stringWithFormat:@"H%ld",(long)hourBlock];
        }
        
        
    }else
    {
        // Hours partitioned across 24, adjust accordingly but it does impact multiple rules
        int hourBlock = ceilf((float)self.hourOfDay / (float)blockSize);
        
        
        if(day==YES){
            return [NSString stringWithFormat:@"D%ld-H%ld",(long)self.dayOfWeek,(long)hourBlock];
            
        }
        else{
            return [NSString stringWithFormat:@"H%ld",(long)hourBlock];
        }
    }
    
}



- (NSArray *)getInstalledAppInfo {
    
    if(!self.installedApps || self.installedApps==nil) //dataset not populated
    {
        // Get the list of user apps
        @try {
            
            self.installedApps = [App_Info getUserAppInfo];
            return self.installedApps;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.installedApps;
    }
}


- (NSArray *)getProcessInfo {
    
    if(!self.runningProcesses || self.runningProcesses ==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.runningProcesses  = [Process_Info getProcessInfo];
            return self.runningProcesses ;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.runningProcesses ;
    }
}


- (NSNumber *)getOurPID {
    
    if(!self.ourPID || self.ourPID ==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.ourPID = [Process_Info getOurPID];
            return self.ourPID;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.ourPID ;
    }
}

- (NSArray *)getRouteInfo {
    
    if(!self.networkRoutes || self.networkRoutes==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.networkRoutes = [Route_Info getRoutes];
            return self.networkRoutes;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
    }
    else //already populated
    {
        return self.networkRoutes;
    }
}



- (NSDictionary *)getDataXferInfo {
    
    if(!self.interfaceBytes || self.interfaceBytes==nil) //dataset not populated
    {
        
        @try {
            
            self.interfaceBytes = [Netstat_Info getInterfaceBytes];
            return self.interfaceBytes;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.interfaceBytes;
    }
}


- (NSArray *)getNetstatInfo {
    
    if(!self.netstatData || self.netstatData==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.netstatData = [Netstat_Info getTCPConnections];
            return self.netstatData;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.netstatData;
    }
}


- (CLLocation *)getLocationInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a location yet?
    if(!self.location || self.location == nil){
        
        //Nope, wait for location data
        bool exit=NO;
        while (exit==NO){
            
            if(self.location != nil){
                NSLog(@"Got a location after waiting..");
                exit=YES;
                return self.location;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Location timer expired");
                exit=YES;
                [self setLocationDNEStatus:DNEStatus_expired];
                return self.location;
                
            }
            
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got a location without waiting...");
    return self.location;
    
}

- (CLPlacemark *)getPlacemarkInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a placemark yet?
    if(!self.placemark || self.placemark == nil){
        
        //Nope, wait for placemark data
        bool exit=NO;
        while (exit==NO){
            
            if(self.placemark  != nil){
                NSLog(@"Got a placemark after waiting..");
                exit=YES;
                return self.placemark ;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Placemark timer expired");
                exit=YES;
                [self setPlacemarkDNEStatus:DNEStatus_expired];
                return self.placemark ;
                
            }
            
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got placemark data
    NSLog(@"Got a placemark without waiting...");
    return self.placemark ;
    
}


- (CMMotionActivity *)getCurrentActivityInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have any activities yet?
    if(!self.currentActivity || self.currentActivity == nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(self.currentActivity != nil){
                NSLog(@"Got current activity after waiting..");
                exit=YES;
                return self.currentActivity;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Current activity timer expired");
                exit=YES;
                [self setActivityDNEStatus:DNEStatus_expired];
                return self.currentActivity;
                
            }
            
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got current activity without waiting...");
    return self.currentActivity;
    
}

- (NSArray *)getPreviousActivityInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have any activities yet?
    if(!self.previousActivities || self.previousActivities == nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(self.previousActivities != nil){
                NSLog(@"Got previous activities after waiting..");
                exit=YES;
                return self.previousActivities;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Previous activities timer expired");
                exit=YES;
                [self setActivityDNEStatus:DNEStatus_expired];
                return self.previousActivities;
                
            }
            
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got previous activities without waiting...");
    return self.previousActivities;
    
}


- (NSArray *)getGyroRadsInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a location yet?
    if(!self.gyroRads || self.gyroRads == nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(self.gyroRads != nil){
                NSLog(@"Got gyro rads after waiting..");
                exit=YES;
                return self.gyroRads;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Gyro rads timer expired");
                exit=YES;
                [self setGyroMotionDNEStatus:DNEStatus_expired];
                return self.gyroRads;
                
                
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got gyro rads without waiting...");
    return self.gyroRads;
    
    
}

- (NSArray *)getGyroPitchInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a location yet?
    if(!self.gyroRollPitch || self.gyroRollPitch ==nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(self.gyroRollPitch != nil){
                NSLog(@"Got gyro pitch after waiting..");
                exit=YES;
                return self.gyroRollPitch;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Gyro pitch timer expired");
                exit=YES;
                [self setGyroMotionDNEStatus:DNEStatus_expired];
                return self.gyroRollPitch;
                
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got gyro pitch without waiting...");
    return self.gyroRollPitch;
    
}


- (NSDictionary *)getWifiInfo {
    
    if(!self.wifiData || self.wifiData==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.wifiData = [Wifi_Info getWifi];
            return self.wifiData;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.wifiData;
    }
}

-(BOOL)isWifiEnabled {
    if(!self.wifiEnabled) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.wifiEnabled= [Wifi_Info isWiFiEnabled];
            return self.wifiEnabled;
            
        }
        @catch (NSException * ex) {
            // Error
            return NO;
        }
        
    }
    else //already populated
    {
        return self.wifiEnabled;
    }
    
}

- (NSArray *)getDiscoveredBLEInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    
    //Do we any devices yet?
    if(self.discoveredBLEDevices == nil || self.discoveredBLEDevices.count <= 1){
        
        //Nope, wait for devices
        bool exit=NO;
        while (exit==NO){
            
            // If its greater than 1 we return, otherwise keep scanning until timer
            if(self.discoveredBLEDevices.count > 1){
                NSLog(@"Got discovered BLE devices after waiting..");
                exit=YES;
                return self.discoveredBLEDevices;
                
            }
            
            //scanning until we hit the timer
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5 ){
                NSLog(@"Discovered BLE devices timer expired");
                exit=YES;
                [self setDiscoveredBLESDNEStatus:DNEStatus_expired];
                return self.discoveredBLEDevices;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
    }
    //we've already got location data
    NSLog(@"Got discovered BLE devices without waiting...");
    return self.discoveredBLEDevices;
    
}

// TO BE IMPLEMENTED
- (NSArray *)getConnectedBLEInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    
    //Do we any devices yet?
    if(self.connectedBLEDevices == nil || self.connectedBLEDevices.count <= 1){
        
        //Nope, wait for devices
        bool exit=NO;
        while (exit==NO){
            
            // If its greater than 1 we return, otherwise keep scanning until timer
            if(self.connectedBLEDevices.count > 1){
                NSLog(@"Got connected BLE devices after waiting..");
                exit=YES;
                return self.connectedBLEDevices;
                
            }
            
            //scanning until we hit the timer
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5 ){
                NSLog(@"Connected BLE devices timer expired");
                exit=YES;
                [self setDiscoveredBLESDNEStatus:DNEStatus_expired];
                return self.discoveredBLEDevices;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
    }
    //we've already got location data
    NSLog(@"Got connected BLE devices without waiting...");
    return self.discoveredBLEDevices;
    
}




@end

