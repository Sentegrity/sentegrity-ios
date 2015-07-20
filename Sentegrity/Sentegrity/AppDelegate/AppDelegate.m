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

@end
