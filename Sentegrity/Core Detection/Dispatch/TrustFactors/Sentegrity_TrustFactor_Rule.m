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
            if ((currentTime-startTime) > 1.0){
                NSLog(@"Location timer expired");
                exit=YES;
                [self setLocationDNEStatus:DNEStatus_expired];
                return currentLocation;

            }
            
            
            [NSThread sleepForTimeInterval:.1];
            
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
            if ((currentTime-startTime) > 1.0){
                NSLog(@"Placemark timer expired");
                exit=YES;
                [self setPlacemarkDNEStatus:DNEStatus_expired];
                return currentPlacemark;
                    
            }
            
            
            [NSThread sleepForTimeInterval:0.1];
            
        }
        
        
    }
    //we've already got placemark data
    NSLog(@"Got a placemark without waiting...");
    return currentPlacemark;
    
}


// Activity dataset caching
// setters required due to async operation (main thread)

static NSArray* activities = nil;
+ (void)setActivity:(NSArray *)previousActivities {
    activities = previousActivities;
}

static int activityDNEStatus = 0;
+ (void)setActivityDNEStatus:(int)dneStatus {
    activityDNEStatus = dneStatus;
}

+ (int)activityDNEStatus {
    return activityDNEStatus;
}

+ (NSArray *)activityInfo {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime currentTime = 0.0;
    
    //Do we have a location yet?
    if(activities == nil){
        
        //Nope, wait for activity data
        bool exit=NO;
        while (exit==NO){
            
            if(activities != nil){
                NSLog(@"Got activities after waiting..");
                exit=YES;
                return activities;
                
            }
            
            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 1.0){
                NSLog(@"Activity timer expired");
                exit=YES;
                [self setActivityDNEStatus:DNEStatus_expired];
                return activities;
                    
            }
            
            
            [NSThread sleepForTimeInterval:0.1];
            
        }
        
        
    }
    //we've already got location data
    NSLog(@"Got activities without waiting...");
    return activities;
    
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
            if ((currentTime-startTime) > 1.0){
                NSLog(@"Motion timer expired");
                exit=YES;
                [self setMotionDNEStatus:DNEStatus_expired];
                return motion;
                    

            }
            
            [NSThread sleepForTimeInterval:0.1];
            
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
    if(bluetoothDevices == nil){
        
        //Nope, wait for devices
        bool exit=NO;
        while (exit==NO){
            
            if(bluetoothDevices != nil){
                NSLog(@"Got bluetooth devices after waiting..");
                exit=YES;
                return bluetoothDevices;
                
            }

            currentTime = CFAbsoluteTimeGetCurrent();
            // we've waited more than a second, exit
            if ((currentTime-startTime) > 3.0){
                NSLog(@"Bluetooth timer expired");
                exit=YES;
                [self setBluetoothDNEStatus:DNEStatus_expired];
                return bluetoothDevices;
                    
            }
            
            [NSThread sleepForTimeInterval:0.1];
            
        }
        
    }
    //we've already got location data
    NSLog(@"Got bluetooth devices without waiting...");
    return bluetoothDevices;
    
}




@end

