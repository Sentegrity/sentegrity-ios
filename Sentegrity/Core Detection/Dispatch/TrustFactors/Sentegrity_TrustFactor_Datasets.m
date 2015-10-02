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
static Sentegrity_TrustFactor_Datasets *sharedTrustFactorDatasets = nil;
static dispatch_once_t onceToken;

+ (id)sharedDatasets {

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

// Only used for demo re-run of core detection, otherwise the cached datasets are used
+ (void) selfDestruct {
    onceToken = 0;
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
        
        self.deviceOrientation = [Motion_Info orientation];
        
        return self.deviceOrientation;
        
    }else
    {
        return self.deviceOrientation;
    }
    
}

// Device orientation
- (NSNumber *)isMoving{
    
    if(!self.moving || self.moving == nil) //dataset not populated
    {
        
        self.moving = [Motion_Info isMoving];
        
        return self.moving;
        
    }else
    {
        return self.moving;
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
            return [NSString stringWithFormat:@"DAY_%ld_HOUR_%ld",(long)weekDay,(long)hourBlock];
            
        }
        else{
            return [NSString stringWithFormat:@"HOUR_%ld",(long)hourBlock];
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
    //we've already got gyro data
    NSLog(@"Got gyro pitch without waiting...");
    return self.gyroRollPitch;
    
}

- (NSArray *)getAccelRadsInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a location yet?
    if(!self.accelRads || self.accelRads == nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(self.accelRads != nil){
                NSLog(@"Got accel rads after waiting..");
                exit=YES;
                return self.accelRads;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.5){
                NSLog(@"Accel rads timer expired");
                exit=YES;
                [self setAccelMotionDNEStatus:DNEStatus_expired];
                return self.accelRads;
                
                
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got accel rads without waiting...");
    return self.accelRads;
    
    
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

-(NSNumber *)isWifiEnabled {
    if(self.wifiEnabled == nil) //dataset not populated
    {
        
        @try {
            
            self.wifiEnabled = [Wifi_Info isWiFiEnabled];
            return self.wifiEnabled;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
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
    
    
    //Do we any devices yet? Hold out for a bit if we only have one thus far (gives more time to find additional)
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
            if ((currentTime-startTime) > 0.1 ){
                NSLog(@"Discovered BLE devices timer expired");
                exit=YES;
                
                // Only set to expired if we truly found none, otherwise run with what we did find (1 or 2)
                if(self.discoveredBLEDevices.count<1){
                    [self setDiscoveredBLESDNEStatus:DNEStatus_expired];
                    
                }
                
                return self.discoveredBLEDevices;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
    }
    //we've already got BLE data
    NSLog(@"Got discovered BLE devices without waiting...");
    return self.discoveredBLEDevices;
    
}


- (NSArray *)getClassicBTInfo {
    
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    
    //Do we any devices? We don't really need to wait for this one as there may never be a connected device, just check for null
    if(self.connectedClassicBTDevices == nil){
        
        //Nope, wait for devices
        bool exit=NO;
        while (exit==NO){
            
            // If its greater than 1 we return, otherwise keep scanning until timer
            if(self.connectedClassicBTDevices.count > 0){
                NSLog(@"Got connected classic BT devices after waiting..");
                exit=YES;
                return self.connectedClassicBTDevices;
                
            }
            
            //scanning until we hit the timer
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 0.3 ){
                NSLog(@"Connected classic BT devices timer expired");
                exit=YES;
                [self setConnectedClassicDNEStatus:DNEStatus_expired];
                return self.connectedClassicBTDevices;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
        }
        
    }
    //we've already got BLE data
    NSLog(@"Got connected classic BT devices without waiting...");
    return self.connectedClassicBTDevices;
    
}



- (NSNumber *)getWifiSignal {
    
    
    if(!self.wifiSignal || self.wifiSignal==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.wifiSignal = [Wifi_Info getSignal];
            return self.wifiSignal;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.wifiSignal;
    }
    
}


- (NSNumber *)getCelluarSignalBars {
    
    if(!self.celluarSignalBars || self.celluarSignalBars==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.celluarSignalBars = [Cell_Info getSignalBars];
            return self.celluarSignalBars;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.celluarSignalBars;
    }
    
    
}


- (NSNumber *)getCelluarSignalRaw {
    
    if(!self.celluarSignalRaw || self.celluarSignalRaw==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.celluarSignalRaw = [Cell_Info getSignalRaw];
            return self.celluarSignalRaw;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.celluarSignalRaw;
    }
    
    
}



- (NSString *)getCarrierConnectionInfo {
    
    
    if(!self.carrierConnectionInfo || self.carrierConnectionInfo==nil) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.carrierConnectionInfo = [Cell_Info getCarrierInfo];
            return self.carrierConnectionInfo;
            
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.carrierConnectionInfo;
    }
    
}

-(NSNumber *)isAirplaneMode {
    if(!self.airplaneMode) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.airplaneMode = [Cell_Info isAirplane];
            return self.airplaneMode;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.airplaneMode;
    }
    
}

@end