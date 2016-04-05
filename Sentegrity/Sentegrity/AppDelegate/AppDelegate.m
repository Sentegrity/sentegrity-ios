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

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Private Interface Declaration
@interface AppDelegate () {
    
    // Progress HUD
    MBProgressHUD *hud;
    
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
    
    // Create the activity dispatcher
    if (!_activityDispatcher) {
        // Allocate the activity dispatcher
        _activityDispatcher = [[Sentegrity_Activity_Dispatcher alloc] init];
    }
    
    // Run the activites from the dispatcher ASAP
    [_activityDispatcher runCoreDetectionActivities];
    
    // Set up the navigation controller
    controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"]];
    
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

//#pragma mark - HTTP Requests
//
//// HTTP Requests
//- (void)httpRequests {
//
//    // Get device version information
//    NSString *deviceType;
//    struct utsname systemInfo;
//    uname(&systemInfo);
//
//    // Get the system info
//    deviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
//
//    // Create a url request
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.ineal.me/tss/all"]];
//
//    // Create a JSON dictionary
//    __block NSDictionary *json;
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//
//        // Get the JSON
//        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//
//        // Run through all the json keys
//        for (id typeKey in json) {
//
//            // Check if the deviceType is equal to the JSON Key
//            if ([deviceType isEqualToString:[NSString stringWithString:typeKey]]) {
//
//                // Go through the subkeys
//                for (id subKeys in [json objectForKey:typeKey]) {
//
//                    // Check if any of the subkeys is the firmwares key
//                    if ([subKeys isEqualToString:@"firmwares"]) {
//
//                        // Go through all the objects in the firmwares key
//                        for (id firmwareDicts in [subKeys objectForKey:@"firmwares"]) {
//
//                            // Check if it's equal to the current version
//                            if([@"version" isEqualToString:[NSString stringWithString:firmwareDicts]]){
//                            }
//                        }
//
//                    }
//
//                }
//
//                // Break
//                break;
//            }
//        }
//
//        // Log the JSON
//        NSLog(@"Async JSON: %@", json);
//    }];
//
//}

@end
