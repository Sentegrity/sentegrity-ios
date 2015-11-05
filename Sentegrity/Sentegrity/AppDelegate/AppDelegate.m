//
//  AppDelegate.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "AppDelegate.h"

// Side Menu
#import "RESideMenu.h"

#import "Sentegrity_TrustFactor_Dataset_Location.h"

#import "Sentegrity_TrustFactor_Datasets.h"

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Private Interface Declaration
@interface AppDelegate () <CBCentralManagerDelegate> {
    
    // Progress HUD
    MBProgressHUD *hud;
    
    // Gryo information
    NSMutableArray *pitchRollArray;
    NSMutableArray *gyroRadsArray;
    NSMutableArray *accelRadsArray;
    NSMutableArray *headingsArray;
    
    // Bluetooth Manager
    CBCentralManager *mgr;
    NSMutableArray *discoveredBLEDevices;
    CFAbsoluteTime startTime;
    
    // Bluetooth Devices
    NSMutableArray *connectedBTDevices;
}

@end


@implementation AppDelegate

#pragma mark - App Delegate Functions

// Application did finish launching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Get the storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Create a navigation controller
    UINavigationController *controller;
    
    // Check if the app has been used at all
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        
        // Do something on first launch
        controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"]];
        
    } else {
        
        // Call async data functions such as location/core
        [self runCoreDetectionActivities];
        
        // Set up the navigation controller
        controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"]];
        
    }
    
    // Hide the navigation bar
    [controller setNavigationBarHidden:YES];
    
    // Create the side menu controller
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:controller leftMenuViewController:nil rightMenuViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"rightmenuviewcontroller"]];
    
    // Set the light content status bar
    [sideMenuViewController setMenuPreferredStatusBarStyle:UIStatusBarStyleDefault];
    
    // Don't scale content view
    [sideMenuViewController setScaleContentView:NO];
    
    // Make it a root controller
    self.window.rootViewController = sideMenuViewController;
    
    // Return YES
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //Call async data functions such as location/core
    //[self runCoreDetectionActivities];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //Call async data functions such as location/core
    //[self runCoreDetectionActivities];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Additional functions

// Run the Core Detection Activites
- (void)runCoreDetectionActivities {
    
    // Start Bluetooth
    [self startBluetoothBLE]; // Also starts classic
    
    // Start location
    [self startLocation];
    
    // Start Activity
    [self startActivity];
    
    // Start Motion
    [self startMotion];
    
}

#pragma mark - Core Detection Activities

// Locatino services
- (void)startLocation {
    
    // Create the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    NSUInteger code = [CLLocationManager authorizationStatus];
    
    // Check if it's enabled
    if (![CLLocationManager locationServicesEnabled]) {
        
        // Set location disabled
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setLocationDNEStatus:DNEStatus_disabled];
        
        // Set placemark disabled
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setPlacemarkDNEStatus:DNEStatus_disabled];
        
    } else {
        
        // Check if location is actually allowed
        if (code == kCLAuthorizationStatusNotDetermined && [_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            // Request location when application is in use
            [self.locationManager requestWhenInUseAuthorization];
            
        }
    }
    
    // Check if the code is authorized
    if (code == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        // Set the location accuracy to low
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        // Start updating the location
        [self.locationManager startUpdatingLocation];
        
    } else if (code == kCLAuthorizationStatusDenied) {
        
        // Location status is denied
        
        //Set location unauthorized
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setLocationDNEStatus:DNEStatus_unauthorized];
        
        //Set placemark unauthorized
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setPlacemarkDNEStatus:DNEStatus_unauthorized];
        
    } else {
        
        // Unknown Reason why location is denied
        
        // Set location error
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setLocationDNEStatus:DNEStatus_unauthorized];
        
        // Set placemark error
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemarkDNEStatus:DNEStatus_unauthorized];
    }
    
}

// Start Motion Monitoring
- (void)startActivity {
    
    // Check if the motion activity manager is available
    if (![CMMotionActivityManager isActivityAvailable]) {
        
        // Not supported
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unsupported];
        
    } else {
        
        // Create the motion manager
        CMMotionActivityManager *manager = [[CMMotionActivityManager alloc] init];
        
        // Get motion activity data
        [manager queryActivityStartingFromDate:[NSDate dateWithTimeIntervalSinceNow:-(60*5)] toDate:[NSDate date] toQueue:[NSOperationQueue new] withHandler:^(NSArray *activities, NSError *error) {
            
            // Check for errors
            if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                
                // The app isn't authorized to use motion activity support.
                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unauthorized];
                
            } else {
                
                // Set activities array
                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPreviousActivities:activities];
                
            }
            
            // Stop future updates as this only gets called once
            [manager stopActivityUpdates];
            
        }];
        
    }
    
}

// Start the motion tracking - Gyro
- (void)startMotion {
    
    // Create the motion manager
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    
    // Allocate all the gyro arrays
    if (!pitchRollArray || pitchRollArray == nil) {
        pitchRollArray = [[NSMutableArray alloc] init];
    }
    if (!accelRadsArray || accelRadsArray == nil) {
        accelRadsArray = [[NSMutableArray alloc] init];
    }
    if (!gyroRadsArray || gyroRadsArray == nil) {
        gyroRadsArray = [[NSMutableArray alloc] init];
    }
    if (!headingsArray || headingsArray == nil) {
        headingsArray = [[NSMutableArray alloc] init];
    }
    
    // Check if the gryo is available
    if (![manager isGyroAvailable] || manager == nil) {
        
        // Gyro not available
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unsupported];
        
    } else {
        
        // Gyro is available
        
        // User Grip & Calibrated Magnetics
        manager.deviceMotionUpdateInterval = .001f;
        
        // Get the device motion updates
        [manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion  *motion, NSError *error) {
            
            // Check for errors
            if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                
                // The app isn't authorized to use motion activity support.
                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unauthorized];
                
            } else {
                
                // Got the Gyro Pitch/Roll
                
                // Create an array of motion samples
                NSArray *itemArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:motion.attitude.pitch], [NSNumber numberWithFloat:motion.attitude.roll], nil];
                
                // Create an array of keys
                NSArray *keyArray = [NSArray arrayWithObjects:@"pitch", @"roll", nil];
                
                // Create the dictionary
                NSDictionary *dict = [[NSDictionary alloc] initWithObjects:itemArray forKeys:keyArray];
                
                // Add sample to array
                [pitchRollArray addObject:dict];
                
                // Set the gyro roll pictch
                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroRollPitch:pitchRollArray];
                
                // Check if the device motion field is not 0
                if (manager.deviceMotion.magneticField.field.z != 0) {
                    
                    // Create an array of headings samples
                    NSArray *itemArrayInfo = [NSArray arrayWithObjects:[NSNumber numberWithDouble:manager.deviceMotion.magneticField.field.x], [NSNumber numberWithDouble:manager.deviceMotion.magneticField.field.y],[NSNumber numberWithDouble:manager.deviceMotion.magneticField.field.z], nil];
                    
                    // Create an array of keys
                    NSArray *keyArrayInfo = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
                    
                    // Create the dictionary
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:itemArrayInfo forKeys:keyArrayInfo];
                    
                    // Add sample to array
                    [headingsArray addObject:dict];
                    
                    // Set the headings
                    [[Sentegrity_TrustFactor_Datasets sharedDatasets] setHeadings:headingsArray];
                    
                }
                
                // Keep updating until we stop
                // We want a minimum of 3 samples before we average them inside the TF
                // its possible we will get more as this handler gets called additional times prior to
                // the TF needing the dataset, but we don't want to cause it to wait therefore we stick with a minimum of 3. If we get more it will continue to update
                if (pitchRollArray.count > 3 && headingsArray.count > 3){
                    [manager stopDeviceMotionUpdates];
                }
                
            }
            
        }];
        
        /*
         // magnetomer readings, this does not work well as its not calibrated (raw data very unpredictable)
         manager.magnetometerUpdateInterval = .001;
         [manager startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue]  withHandler:^(CMMagnetometerData  *magnetometer, NSError *error) {
         
         [manager stopMagnetometerUpdates];
         
         if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
         // The app isn't authorized to use motion activity support.
         [[Sentegrity_TrustFactor_Datasets sharedDatasets] setHeadingsMotionDNEStatus:DNEStatus_unauthorized];
         }
         else{
         
         
         // Create an array of headings samples
         NSArray *ItemArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:magnetometer.magneticField.x], [NSNumber numberWithDouble:magnetometer.magneticField.y],[NSNumber numberWithDouble:magnetometer.magneticField.z], nil];
         
         // Create an array of keys
         NSArray *KeyArray = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
         
         // Create the dictionary
         NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
         
         // Add sample to array
         [headingsArray addObject:dict];
         
         [[Sentegrity_TrustFactor_Datasets sharedDatasets] setHeadings:headingsArray];
         }
         
         }];
         
         */
        
        // Attempt to detect large movements
        manager.gyroUpdateInterval = .001f;
        [manager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData  *gyroData, NSError *error) {
            
            // Check for errors
            if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                
                // The app isn't authorized to use motion activity support.
                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unauthorized];
                
            } else {
                
                // Create an array of gyro samples
                NSArray *itemArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:gyroData.rotationRate.x], [NSNumber numberWithFloat:gyroData.rotationRate.y], [NSNumber numberWithFloat:gyroData.rotationRate.z], nil];
                
                // Create an array of keys
                NSArray *keyArray = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
                
                // Create the dictionary
                NSDictionary *dict = [[NSDictionary alloc] initWithObjects:itemArray forKeys:keyArray];
                
                // Add sample to array
                [gyroRadsArray addObject:dict];
                
                // Set the gyro radians
                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroRads:gyroRadsArray];
                
                
                // We want a minimum of 3 samples before we average them inside the TF
                // its possible we will get more as this handler gets called additional times prior to
                // the TF needing the dataset, but we don't want to cause it to wait therefore we stick with a minimum of 3. If we get more it will continue to update
                
                // Keep updating until we stop
                if (gyroRadsArray.count > 3){
                    [manager stopGyroUpdates];
                }
                
            }
            
        }];
        
    }
    
    
    // Accelerometer
    
    // Check if the accelerometer is available
    if (![manager isAccelerometerAvailable] || manager == nil) {
        
        // Accelerometer is not available
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setAccelMotionDNEStatus:DNEStatus_unsupported];
        
    } else {
        
        // Accelerometer is available
        
        // Used to detect orientation
        manager.accelerometerUpdateInterval = .001f;
        [manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData  *accelData, NSError *error) {
            
            // Check if an error occured
            if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                
                // The app isn't authorized to use motion activity support.
                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unauthorized];
                
            } else {
                
                // Create an array of gyro samples
                NSArray *itemArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:accelData.acceleration.x], [NSNumber numberWithFloat:accelData.acceleration.y], [NSNumber numberWithFloat:accelData.acceleration.z], nil];
                
                // Create an array of keys
                NSArray *keyArray = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
                
                // Create the dictionary
                NSDictionary *dict = [[NSDictionary alloc] initWithObjects:itemArray forKeys:keyArray];
                
                // Add sample to array
                [accelRadsArray addObject:dict];
                
                // Update dataset
                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setAccelRads:accelRadsArray];
                
                // We want a minimum of 3 samples before we average them inside the TF
                // its possible we will get more as this handler gets called additional times prior to
                // the TF needing the dataset, but we don't want to cause it to wait therefore we stick with a minimum of 3. If we get more it will continue to update
                
                // Keep updating until we stop
                if (accelRadsArray.count > 3){
                    [manager stopAccelerometerUpdates];
                }
                
            }
            
        }];
        
    }
    
}

// Start Bluetooth scanning
- (void)startBluetoothBLE {
    
    // Set the start time
    startTime = CFAbsoluteTimeGetCurrent();
    
    // Create the bluetooth manager options
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerOptionShowPowerAlertKey, nil];
    
    // Start the manager
    mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    
}

// Start Scanning Bluetooth classic
- (void)startBluetoothClassic {
    
    // Start Bluetooth Manager
    [[MDBluetoothManager sharedInstance] registerObserver:self];
    
}

#pragma mark - Bluetooth Manager Delegate

// Callback for didDiscoverPeripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // Add the device dictionary to the list
    [discoveredBLEDevices addObject:[NSString stringWithFormat:@"%@", peripheral.identifier.UUIDString]];
    
    // Update the datasets
    [[Sentegrity_TrustFactor_Datasets sharedDatasets] setDiscoveredBLEDevices:discoveredBLEDevices];
    
    // Update timer with current time
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    
    // Stop scanning after 2 seconds (this has no bearing on CD execution time)
    if ((currentTime-startTime) > 2.0){
        
        // Scanning stopped
        NSLog(@"Bluetooth scanning stopped");
        [mgr stopScan];
        
    }
    
}

// Central manager updated
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    // Check which state the bluetooth manager is in
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        {
            //messtoshow=[NSString stringWithFormat:@"State unknown, update imminent."];
            
            // Wait
            break;
        }
        case CBCentralManagerStateResetting:
        {
            //messtoshow=[NSString stringWithFormat:@"The connection with the system service was momentarily lost, update imminent."];
            
            // Wait
            break;
        }
        case CBCentralManagerStateUnsupported:
        {
            
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setDiscoveredBLESDNEStatus:DNEStatus_unsupported];
            
            // We also set classic here since it uses private API this is more reliable
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedClassicDNEStatus:DNEStatus_unsupported];
            
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            //messtoshow=[NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            
            // Update the dataset to unauthorized
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setDiscoveredBLESDNEStatus:DNEStatus_unauthorized];
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedClassicDNEStatus:DNEStatus_unauthorized];
            
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            //messtoshow=[NSString stringWithFormat:@"Bluetooth is currently powered off."];
            
            // Update the dataset to disabled
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setDiscoveredBLESDNEStatus:DNEStatus_disabled];
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedClassicDNEStatus:DNEStatus_disabled];
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            
            // Create the bluetooth array
            if (!discoveredBLEDevices || discoveredBLEDevices == nil) {
                // Allocate the discoveredBLEDevices array
                discoveredBLEDevices = [[NSMutableArray alloc] init];
            }
            
            // Set timer to eventually stop scanning (otherwise if we don't find any it will keep trying during app use and kill battery)
            startTime = CFAbsoluteTimeGetCurrent();
            
            // Start scanning for any peripheral bluetooth devices
            [mgr scanForPeripheralsWithServices:nil options:nil];
            
            // Also start classic BT
            [self startBluetoothClassic];
            
            // Done
            break;
        }
            
    }
    
}

#pragma mark - Bluetooth Classic Manager Delegate

// Received Bluetooth notification
- (void)receivedBluetoothNotification:(MDBluetoothNotification)bluetoothNotification {
    
    // Unregister bluetooth
    [[MDBluetoothManager sharedInstance] unregisterObserver:self];
    
    // Get the connected devices
    NSArray *connectedDevices = [[BluetoothManager sharedInstance] connectedDevices];
    
    // Create the mutablearray if needed
    if (!connectedBTDevices || connectedBTDevices == nil) {
        
        // Allocate the connectedBTDevices array
        connectedBTDevices = [[NSMutableArray alloc] init];
        
    }
    
    // Run through all found devices information
    for (BluetoothDevice *device in connectedDevices) {
        
        // Add the device to the list
        [connectedBTDevices addObject:[NSString stringWithFormat:@"%@", [device address]]];
        
    }
    
    // Set the dataset
    [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedClassicBTDevices:connectedBTDevices];
    
}

#pragma mark - HTTP Requests

// HTTP Requests
- (void)httpRequests {
    
    // Get device version information
    NSString *deviceType;
    struct utsname systemInfo;
    uname(&systemInfo);
    
    // Get the system info
    deviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // Create a url request
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.ineal.me/tss/all"]];
    
    // Create a JSON dictionary
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        // Get the JSON
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        // Run through all the json keys
        for (id typeKey in json) {
            
            // Check if the deviceType is equal to the JSON Key
            if ([deviceType isEqualToString:[NSString stringWithString:typeKey]]) {
                
                // Go through the subkeys
                for (id subKeys in [json objectForKey:typeKey]) {
                    
                    // Check if any of the subkeys is the firmwares key
                    if ([subKeys isEqualToString:@"firmwares"]) {
                        
                        // Go through all the objects in the firmwares key
                        for (id firmwareDicts in [subKeys objectForKey:@"firmwares"]) {
                            
                            // Check if it's equal to the current version
                            if([@"version" isEqualToString:[NSString stringWithString:firmwareDicts]]){
                                
                                // TODO: What is this doing?
                            }
                        }
                        
                    }
                    
                }
                
                // Break
                break;
            }
        }
        
        // Log the JSON
        NSLog(@"Async JSON: %@", json);
    }];
    
}

#pragma mark - Location Manager Delegate

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    // Set the long/lat location
    [[Sentegrity_TrustFactor_Datasets sharedDatasets] setLocation:newLocation];
    
    // Attempt to obtain geo data for country
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    // Get the reverse geocode location when finished
    [reverseGeocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        // Cancel any future requests
        [reverseGeocoder cancelGeocode];
        
        // Check for any errors
        if (error) {
            
            // Error exists, set DNE error
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemarkDNEStatus:DNEStatus_error];
            
        } else {
            
            // No Errors
            
            // Get placemark object
            CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
            
            // Set the placemark
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemark:myPlacemark];
            
        }
        
    }];
    
    // Stop all future updates (we only needed one)
    [manager stopUpdatingLocation];
    
}

@end
