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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Call async data functions such as location/core
    [self startLocation];
    
    [self startActivity];
    
    [self startMotion];
    
    
    // Override point for customization after application launch.
    
    // Get the storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    // Set up the navigation controller
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"contentViewController"]];
    
    // Hide the navigation bar
    [controller setNavigationBarHidden:YES];
    
    // Create side menu controller
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:controller leftMenuViewController:nil rightMenuViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"rightMenuViewController"]];
    
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
        
        //NSLog(@"Location services disabled");
        [Sentegrity_TrustFactor_Rule setLocationDNEStatus:DNEStatus_disabled];
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
        [Sentegrity_TrustFactor_Rule setLocationDNEStatus:DNEStatus_unauthorized];
        
    }
    else{
        [Sentegrity_TrustFactor_Rule setLocationDNEStatus:DNEStatus_error];
    }
    

}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    // stop all future updates (we only needed one)
    [manager stopUpdatingLocation];
    
    [Sentegrity_TrustFactor_Rule setLocation:newLocation];

}

-(void)startActivity{
    
    
    if(![CMMotionActivityManager isActivityAvailable]){
                [Sentegrity_TrustFactor_Rule setActivityDNEStatus:DNEStatus_unsupported];
        
    }else{
        
        CMMotionActivityManager *manager = [CMMotionActivityManager new];
        
        [manager queryActivityStartingFromDate:[NSDate dateWithTimeIntervalSinceNow:-2 * 60 * 60]
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

-(void)startMotion{
    
    
    CMMotionManager *manager = [[CMMotionManager alloc] init];
    
    if(![manager isDeviceMotionAvailable] || manager == nil){
        
        [Sentegrity_TrustFactor_Rule setMotionDNEStatus:DNEStatus_unsupported];
        
    }else{
        
         manager.deviceMotionUpdateInterval = .2;
        
        [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                     withHandler:^(CMDeviceMotion  *motion, NSError *error) {
                                         
                                        [manager stopDeviceMotionUpdates];
                                         
                                         if (error != nil && (error.code == CMErrorMotionActivityNotAuthorized || error.code == CMErrorMotionActivityNotEntitled)) {
                                             // The app isn't authorized to use motion activity support.
                                             [Sentegrity_TrustFactor_Rule setMotionDNEStatus:DNEStatus_unauthorized];
                                         }
                                         else{
                                             
                                             // Pass the raw values to the implementation such that rounding can be configured per policy
                                             NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:motion.userAcceleration.x],[NSNumber numberWithFloat:motion.userAcceleration.y],[NSNumber numberWithFloat:motion.userAcceleration.z], nil];
                                             

                                             [Sentegrity_TrustFactor_Rule setMotion:array];
                                             
                                         }
                                         
                                         
                                     }];
    
        
    }
    
    
    
}
@end
