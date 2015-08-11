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

#import "Sentegrity_TrustFactor_Rule.h"

@interface AppDelegate () <CBCentralManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Call async data functions such as location/core
    [self startLocation];
    
    [self startActivity];
    
    [self startMotion];
    
    [self startBluetooth];
    
    
    // Override point for customization after application launch.
    
    // Get the storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Set up the navigation controller
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"mainviewcontroller"]];
    
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
        [Sentegrity_TrustFactor_Rule setLocationDNEStatus:DNEStatus_disabled];
        
        //Set placemark disabled
        [Sentegrity_TrustFactor_Rule setPlacemarkDNEStatus:DNEStatus_disabled];
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
        [Sentegrity_TrustFactor_Rule setLocationDNEStatus:DNEStatus_unauthorized];
        
        //Set placemark unauthorized
        [Sentegrity_TrustFactor_Rule setPlacemarkDNEStatus:DNEStatus_unauthorized];
        
    }
    else{
        
        //Set location error
        [Sentegrity_TrustFactor_Rule setLocationDNEStatus:DNEStatus_unauthorized];
        
        //Set placemark error
        [Sentegrity_TrustFactor_Rule setPlacemarkDNEStatus:DNEStatus_unauthorized];
    }
    
    
}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    // stop all future updates (we only needed one)
    [manager stopUpdatingLocation];
    
    // Set the long/lat location
    [Sentegrity_TrustFactor_Rule setLocation:newLocation];
    
    // Attempt to obtain geo data for country
    CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
    
    [reverseGeocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         // Cancel any future requests
         
         [reverseGeocoder cancelGeocode];
         if (error){
             [Sentegrity_TrustFactor_Rule setPlacemarkDNEStatus:DNEStatus_error];
         }
         else{
             
             // Get placemark object
             CLPlacemark *myPlacemark = [placemarks objectAtIndex:0];
             
             // Set the placemark
             [Sentegrity_TrustFactor_Rule setPlacemark:myPlacemark];
             
         }
         
         
         
     }];
    
}

-(void)startActivity{
    
    
    if(![CMMotionActivityManager isActivityAvailable]){
        [Sentegrity_TrustFactor_Rule setActivityDNEStatus:DNEStatus_unsupported];
        
    }else{
        
        CMMotionActivityManager *manager = [CMMotionActivityManager new];
        
        
        [manager queryActivityStartingFromDate:[NSDate dateWithTimeIntervalSinceNow:-(60*10)]
                                        toDate:[NSDate new]
                                       toQueue:[NSOperationQueue new]
                                   withHandler:^(NSArray *activities, NSError *error) {
                                       
                                       // Stop future updates
                                       [manager stopActivityUpdates];
                                       
                                       if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                           // The app isn't authorized to use motion activity support.
                                           [Sentegrity_TrustFactor_Rule setActivityDNEStatus:DNEStatus_unauthorized];
                                       }
                                       else{
                                           
                                           // Set activities array
                                           [Sentegrity_TrustFactor_Rule setActivity:activities];
                                           
                                           
                                       }
                                       
                                   }];
        
    }
    
    
}

static int runCount = 0;
static NSMutableArray *array;
-(void)startMotion{
    
    
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    array = [[NSMutableArray alloc]init];
    
    if(![manager isAccelerometerAvailable] || manager == nil){
        
        [Sentegrity_TrustFactor_Rule setMotionDNEStatus:DNEStatus_unsupported];
        
    }else{
        
        manager.accelerometerUpdateInterval = .1;
        [manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                      withHandler:^(CMAccelerometerData  *motion, NSError *error) {
                                          
                                          
                                          if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                              // The app isn't authorized to use motion activity support.
                                              [Sentegrity_TrustFactor_Rule setMotionDNEStatus:DNEStatus_unauthorized];
                                          }
                                          else{
                                              
                                              // Create an array of motion samples
                                              NSArray *ItemArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:motion.acceleration.x], [NSNumber numberWithFloat:motion.acceleration.y], [NSNumber numberWithFloat:motion.acceleration.z], nil];
                                              
                                              // Create an array of keys
                                              NSArray *KeyArray = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
                                              
                                              // Create the dictionary
                                              NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                                              
                                              // Add sample to array
                                              [array addObject:dict];
                                              
                                              // Increment run count
                                              runCount = runCount + 1;
                                              
                                              // We want a minimum of 3 samples before we average them inside the TF
                                              // its possible we will get more as this handler gets called additional times prior to
                                              // the TF needing the dataset, but we don't want to cause it to wait therefore we stick with a minimum of 3. If we get more it will continue to update
                                              
                                              if(runCount == 3){
                                                  [Sentegrity_TrustFactor_Rule setMotion:array];
                                                  [manager stopAccelerometerUpdates];
                                              }
                                              
                                              
                                          }
                                          
                                      }];
        
        
    }
    
    
    
}


static CBCentralManager *mgr;
static NSMutableArray *bluetoothDevices;
static int maxDeviceCount=10;
static CFAbsoluteTime startTime=0.0;

- (void) startBluetooth{
    mgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [Sentegrity_TrustFactor_Rule setBluetooth:bluetoothDevices];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // Update timer with current time
    CFAbsoluteTime currentTime = 0.0;
    currentTime = CFAbsoluteTimeGetCurrent();
    
    // we've waited more than 3 seconds OR exceeded max devices so stop scan
    if ((currentTime-startTime) > 3.0 || bluetoothDevices.count >= maxDeviceCount){
        NSLog(@"Bluetooth scanning stopped");
        [mgr stopScan];
        
    }
    
    //NSLog(@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData);
    
    // Add the device dictionary to the list
    [bluetoothDevices addObject:[NSString stringWithFormat:@"%@",peripheral.identifier]];
    
    
    
    
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
            
            [Sentegrity_TrustFactor_Rule setBluetoothDNEStatus:DNEStatus_unsupported];
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            //messtoshow=[NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            
            [Sentegrity_TrustFactor_Rule setBluetoothDNEStatus:DNEStatus_unauthorized];
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            //messtoshow=[NSString stringWithFormat:@"Bluetooth is currently powered off."];
            
            [Sentegrity_TrustFactor_Rule setBluetoothDNEStatus:DNEStatus_disabled];
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            
            // Set bluetooth array
            bluetoothDevices = [[NSMutableArray alloc] init];
            
            // Set timer to eventually stop scanning (otherwise if we don't find any it will keep trying during app use and kill battery)
            startTime = CFAbsoluteTimeGetCurrent();
            
            // Start scanning for any peripheral
            [mgr scanForPeripheralsWithServices:nil options:nil];
            
            
            break;
        }
            
    }
    
}
@end
