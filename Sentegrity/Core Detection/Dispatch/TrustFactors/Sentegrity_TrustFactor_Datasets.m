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
        _runTimeEpoch = [[NSDate date] timeIntervalSince1970];
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
    
    //Do we any data yet?
    if(self.location == nil){
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.location != nil){
                NSLog(@"Got location GPS after waiting..");
                return self.location;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Location GPS timer expired");
        [self setLocationDNEStatus:DNEStatus_expired];
        return self.location;
        
        
    }
    //we've already got data
    NSLog(@"Got location GPS without waiting...");
    return self.location;

    
}

- (CLPlacemark *)getPlacemarkInfo {
    
    //Do we any data yet?
    if(self.placemark == nil){
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.50;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.placemark != nil){
                NSLog(@"Got location placemark after waiting..");
                return self.placemark;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Location placemark timer expired");
        [self setPlacemarkDNEStatus:DNEStatus_expired];
        return self.placemark;
        
        
    }
    //we've already got data
    NSLog(@"Got location placemark without waiting...");
    return self.placemark;
    
    

    
}

- (NSArray *)getPreviousActivityInfo {
    
    //Do we any data yet?
    if(self.previousActivities == nil || self.previousActivities.count < 1){
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.1;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.previousActivities.count > 0){
                NSLog(@"Got Activity after waiting..");
                return self.previousActivities;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Activity timer expired");
        [self setActivityDNEStatus:DNEStatus_expired];
        return self.previousActivities;
        
        
    }
    //we've already got data
    NSLog(@"Got Activity without waiting...");
    return self.previousActivities;
    

    
}


- (NSArray *)getGyroRadsInfo {
    
    //Do we any data yet?
    if(self.gyroRads == nil || self.gyroRads.count < 1){
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.1;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.gyroRads.count > 0){
                NSLog(@"Got Gyro rads after waiting..");
                return self.gyroRads;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Gyro rads timer expired");
        [self setGyroMotionDNEStatus:DNEStatus_expired];
        return self.gyroRads;
        
        
    }
    //we've already got data
    NSLog(@"Got Gyro rads without waiting...");
    return self.gyroRads;
    
}

- (NSArray *)getGyroPitchInfo {
    

    //Do we any pitch info yet?
    if(self.gyroRollPitch == nil || self.gyroRollPitch.count < 1){
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.gyroRollPitch.count > 0){
                NSLog(@"Got Gyro roll pitch  after waiting..");
                return self.gyroRollPitch;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Gyro roll pitch timer expired");
        [self setGyroMotionDNEStatus:DNEStatus_expired];
        return self.gyroRollPitch;
        
        
    }
    //we've already got data
    NSLog(@"Got Gyro roll pitch without waiting...");
    return self.gyroRollPitch;
    
    
}

- (NSArray *)getAccelRadsInfo {
    
    
    //Do we any rads yet?
    if(self.accelRads == nil || self.accelRads.count < 1){
        
        //Nope, wait for rads
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.1;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.accelRads.count > 0){
                NSLog(@"Got accel rads after waiting..");
                return self.accelRads;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Accel rads timer expired");
        [self setAccelMotionDNEStatus:DNEStatus_expired];
        return self.accelRads;
        
        
    }
    //we've already got BLE data
    NSLog(@"Got accel rads without waiting...");
    return self.accelRads;
    
    
}

- (NSArray *)getHeadingsInfo {
    
    
    //Do we any headings yet?
    if(self.headings == nil || self.headings.count < 1){
        
        //Nope, wait for rads
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.5;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.headings.count > 0){
                NSLog(@"Got headings after waiting..");
                return self.headings;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Headings timer expired");
        [self setHeadingsMotionDNEStatus:DNEStatus_expired];
        return self.headings;
        
        
    }
    //we've already got BLE dat
    NSLog(@"Got headings without waiting...");
    return self.headings;
    
    
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

    
    //Do we any devices yet?
    if(self.discoveredBLEDevices == nil || self.discoveredBLEDevices.count < 1){
        
        //Nope, wait for devices
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;

        while ((currentTime-startTime) < waitTime){
   
            // If its greater than 0 return
            if(self.discoveredBLEDevices.count > 0){
                NSLog(@"Got discovered BLE devices after waiting..");
                return self.discoveredBLEDevices;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Discovered BLE devices timer expired");
        [self setDiscoveredBLESDNEStatus:DNEStatus_expired];
        return self.discoveredBLEDevices;
            
        
    }
    //we've already got BLE data
    NSLog(@"Got discovered BLE devices without waiting...");
    return self.discoveredBLEDevices;
    
}


- (NSArray *)getClassicBTInfo {
    

    //Do we any devices yet?
    if(self.connectedClassicBTDevices == nil || self.connectedClassicBTDevices.count < 1){
        
        //Nope, wait for devices
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.05;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.connectedClassicBTDevices.count > 0){
                NSLog(@"Got discovered BLE devices after waiting..");
                return self.connectedClassicBTDevices;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            //update timer
            currentTime = CFAbsoluteTimeGetCurrent();
            
        }
        
        // timer expired
        NSLog(@"Connected classic BT device timer expired");
        [self setConnectedClassicDNEStatus:DNEStatus_expired];
        return self.connectedClassicBTDevices;
        
        
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

-(NSNumber *)isTethering {
    if(!self.tethering) //dataset not populated
    {
        // Get the list of processes and all information about them
        @try {
            
            self.tethering = [Wifi_Info isTethering];
            return self.tethering;
            
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
    }
    else //already populated
    {
        return self.tethering;
    }
    
}


@end