//
//  Sentegrity_TrustFactor_Datasets.m
//  Sentegrity
//
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity_TrustFactor_Datasets.h"

@implementation Sentegrity_TrustFactor_Datasets

#pragma mark - Singleton Methods

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
+ (void)selfDestruct {
    // TODO: Get rid of this crappy code (sorry Jason)
    
    // Don't just destroy the token, destroy the entire object
    sharedTrustFactorDatasets = nil;
    onceToken = 0;
}

#pragma mark - TrustFactors Implementation Helpers

// Share payload validation routine for TFs that should have payload items
- (BOOL)validatePayload:(NSArray *)payload {
    
    // Check if the payload is empty
    if (!payload || payload == nil || payload.count < 1) {
        return NO;
    }
    
    // Return Valid
    return YES;
}

#pragma mark - Dataset Helpers

// CPU usage
- (float)getCPUUsage {
    
    // When dataset is not populated
    if(!self.cpuUsage) {
        
        // Set self cpu usage
        self.cpuUsage = [CPU_Info getCPUUsage];
        
        // Return cpu usage
        return self.cpuUsage;
        
    } else {
        
        // Return cpu usage
        return self.cpuUsage;
    }
}

// Battery state
- (NSString *)getBatteryState {
    
    // If dataset isn't populated
    if(!self.batteryState || self.batteryState == nil) {
        
        // Set device to current device
        UIDevice *Device = [UIDevice currentDevice];
        
        // Enable battery monitoring
        Device.batteryMonitoringEnabled = YES;
        
        // Set battery state
        UIDeviceBatteryState battery = [Device batteryState];
        NSString* state;
        
        switch (battery) {
                
                // Plugged in, less than 100%
            case UIDeviceBatteryStateCharging:
                state = @"pluggedCharging";
                break;
                
                // Plugged in, at 100%
            case UIDeviceBatteryStateFull:
                state = @"pluggedFull";
                break;
                
                // On battery, discharging
            case UIDeviceBatteryStateUnplugged:
                state = @"unplugged";
                break;
                
                // Unknown state
            default:
                state = @"unknown";
                break;
        }
        
        // Set battery state
        self.batteryState = state;
        
        // Return battery state
        return self.batteryState;
        
    } else {
        
        // Return battery state
        return self.batteryState;
    }
}

// Device orientation
- (NSString *)getDeviceOrientation {
    
    // If dataset is not populated
    if(!self.deviceOrientation || self.deviceOrientation == nil) {
        
        // Get device orientation
        self.deviceOrientation = [Motion_Info orientation];
        
        // Return device orientation
        return self.deviceOrientation;
        
    } else {
        
        // Return device orientation
        return self.deviceOrientation;
    }
}

// Device orientation
- (NSNumber *)getMovement {
    
    // If dataset is not populated
    if(!self.movement || self.movement == nil) {
        
        // Get device moving info
        self.movement = [Motion_Info movement];
        
        // Return moving info
        return self.movement;
        
    } else {
        
        // Return moving info
        return self.movement;
    }
}

// Time information
- (NSString *)getTimeDateStringWithHourBlockSize:(NSInteger)blockSize withDayOfWeek:(BOOL)day {
    
    // If dataset isn't populated
    if(!self.hourOfDay) {
        
        // Get day of week
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSInteger weekDay = [comps weekday];
        
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
        
        // Set minutes
        NSInteger minutes = [components minute];
        
        // Set hours
        NSInteger hours = [components hour];
        
        // Set dayOfWeek dataset
        self.dayOfWeek = weekDay;
        
        // Set hourOfDay dataset
        self.hourOfDay = hours;
        
        // Round up if needed
        if(minutes > 30){
            
            // Round up hour of day
            self.hourOfDay = hours+1;
        }
        
        // Avoid midnight as 0/blocksize will equal 0 and ceil will not round up
        if(hours == 0) {
            
            // Sets hour of day to 1 when midnight
            self.hourOfDay = 1;
        }
        
        // Hours partitioned by dividing by block size, adjust accordingly but it does impact multiple rules
        int hourBlock = ceilf((float)self.hourOfDay / (float)blockSize);
        
        // If day is provided
        if(day == YES) {
            
            // Return formatted with day of week and time
            return [NSString stringWithFormat:@"DAY_%ld_HOUR_%ld",(long)weekDay,(long)hourBlock];
            
        } else {
            
            // Return just time
            return [NSString stringWithFormat:@"HOUR_%ld",(long)hourBlock];
        }
        
    } else {
        
        // Hours partitioned across 24, adjust accordingly but it does impact multiple rules
        int hourBlock = ceilf((float)self.hourOfDay / (float)blockSize);
        
        // If day is provided
        if(day == YES) {
            
            // Return formatted with day of week and time
            return [NSString stringWithFormat:@"D%ld-H%ld",(long)self.dayOfWeek,(long)hourBlock];
            
        } else {
            
            // Return just time
            return [NSString stringWithFormat:@"H%ld",(long)hourBlock];
        }
    }
}

// Installed App Info
- (NSArray *)getInstalledAppInfo {
    
    // If dataset isn't populated
    if(!self.installedApps || self.installedApps == nil) {
        
        // Get the list of user apps
        @try {
            
            // Set installed apps to user apps
            self.installedApps = [App_Info getUserAppInfo];
            
            // Return installed apps
            return self.installedApps;
        }
        
        @catch (NSException * ex) {
            
            // Error
            return nil;
        }
        
        // If already populated
    } else {
        
        // Return installed apps
        return self.installedApps;
    }
}

// Process information
- (NSArray *)getProcessInfo {
    
    // If dataset is not populated
    if(!self.runningProcesses || self.runningProcesses ==nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set running processes
            self.runningProcesses  = [Process_Info getProcessInfo];
            
            // Return running processes
            return self.runningProcesses;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If already populated
    } else {
        
        // Return running processes
        return self.runningProcesses ;
    }
}

// PID
- (NSNumber *)getOurPID {
    
    // If dataset is not populated
    if(!self.ourPID || self.ourPID ==nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set our PID
            self.ourPID = [Process_Info getOurPID];
            
            // Return our PID
            return self.ourPID;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return our PID
        return self.ourPID ;
    }
}

// Network Route Info
- (NSArray *)getRouteInfo {
    
    // If dataset is not populated
    if(!self.networkRoutes || self.networkRoutes == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set network routes
            self.networkRoutes = [Route_Info getRoutes];
            
            // Return network routes
            return self.networkRoutes;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return network routes
        return self.networkRoutes;
    }
}

// Data transfer information
- (NSDictionary *)getDataXferInfo {
    
    // If dataset is not populated
    if(!self.interfaceBytes || self.interfaceBytes == nil) {
        
        // Get interface size in form of bytes
        @try {
            
            // Set interface size in the form of bytes
            self.interfaceBytes = [Netstat_Info getInterfaceBytes];
            
            // Return interfacce bytes
            return self.interfaceBytes;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return interface bytes
        return self.interfaceBytes;
    }
}

// NetStat Info
- (NSArray *)getNetstatInfo {
    
    
    // If dataset is not populated
    if(!self.netstatData || self.netstatData == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set net stat data
            self.netstatData = [Netstat_Info getTCPConnections];
            
            // Return net stat data
            return self.netstatData;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return net stat data
        return self.netstatData;
    }
}

// Location information
- (CLLocation *)getLocationInfo {
    
    //Do we any data yet?
    if(self.location == nil) {
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.location != nil) {
                
                NSLog(@"Got location GPS after waiting..");
                
                // Return location
                return self.location;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Location GPS timer expired");
        [self setLocationDNEStatus:DNEStatus_expired];
        
        // Return Location
        return self.location;
    }
    
    // We already have the data
    NSLog(@"Got location GPS without waiting...");
    
    // Return location
    return self.location;
}

// Placemark information
- (CLPlacemark *)getPlacemarkInfo {
    
    //Do we any data yet?
    if(self.placemark == nil) {
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.50;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.placemark != nil) {
                
                NSLog(@"Got location placemark after waiting..");
                
                // Return location placemark
                return self.placemark;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Location placemark timer expired");
        [self setPlacemarkDNEStatus:DNEStatus_expired];
        
        // Return location placemark
        return self.placemark;
    }
    
    // We already have the data
    NSLog(@"Got location placemark without waiting...");
    
    // Return location placemark
    return self.placemark;
}

// Previous activity information
- (NSArray *)getPreviousActivityInfo {
    
    //Do we any data yet?
    if(self.previousActivities == nil || self.previousActivities.count < 1) {
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.1;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.previousActivities.count > 0) {
                NSLog(@"Got Activity after waiting..");
                
                // Return previous activities
                return self.previousActivities;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Activity timer expired");
        [self setActivityDNEStatus:DNEStatus_expired];
        
        // Return previous activities
        return self.previousActivities;
    }
    
    // We already have the data
    NSLog(@"Got Activity without waiting...");
    
    // Return previous activities
    return self.previousActivities;
}

// Gyro information
- (NSArray *)getGyroRadsInfo {
    
    //Do we any data yet?
    if(self.gyroRads == nil || self.gyroRads.count < 1) {
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.2;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.gyroRads.count > 0){
                NSLog(@"Got Gyro rads after waiting..");
                return self.gyroRads;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Gyro rads timer expired");
        [self setGyroMotionDNEStatus:DNEStatus_expired];
        
        // Return gyro
        return self.gyroRads;
    }
    
    // We already have the data
    NSLog(@"Got Gyro rads without waiting...");
    
    // Return gyro
    return self.gyroRads;
}

// Gyro pitch information
- (NSArray *)getGyroPitchInfo {
    
    // Do we any pitch info yet?
    if(self.gyroRollPitch == nil || self.gyroRollPitch.count < 1) {
        
        // Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        while ((currentTime-startTime) < waitTime) {
            
            // If its greater than 0 return
            if(self.gyroRollPitch.count > 0) {
                
                NSLog(@"Got Gyro roll pitch  after waiting..");
                
                // Return gyro pitch
                return self.gyroRollPitch;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Gyro roll pitch timer expired");
        [self setGyroMotionDNEStatus:DNEStatus_expired];
        
        // Return gyro pitch
        return self.gyroRollPitch;
    }
    
    // We already have the data
    NSLog(@"Got Gyro roll pitch without waiting...");
    
    // Return gyro pitch
    return self.gyroRollPitch;
}

// Acceleration info
- (NSArray *)getAccelRadsInfo {
    
    // Do we any rads yet?
    if(self.accelRads == nil || self.accelRads.count < 1) {
        
        // Nope, wait for rads
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.1;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.accelRads.count > 0) {
                
                NSLog(@"Got accel rads after waiting..");
                
                // Return acceleration rads
                return self.accelRads;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Accel rads timer expired");
        [self setAccelMotionDNEStatus:DNEStatus_expired];
        
        // Return acceleration rads
        return self.accelRads;
    }
    
    // We already have the data
    NSLog(@"Got accel rads without waiting...");
    
    // Return acceleration rads
    return self.accelRads;
}



// Magnetic Headings information
- (NSArray *)getMagneticHeadingsInfo {
    
    //Do we any headings yet?
    if(self.magneticHeading == nil || self.magneticHeading.count < 1) {
        
        //Nope, wait for rads
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.5;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.magneticHeading.count > 0) {
                
                NSLog(@"Got magnetic headings after waiting..");
                
                // Return headings
                return self.magneticHeading;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer Expires
        NSLog(@"Headings timer expired");
        [self setMagneticHeadingDNEStatus:DNEStatus_expired];
        
        // Return headings
        return self.magneticHeading;
    }
    
    // We alreaady have the data
    NSLog(@"Got magnetic headings without waiting...");
    
    // Return headings
    return self.magneticHeading;
}





// Headings information
- (NSArray *)getHeadingsInfo {
    
    //Do we any headings yet?
    if(self.headings == nil || self.headings.count < 1) {
        
        //Nope, wait for rads
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.5;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.headings.count > 0) {
                
                NSLog(@"Got headings after waiting..");
                
                // Return headings
                return self.headings;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer Expires
        NSLog(@"Headings timer expired");
        [self setHeadingsMotionDNEStatus:DNEStatus_expired];
        
        // Return headings
        return self.headings;
    }
    
    // We alreaady have the data
    NSLog(@"Got headings without waiting...");
    
    // Return headings
    return self.headings;
}

// Wifi information
- (NSDictionary *)getWifiInfo {
    
    // If dataset is not populated
    if(!self.wifiData || self.wifiData == nil) {
        
        // Try for wifi data
        @try {
            
            // Get wifi data and set it
            self.wifiData = [Wifi_Info getWifi];
            
            // Return wifi data
            return self.wifiData;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return wifi data
        return self.wifiData;
    }
}

// Wifi enabled
-(NSNumber *)isWifiEnabled {
    
    // If dataset is not populated
    if(self.wifiEnabled == nil) {
        
        // Try to enable wifi
        @try {
            
            // Set whether wifi is enabled or not
            self.wifiEnabled = [Wifi_Info isWiFiEnabled];
            
            // Return information about whether wifi is enabled
            return self.wifiEnabled;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If the dataset is already populated
    } else {
        
        // Return information about whether wifi is enabled
        return self.wifiEnabled;
    }
}

// BLE information
- (NSArray *)getDiscoveredBLEInfo {
    
    //Do we any devices yet?
    if(self.discoveredBLEDevices == nil || self.discoveredBLEDevices.count < 1) {
        
        //Nope, wait for devices
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        while ((currentTime-startTime) < waitTime) {
            
            // If its greater than 0 return
            if(self.discoveredBLEDevices.count > 0){
                NSLog(@"Got discovered BLE devices after waiting..");
                
                // Return the BLE devices
                return self.discoveredBLEDevices;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Discovered BLE devices timer expired");
        [self setDiscoveredBLESDNEStatus:DNEStatus_expired];
        
        // Return the BLE devices
        return self.discoveredBLEDevices;
    }
    
    // We already have the data
    NSLog(@"Got discovered BLE devices without waiting...");
    
    // Return the BLE devices
    return self.discoveredBLEDevices;
}

// BT information
- (NSArray *)getClassicBTInfo {
    
    //Do we any devices yet?
    if(self.connectedClassicBTDevices == nil || self.connectedClassicBTDevices.count < 1) {
        
        //Nope, wait for devices
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.05;
        
        while ((currentTime-startTime) < waitTime) {
            
            // If its greater than 0 return
            if(self.connectedClassicBTDevices.count > 0){
                NSLog(@"Got discovered BLE devices after waiting..");
                
                // Return connected BT devices
                return self.connectedClassicBTDevices;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Connected classic BT device timer expired");
        [self setConnectedClassicDNEStatus:DNEStatus_expired];
        
        // Return connected BT devices
        return self.connectedClassicBTDevices;
    }
    
    // We already have the data
    NSLog(@"Got connected classic BT devices without waiting...");
    
    // Return connected BT devices
    return self.connectedClassicBTDevices;
}

// Wifi signal
- (NSNumber *)getWifiSignal {
    
    // If dataset is not populated
    if(!self.wifiSignal || self.wifiSignal == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set the wifi signal
            self.wifiSignal = [Wifi_Info getSignal];
            
            // Return wifi signal
            return self.wifiSignal;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return wifi signal
        return self.wifiSignal;
    }
}

// Cellular signal information
- (NSNumber *)getCelluarSignalBars {
    
    // If dataset is not populated
    if(!self.celluarSignalBars || self.celluarSignalBars == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set the bars to how many we have
            self.celluarSignalBars = [Cell_Info getSignalBars];
            
            // Return cell signal
            return self.celluarSignalBars;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return cell signal
        return self.celluarSignalBars;
    }
}

// Raw cellular signal
- (NSNumber *)getCelluarSignalRaw {
    
    // If dataset is not populated
    if(!self.celluarSignalRaw || self.celluarSignalRaw == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set raw signal
            self.celluarSignalRaw = [Cell_Info getSignalRaw];
            
            // Return raw signal
            return self.celluarSignalRaw;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return raw signal
        return self.celluarSignalRaw;
    }
}

// Carrier connection information
- (NSString *)getCarrierConnectionInfo {
    
    // If dataset is not populated
    if(!self.carrierConnectionInfo || self.carrierConnectionInfo == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set carrier connection information
            self.carrierConnectionInfo = [Cell_Info getCarrierInfo];
            
            // Return carrier connection information
            return self.carrierConnectionInfo;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return carrier connection information
        return self.carrierConnectionInfo;
    }
}

// AirplaneMode information
-(NSNumber *)isAirplaneMode {
    
    // If dataset is not populated
    if(!self.airplaneMode) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set AirplaneMode information
            self.airplaneMode = [Cell_Info isAirplane];
            
            // Return AirplaneMode information
            return self.airplaneMode;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return AirplaneMode information
        return self.airplaneMode;
    }
}

// Tethering information
-(NSNumber *)isTethering {
    
    // If dataset is not popoulated
    if(!self.tethering) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set if device is tethering
            self.tethering = [Wifi_Info isTethering];
            
            // Return tethering information
            return self.tethering;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return tethering information
        return self.tethering;
    }
}

@end