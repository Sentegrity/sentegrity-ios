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



@interface AppDelegate () <CBCentralManagerDelegate>

@end


@implementation AppDelegate

static MBProgressHUD *HUD;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    //Call async data functions such as location/core
    [self startLocation];
    
    [self startActivity];
    
    [self startMotion];
    
    [self startBluetoothBLE];
    
    [self startBluetoothClassic];
    
    
    
    // Override point for customization after application launch.
    
    // Get the storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Set up the navigation controller
    //UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"mainviewcontroller"]];
    // Set up the navigation controller
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"]];
    
    
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
    [self startLocation];
    
    [self startActivity];
    
    [self startMotion];
    
    [self startBluetoothBLE];
    
    [self startBluetoothClassic];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

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
    
    // stop all future updates (we only needed one)
    [manager stopUpdatingLocation];
    
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
    
}

-(void)startActivity{
    
    
    if(![CMMotionActivityManager isActivityAvailable]){
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unsupported];
        
    }else{
        
        CMMotionActivityManager *manager = [CMMotionActivityManager new];
        
               [manager queryActivityStartingFromDate:[NSDate dateWithTimeIntervalSinceNow:-(60*5)]
                                        toDate:[NSDate date]
                                       toQueue:[NSOperationQueue new]
                                   withHandler:^(NSArray *activities, NSError *error) {
                                       
                                       // Stop future updates as this only gets called once
                                       [manager stopActivityUpdates];
                                       
                                       if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                           // The app isn't authorized to use motion activity support.
                                           [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unauthorized];
                                       }
                                       else{
                                           
                                           // Set activities array
                                           [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPreviousActivities:activities];
                                           
                                           
                                       }
                                       
                                   }];
        
        
        
    }
    
    
}

static int pitchRunCount = 0;
static int radsRunCount = 0;
static NSMutableArray *pitchRollArray;
static NSMutableArray *radsArray;
-(void)startMotion{
    
    
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    pitchRollArray = [[NSMutableArray alloc]init];
    radsArray = [[NSMutableArray alloc]init];
    
    // Accelerometer
    
    if(![manager isGyroAvailable] || manager == nil){
        
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unsupported];
        
    }else{
        
        // User Grip
        manager.deviceMotionUpdateInterval = .001;
        [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                      withHandler:^(CMDeviceMotion  *motion, NSError *error) {
                                          
                                          
                                          if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                              // The app isn't authorized to use motion activity support.
                                              [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroMotionDNEStatus:DNEStatus_unauthorized];
                                          }
                                          else{
                                              
                                              // Create an array of motion samples
                                              NSArray *ItemArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:motion.attitude.pitch], [NSNumber numberWithFloat:motion.attitude.roll], nil];
                                              
                                              // Create an array of keys
                                              NSArray *KeyArray = [NSArray arrayWithObjects:@"pitch", @"roll", nil];
                                              
                                              // Create the dictionary
                                              NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                                              
                                              // Add sample to array
                                              [pitchRollArray addObject:dict];
                                              
                                              // Increment run count
                                              pitchRunCount = pitchRunCount + 1;
                                              
                                              // We want a minimum of 3 samples before we average them inside the TF
                                              // its possible we will get more as this handler gets called additional times prior to
                                              // the TF needing the dataset, but we don't want to cause it to wait therefore we stick with a minimum of 3. If we get more it will continue to update
                                        
                                              // Keep updating until we stop
                                            if (pitchRunCount > 3){
                                                [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroRollPitch:pitchRollArray];
                                                  [manager stopDeviceMotionUpdates];
                                            }
                                              
                                          }
                                          
                                      }];
        
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
                                     [radsArray addObject:dict];
                                     
                                     // Increment run count
                                     radsRunCount = radsRunCount + 1;
                                     
                                     // We want a minimum of 3 samples before we average them inside the TF
                                     // its possible we will get more as this handler gets called additional times prior to
                                     // the TF needing the dataset, but we don't want to cause it to wait therefore we stick with a minimum of 3. If we get more it will continue to update
                                     
                                     // Keep updating until we stop
                                     
                                     if (radsRunCount > 3){
                                         [[Sentegrity_TrustFactor_Datasets sharedDatasets] setGyroRads:radsArray];
                                         [manager stopGyroUpdates];
                                     }
                                     
                                 }
                                 
                             }];

        
        
    }
    

}


static CBCentralManager *mgr;
static NSMutableArray *discoveredBLEDevices;
static CFAbsoluteTime startTime=0.0;

- (void) startBluetoothBLE{
    
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
    
    // we've waited more than 1 seconds OR exceeded max devices so stop scan
    if ((currentTime-startTime) > 1.0 || discoveredBLEDevices.count >= 3){
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


static NSMutableArray *connectedClassicBTDevices;

-(void)startBluetoothClassic{
    // Start
    [[MDBluetoothManager sharedInstance] registerObserver:self];
    
}

- (void)receivedBluetoothNotification:
(MDBluetoothNotification)bluetoothNotification
{
    
    if([[MDBluetoothManager sharedInstance] bluetoothIsPowered]){
        
        
        NSArray *connectedDevices = [[BluetoothManager sharedInstance] connectedDevices];
        
        connectedClassicBTDevices = [[NSMutableArray alloc]init];
        
        // Run through all found devices information
        for (BluetoothDevice *device in connectedDevices) {
            
            // Add the device  to the list
            [connectedClassicBTDevices addObject:[NSString stringWithFormat:@"%@",[device address]]];
            
            
        }
        
         [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedClassicBTDevices:connectedClassicBTDevices];
        
    }else{
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setConnectedClassicDNEStatus:DNEStatus_disabled];
        
    }
    
}

@end
