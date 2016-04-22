//
//  SentegrityTAF_AppDelegate.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_AppDelegate.h"

// Side Menu
#import "RESideMenu.h"

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Private Interface Declaration
@interface SentegrityTAF_AppDelegate () {
    
    // Progress HUD
    MBProgressHUD *hud;
    
}

@end


@implementation SentegrityTAF_AppDelegate

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

// This is our override of the super class showUIForAction.
- (void)showUIForAction:(enum DAFUIAction)action withResult:(DAFWaitableResult *)result
{
    NSLog(@"DAFSkelAppDelegate: showUIForAction (%d)", action);
    switch (action)
    {
        case AppStartup:
            // Occurs on each application startup (foreground as well)
            
            /* SENTEGRITY:
             * Start ACTIVITY DISPATCHER here
             
             * DESCRIPTION FROM API DOCS
             * Occurs after the GD runtime is initialized, and before GD's 'authorize' is called.
             * The app should set a root view controller for DAFAppBase::gdWindow . Other views
             * (e.g. password entry) will appear over it. Typically the root view will allow maintenance
             * actions (such as 'lock application', 'change password') to be initiated.
             */
            
            [self setupNibs];
            [self.gdWindow setRootViewController:self.mainViewController];
            [self.gdWindow makeKeyAndVisible];
            break;
            
        case GetAuthToken_FirstTime:
            // Used to connect to a hardware device for the first time ever
            // Sentegrity doesn't use this, just pass it back
            
            /* DESCRIPTION FROM API DOCS:
             * Occurs when DAF is about to call DADevice::createSession during the initial
             * application setup sequence. If user interaction is required to choose a device
             * and/or assist with its initial connection, a suitable view should be shown in response to this event.
             */
            
            NSLog(@"DAFSkelAppDelegate: starting activation UI");
            [super showUIForAction:action withResult:result];
            //[self.firstTimeViewController setResult:result];
            //[self.mainViewController presentViewController:self.firstTimeViewController animated:NO completion:nil];
            break;
            
        case GetAuthToken:
            // This is used to connect to a hardware device and establish a "session"
            // Sentegrity doesn't use this, just pass this back
            
            /* DESCRIPTION FROM API DOCS:
             * Occurs when DAF is about to call DADevice::createSession to reconnect to the device used
             * for authentication. This may be used to prompt the user to activate the device, give a status report, and so on.
             */
            
            NSLog(@"DAFSkelAppDelegate: starting unlock UI");
            [super showUIForAction:action withResult:result];
            
            //[self.unlockViewController setResult:result];
            //[self.mainViewController presentViewController:self.unlockViewController animated:NO completion:nil];
            break;
            
        case GetAuthToken_WithWarning:
            // If a warning is present it will be showed here prior to starting the authetnication process
            // These are warnings that come from the GD runtime such as "easy activation" when other Good apps are present
            // Sentegrity doesn't use this, let the default view controllers handle it
            
            /* DESCRIPTION FROM API DOCS:
             * This is used when a warning must be shown to the user before starting an authentication sequence, for
             * example when processing an Easy Activation request. The warning is described by a DAFAuthenticationWarning
             * object, which can be accessed using the DAFAppBase::authWarning property.
             *
             * The user should be given an option to reject the request for authentication; in this case cancelAuthenticateWithWarn:
             * (DAFAppBase) should be called.
             *
             * The application should not ignore this request. Passing it back to the default
             * showUIForAction:withResult: (DAFAppBase) handler will result in the authentication request being rejected.
             */
            
            // We can call the default view controllers here, but don't pass it back to "[super showUIForAction:action withResult:result];"
            [self.easyActivationViewController setResult:result];
            [self.mainViewController presentViewController:self.easyActivationViewController animated:NO completion:nil];
            break;
            
        case GetPassword_FirstTime:
            // Prompts for user to create password
            
            /* SENTEGRITY:
             * We are "layering" over the existing password mechanism by passing in our MASTER_KEY
             * instead of what would normally be the user's password. Here we will generate the Core Detection startup file
             * we will show Ivo's creat password view controller and once a password is accepted
             * call the startup file to create a new one using this password. 
             
             * NSString *masterKeyString = [[Sentegrity_Startup_Store sharedStartupStore] populateNewStartupFileWithUserPassword:password withError:error];
             
             * In response, the startup file will be created and will return a masterKey a string, this MASTER_KEY can be used
             * to setResult here and complete the first time setup process.

             
             
             * DESCRIPTION FROM API DOCS:
             * Where a user password is required (see DA_AUTH_PUBLIC), this should present a screen which allows the user
             * to set an initial password. This event occurs during the application setup sequence.
             *
             * DAFAppBase::passwordViewController provides a simple (built in) implementation of this function.
             */
            
            // REMOVED THIS SUPER CALL ONCE IMPLEMENT SENTEGRITY VIEWCONTROLLER (IT SHOWS THE DEFAULT)
            [super showUIForAction:action withResult:result];
            
            break;
        case GetPassword:
            // Prompts for user password/authentication
            
            /* SENTEGRITY:
             * Run core detection and analyze core detection results here
             * Results can be analyzed using analyzePreAuthenticationActionsWithError() (see LoginViewController inside Sentegrity Project)
             * The goal here is to basically port all the functionality from LoginViewController in the standalone Sentegrity app to here
             * and analyzed specifically, the preAuthenticationAction
             * If preAuthenticationAction=Transparently_Authentication we simply setResult here to MASTER_KEY (convert to string first)
             * If preAuthenticationAction=promptUserForPassword or promptUserForPasswordAndWarn
             * then show Ivo's Login view controller, in the event of "AndWarn" we show the popup box once LoginViewcontroller loads
             * If preAuthenticationAction=BlockAndWarn we can invoke the popup w/ message once LoginViewcontroller loads and
             * hide the input boxes
             *
             * If the user successfully authenticates via Ivo's login screen
             * (loginResponseObject.authenticationResponseCode = authenticationResult_Success)
             * the MASTER_KEY will have been returned in the loginResponseObject and we can setResult with it here
             
             
             * DESCRIPTION FROM API DOCS:
             * Where a user password is required (see DA_AUTH_PUBLIC), this should present a screen prompting the
             * user to enter their password in order to complete authentication.
             
             * DAFAppBase::passwordViewController provides a simple implementation of this function.
             */
            
            // REMOVED THIS SUPER CALL ONCE IMPLEMENT SENTEGRITY VIEWCONTROLLER (IT SHOWS THE DEFAULT)
            [super showUIForAction:action withResult:result];
            break;
        case GetOldPassword:
            // setResult to string containing old password during password change
            // NA (NOT IMPLEMENTED YET IN SENTEGRITY)
            
            /* DESCRIPTION FROM API DOCS:
             * When a user password is being changed, this should present a screen requesting the user's old (existing) password.
             * DAFAppBase::passwordViewController provides a simple implementation of this function.
             */
            
            break;
        case GetNewPassword:
            // setResult to string containing new password during password change
            // NA (NOT IMPLEMENTED YET IN SENTEGRITY)
            
            /* DESCRIPTION FROM API DOCS:
             * When a user password is being changed, this should present a screen requesting the user to set a new password.
             * DAFAppBase::passwordViewController provides a simple implementation of this function.
             */
            
            break;
        default:
            
            // Pass on all other requests (and any actions added in future)
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
