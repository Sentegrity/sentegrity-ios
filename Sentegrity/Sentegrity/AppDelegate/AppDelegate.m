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
@interface AppDelegate () <CBCentralManagerDelegate>
@end


@implementation AppDelegate

#pragma mark - ISHPermissionKit

static MBProgressHUD *HUD;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Get the storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *controller;
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        
        //Do something on first launch
        
        controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"]];
        
        
    }
    else{
        
        //Call async data functions such as location/core
        [self runCoreDetectionActivities];
        
        // Set up the navigation controller
        //UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"mainviewcontroller"]];
        // Set up the navigation controller
        controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"]];
        
    }
    
    
    
    // Hide the navigation bar
    [controller setNavigationBarHidden:YES];
    
    // Create side menu controller
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

#pragma mark - App Delegate Functions

- (void)runCoreDetectionActivities {
    // Run the Core Detection Activites
    
    [self startBluetoothBLE];
    
    [self startLocation];
    
    [self startActivity];
    
    [self startMotion];
    
    [self startBluetoothClassic];
}

#pragma mark - Core Detection Activities

- (void)startLocation {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    NSUInteger code = [CLLocationManager authorizationStatus];
    
    if(![CLLocationManager locationServicesEnabled]){
        
        //Set location disabled
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setLocationDNEStatus:DNEStatus_disabled];
        
        //Set placemark disabled
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setPlacemarkDNEStatus:DNEStatus_disabled];
    }
    else{
        
        if(code == kCLAuthorizationStatusNotDetermined && [_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
            
            
            [self.locationManager  requestWhenInUseAuthorization];
            
        }
    }
    
    
    if(code == kCLAuthorizationStatusAuthorizedWhenInUse){
        
        //set accuracy to low
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        //start
        [self.locationManager startUpdatingLocation];
        
    }
    else if(code ==kCLAuthorizationStatusDenied){
        
        //Set location unauthorized
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setLocationDNEStatus:DNEStatus_unauthorized];
        
        //Set placemark unauthorized
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setPlacemarkDNEStatus:DNEStatus_unauthorized];
        
    }
    else{
        
        //Set location error
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setLocationDNEStatus:DNEStatus_unauthorized];
        
        //Set placemark error
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemarkDNEStatus:DNEStatus_unauthorized];
    }
    
    
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    // Set the long/lat location
    [[Sentegrity_TrustFactor_Datasets sharedDatasets] setLocation:newLocation];
    
    // Attempt to obtain geo data for country
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    [reverseGeocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         // Cancel any future requests
         
         [reverseGeocoder cancelGeocode];
         if (error){
             [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemarkDNEStatus:DNEStatus_error];
         }
         else{
             
             // Get placemark object
             CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
             
             // Set the placemark
             [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemark:myPlacemark];
             
         }
         
     }];
    
    
    // stop all future updates (we only needed one)
    [manager stopUpdatingLocation];
    
}

-(void)startActivity{
    
    
    if(![CMMotionActivityManager isActivityAvailable]){
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unsupported];
        
    }else{
        
        CMMotionActivityManager *manager = [[CMMotionActivityManager alloc] init];
        
        [manager queryActivityStartingFromDate:[NSDate dateWithTimeIntervalSinceNow:-(60*5)]
                                        toDate:[NSDate date]
                                       toQueue:[NSOperationQueue new]
                                   withHandler:^(NSArray *activities, NSError *error) {
                                       
                                       
                                       
                                       if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                           // The app isn't authorized to use motion activity support.
                                           [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unauthorized];
                                           
                                           
                                       }
                                       else{
                                           
                                           // Set activities array
                                           [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPreviousActivities:activities];
                                           
                                           
                                       }
                                       
                                       // Stop future updates as this only gets called once
                                       [manager stopActivityUpdates];
                                       
                                   }];
        
        
        
    }
    
    
    
    
}




static NSMutableArray *pitchRollArray;
static NSMutableArray *gyroRadsArray;
static NSMutableArray *accelRadsArray;
static NSMutableArray *headingsArray;
-(void)startMotion{
    
    
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    pitchRollArray = [[NSMutableArray alloc]init];
    accelRadsArray= [[NSMutableArray alloc]init];
    gyroRadsArray = [[NSMutableArray alloc]init];
    headingsArray = [[NSMutableArray alloc]init];
    
    // Gyroscope
    
    if(![manager isGyroAvailable] || manager == nil){
        
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unsupported];
        
    }else{
        
        // User Grip & Calibrated Magnetics
        manager.deviceMotionUpdateInterval = .001;
        
        
        [manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical
                                                     toQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMDeviceMotion  *motion, NSError *error) {
                                         
                                         
                                         if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                             // The app isn't authorized to use motion activity support.
                                             [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unauthorized];
                                         }
                                         else{
                                             
                                             
                                             
                                             // Pitch/Roll

                                             
                                             // Create an array of motion samples
                                             NSArray *ItemArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:motion.attitude.pitch], [NSNumber numberWithFloat:motion.attitude.roll], nil];
                                             
                                             // Create an array of keys
                                             NSArray *KeyArray = [NSArray arrayWithObjects:@"pitch", @"roll", nil];
                                             
                                             // Create the dictionary
                                             NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                                             
                                             // Add sample to array
                                             [pitchRollArray addObject:dict];
                                             
                                             [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroRollPitch:pitchRollArray];
                                             

                                             
                                             if(manager.deviceMotion.magneticField.field.z != 0){
                                                 
         
                                                 // Create an array of headings samples
                                                 NSArray *ItemArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:manager.deviceMotion.magneticField.field.x], [NSNumber numberWithDouble:manager.deviceMotion.magneticField.field.y],[NSNumber numberWithDouble:manager.deviceMotion.magneticField.field.z], nil];
                                                 
                                                 // Create an array of keys
                                                 NSArray *KeyArray = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
                                                 
                                                 // Create the dictionary
                                                 NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                                                 
                                                 // Add sample to array
                                                 [headingsArray addObject:dict];
                                                 
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
        manager.gyroUpdateInterval = .001;
        [manager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                             withHandler:^(CMGyroData  *gyroData, NSError *error) {
                                 
                                 
                                 if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                     // The app isn't authorized to use motion activity support.
                                     [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unauthorized];
                                 }
                                 else{
                                     
                                     // Create an array of gyro samples
                                     NSArray *ItemArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:gyroData.rotationRate.x], [NSNumber numberWithFloat:gyroData.rotationRate.y], [NSNumber numberWithFloat:gyroData.rotationRate.z], nil];
                                     
                                     // Create an array of keys
                                     NSArray *KeyArray = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
                                     
                                     // Create the dictionary
                                     NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                                     
                                     // Add sample to array
                                     [gyroRadsArray addObject:dict];
                                     
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
    
    if(![manager isAccelerometerAvailable] || manager == nil){
        
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setAccelMotionDNEStatus:DNEStatus_unsupported];
        
    }else{
        
        
        
        // Used to detect orientation
        manager.accelerometerUpdateInterval = .001;
        [manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                      withHandler:^(CMAccelerometerData  *accelData, NSError *error) {
                                          
                                          
                                          if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                              // The app isn't authorized to use motion activity support.
                                              [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unauthorized];
                                          }
                                          else{
                                              
                                              
                                              // Create an array of gyro samples
                                              NSArray *ItemArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:accelData.acceleration.x], [NSNumber numberWithFloat:accelData.acceleration.y], [NSNumber numberWithFloat:accelData.acceleration.z], nil];
                                              
                                              // Create an array of keys
                                              NSArray *KeyArray = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
                                              
                                              // Create the dictionary
                                              NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                                              
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


static CBCentralManager *mgr;
static NSMutableArray *discoveredBLEDevices;
static CFAbsoluteTime startTime=0.0;

- (void) startBluetoothBLE{
    
    startTime = CFAbsoluteTimeGetCurrent();
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerOptionShowPowerAlertKey, nil];
    
    
    mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    
}


// Callback for currentlyConnected
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    
    
    //[[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedBLEDevices:peripherals];
    
    
}

// Callback for didDiscoverPeripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // Add the device dictionary to the list
    [discoveredBLEDevices addObject:[NSString stringWithFormat:@"%@",peripheral.identifier.UUIDString]];
    
    [[Sentegrity_TrustFactor_Datasets sharedDatasets] setDiscoveredBLEDevices:discoveredBLEDevices];
    
    // Update timer with current time
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    
    // stop scanning after 2 seconds (this has no bearing on CD execution time)
    if ((currentTime-startTime) > 2.0){
        NSLog(@"Bluetooth scanning stopped");
        [mgr stopScan];
        
    }
    
    
    
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    
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
            //messtoshow=[NSString stringWithFormat:@"The platform doesn't support Bluetooth Low Energy"];
            
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setDiscoveredBLESDNEStatus:DNEStatus_unsupported];
            // [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedBLEDNEStatus:DNEStatus_unsupported];
            
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            //messtoshow=[NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setDiscoveredBLESDNEStatus:DNEStatus_unauthorized];
            // [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedBLEDNEStatus:DNEStatus_unauthorized];
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            //messtoshow=[NSString stringWithFormat:@"Bluetooth is currently powered off."];
            
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setDiscoveredBLESDNEStatus:DNEStatus_disabled];
            //[[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedBLEDNEStatus:DNEStatus_disabled];
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            
            // Set bluetooth array
            discoveredBLEDevices = [[NSMutableArray alloc] init];
            
            // Set timer to eventually stop scanning (otherwise if we don't find any it will keep trying during app use and kill battery)
            startTime = CFAbsoluteTimeGetCurrent();
            
            // Start scanning for any peripheral
            
            
            [mgr scanForPeripheralsWithServices:nil options:nil];
            
            // Retrieve list of paired
            //[mgr retrieveConnectedPeripheralsWithServices:nil];
            
            
            break;
        }
            
    }
    
}


static NSMutableArray *connectedBTDevices;

-(void)startBluetoothClassic{
    // Start
    [[MDBluetoothManager sharedInstance] registerObserver:self];
    
}

- (void)receivedBluetoothNotification:
(MDBluetoothNotification)bluetoothNotification
{
    
    if([[MDBluetoothManager sharedInstance] bluetoothIsPowered] && ([[Sentegrity_TrustFactor_Datasets sharedDatasets] discoveredBLESDNEStatus] != DNEStatus_disabled)){
        
        
        NSArray *connectedDevices = [[BluetoothManager sharedInstance] connectedDevices];
        
        connectedBTDevices = [[NSMutableArray alloc]init];
        
        // Run through all found devices information
        for (BluetoothDevice *device in connectedDevices) {
            
            // Add the device  to the list
            [connectedBTDevices addObject:[NSString stringWithFormat:@"%@",[device address]]];
            
            
        }
        
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedClassicBTDevices:connectedBTDevices];
        
    }else{
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedClassicDNEStatus:DNEStatus_disabled];
        
    }
    
}


-(void)httpRequests{
    // Get latest version
    NSString *deviceType;
    struct utsname systemInfo;
    uname(&systemInfo);
    deviceType = [NSString stringWithCString:systemInfo.machine
                                    encoding:NSUTF8StringEncoding];
    
    
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.ineal.me/tss/all"]];
    
    
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               
                               for(id typeKey in json){
                                   if([deviceType isEqualToString:[NSString stringWithString:typeKey]]){
                                       
                                       for(id subKeys in [json objectForKey:typeKey]){
                                           
                                           if([subKeys isEqualToString:@"firmwares"]){
                                               
                                               for(id firmwareDicts in [subKeys objectForKey:@"firmwares"]){
                                                   
                                                   if([@"version" isEqualToString:[NSString stringWithString:firmwareDicts]]){
                                                       
                                                       
                                                   }
                                               }
                                               
                                           }
                                           
                                       }
                                       break;
                                   }
                               }
                               NSLog(@"Async JSON: %@", json);
                           }];
    
    
}


@end
