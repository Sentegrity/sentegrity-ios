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

//#pragma mark - App Delegate Functions


//// Application did finish launching
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //// Override point for customization after application launch.
    
    //// Get the storyboard
    //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //// Create a navigation controller
    //UINavigationController *controller;
    
    //// Create the activity dispatcher
    //if (!_activityDispatcher) {
        //// Allocate the activity dispatcher
        //_activityDispatcher = [[Sentegrity_Activity_Dispatcher alloc] init];
    //}
    
    //// Run the activites from the dispatcher
    //[_activityDispatcher startBluetoothBLE];
    //[_activityDispatcher startMotion];
    
    //// Set up the navigation controller
    //controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"]];
    
    //// Hide the navigation bar
    //[controller setNavigationBarHidden:YES];
    
    //// Create the side menu controller
    //RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:controller leftMenuViewController:nil rightMenuViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"rightmenuviewcontroller"]];
    
    //// Set the light content status bar
    //[sideMenuViewController setMenuPreferredStatusBarStyle:UIStatusBarStyleDefault];
    
    //// Don't scale content view
    //[sideMenuViewController setScaleContentView:NO];
    
    //// Make it a root controller
    ////self.window.rootViewController = sideMenuViewController;
    
    //// Return YES
    //return YES;
//}

//- (void)applicationWillResignActive:(UIApplication *)application {
    //// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    //// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//}

//- (void)applicationDidEnterBackground:(UIApplication *)application {
    //// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    //// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//}

//- (void)applicationWillEnterForeground:(UIApplication *)application {
    //// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    ////Call async data functions such as location/core
    ////[self runCoreDetectionActivities];
//}

//- (void)applicationDidBecomeActive:(UIApplication *)application {
    //// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    ////Call async data functions such as location/core
    ////[self runCoreDetectionActivities];
//}

//- (void)applicationWillTerminate:(UIApplication *)application {
    //// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//}

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
//
//                                // TODO: What is this doing?
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

#pragma mark - Good DAF

- (void)setupNibs
{
    NSLog(@"DAFSkelAppDelegate: setupNibs");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.mainViewController = [[DAFSkelMainViewController alloc]
                                   initWithNibName:@"DAFSkelMainViewController_iPhone"
                                   bundle:nil];
        self.firstTimeViewController = [[DAFSkelFirstTimeViewController alloc]
                                        initWithNibName:@"DAFSkelFirstTimeViewController_iPhone"
                                        bundle:nil];
        self.unlockViewController = [[DAFSkelUnlockViewController alloc]
                                     initWithNibName:@"DAFSkelUnlockViewController_iPhone"
                                     bundle:nil];
        self.easyActivationViewController = [[DAFSkelAuthWarningViewController alloc]
                                             initWithNibName:@"DAFSkelAuthWarningViewController_iPhone"
                                             bundle:nil];
        
    } else {
        self.mainViewController = [[DAFSkelMainViewController alloc]
                                   initWithNibName:@"DAFSkelMainViewController_iPad"
                                   bundle:nil];
        self.firstTimeViewController = [[DAFSkelFirstTimeViewController alloc]
                                        initWithNibName:@"DAFSkelFirstTimeViewController_iPad"
                                        bundle:nil];
        self.unlockViewController = [[DAFSkelUnlockViewController alloc]
                                     initWithNibName:@"DAFSkelUnlockViewController_iPad"
                                     bundle:nil];
        self.easyActivationViewController = [[DAFSkelAuthWarningViewController alloc]
                                             initWithNibName:@"DAFSkelAuthWarningViewController_iPad"
                                             bundle:nil];
    }
}

- (void)showUIForAction:(enum DAFUIAction)action withResult:(DAFWaitableResult *)result
{
    NSLog(@"DAFSkelAppDelegate: showUIForAction (%d)", action);
    switch (action)
    {
        case AppStartup:
            [self setupNibs];
            [self.gdWindow setRootViewController:self.mainViewController];
            [self.gdWindow makeKeyAndVisible];
            break;
            
        case GetAuthToken_FirstTime:
            NSLog(@"DAFSkelAppDelegate: starting activation UI");
            [self.firstTimeViewController setResult:result];
            [self.mainViewController presentViewController:self.firstTimeViewController animated:NO completion:nil];
            break;
            
        case GetAuthToken:
            NSLog(@"DAFSkelAppDelegate: starting unlock UI");
            [self.unlockViewController setResult:result];
            [self.mainViewController presentViewController:self.unlockViewController animated:NO completion:nil];
            break;
            
        case GetAuthToken_WithWarning:
            [self.easyActivationViewController setResult:result];
            [self.mainViewController presentViewController:self.easyActivationViewController animated:NO completion:nil];
            break;
            
        case GetPassword_FirstTime:
        case GetPassword:
        case GetOldPassword:
        case GetNewPassword:
        default:
            // Pass on all password requests (and any actions added in future)
            // to DAFAppBase's default implementation.
            [super showUIForAction:action withResult:result];
            break;
    }
}

- (void)eventNotification:(enum DAFUINotification)event withMessage:(NSString *)msg
{
    NSLog(@"DAFSkelAppDelegate: we got an event notification, type=%d message='%@'", event, msg);
    [super eventNotification:event withMessage:msg];
    [self.mainViewController updateUIForNotification:event];
    [self.firstTimeViewController updateUIForNotification:event];
    [self.unlockViewController updateUIForNotification:event];
    [self.easyActivationViewController updateUIForNotification:event];
}

@end
