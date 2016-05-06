//
//  SentegrityTAF_AppDelegate.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_AppDelegate.h"

// Permissions
#import "ISHPermissionKit.h"
#import "LocationPermissionViewController.h"
#import "ActivityPermissionViewController.h"
#import "SentegrityTAF_WelcomeViewController.h"


// Animated Progress Alerts
#import "MBProgressHUD.h"

// Sentegrity
#import "Sentegrity.h"



// Private
@interface SentegrityTAF_AppDelegate (private) <ISHPermissionsViewControllerDataSource, ISHPermissionsViewControllerDelegate, WelcomeViewControllerDelegate>

// Progress HUD
@property (nonatomic,strong) MBProgressHUD *hud;

@end

@implementation SentegrityTAF_AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
    // Call DAF superclass to handle rest of startup process
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
    
}

#pragma mark - Good DAF

// Setup NIBS
- (void)setupNibs {
    
    self.main2ViewController = [[SentegrityTAF_Main2ViewController alloc] initWithNibName:@"SentegrityTAF_Main2ViewController" bundle:nil];
    
}

// This is our override of the super class showUIForAction.
- (void)showUIForAction:(enum DAFUIAction)action withResult:(DAFWaitableResult *)result
{
    NSLog(@"DAFSkelAppDelegate: showUIForAction (%d)", action);
    
    //self.dashboardViewController dismissViewControllerAnimated:NO completion:nil];
    
    switch (action) {
            
        case AppStartup: {
 
            // Occurs on each application startup (foreground as well)
            
            /* SENTEGRITY:
             * Start ACTIVITY DISPATCHER here
             
             * DESCRIPTION FROM API DOCS
             * Occurs after the GD runtime is initialized, and before GD's 'authorize' is called.
             * The app should set a root view controller for DAFAppBase::gdWindow . Other views
             * (e.g. password entry) will appear over it. Typically the root view will allow maintenance
             * actions (such as 'lock application', 'change password') to be initiated.
             */
            
            // Wipe out all previous datasets (in the event this is not the first run)
            [Sentegrity_TrustFactor_Datasets selfDestruct];
            
            // Create the activity dispatcher
            if (!_activityDispatcher) {
                // Allocate the activity dispatcher
                _activityDispatcher = [[Sentegrity_Activity_Dispatcher alloc] init];
            }
            
            // Start Netstat
            [_activityDispatcher startNetstat];
            
            // Start Bluetooth as soon as possible
            [_activityDispatcher startBluetoothBLE];
            
            //Check application's permissions to run the different activities and set DNE status
            [self checkApplicationPermission];
            
            // Setup the nibs
            [self setupNibs];
            
            // Show the main view controller
            //[self.gdWindow setRootViewController:self.mainViewController ];
            //[self.gdWindow makeKeyAndVisible];
            
           // NSDictionary *launchOptions = [[GDiOS sharedInstance] launchOptions];
            
            
            
             //NSLog(@"options: %@", [[GDiOS sharedInstance] launchOptions]);
            
            // Done
            break;
            
        }
            
        case GetAuthToken_WithWarning:
            // If a warning is present it will be shown here prior to starting the authetnication process
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
            // Close dashboard regardless
            
            // Tell mainview controller that easyActivation is happening
            //[self.mainViewController setEasyActivation:YES];
            
            // Dismess any existing
            // [self.dashboardViewController dismissViewControllerAnimated:NO completion:nil];
            
            // Show main
            [self.gdWindow setRootViewController:self.main2ViewController];
            [self.gdWindow makeKeyAndVisible];
            
            [self.main2ViewController showAuthWarningWithResult:result];
         
            // Done
            break;
            
        case GetPassword_FirstTime:
            
            
            // Prompts for user to create password
            
            /* SENTEGRITY:
             * We are "layering" over the existing password mechanism by passing in our MASTER_KEY
             * instead of what would normally be the user's password. Here we will generate the Core Detection startup file
             * we will show Ivo's create password view controller and once a password is accepted
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
            
            // Set the security policy provided by Good so we can enforce it during password creation
            //[self.passwordCreationViewController setSecurityPolicy:[self.gdTrust securityPolicy]];
            
            // Show main
            [self.gdWindow setRootViewController:self.main2ViewController];
            [self.gdWindow makeKeyAndVisible];
            
            [self.main2ViewController showWelcomePermissionAndPassWordCreationWithResult:result];
            
            // Update the startup file with the email
            //[[Sentegrity_Startup_Store sharedStartupStore] updateStartupFileWithEmail:[[gdLibrary getApplicationConfig] objectForKey:GDAppConfigKeyUserId] withError:nil];
            
            // Done
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
            
            // Reset easy activation var set when easy activation is attempted, this prevents main from showing the dashboard when it re-appears

            // Show main
            [self.gdWindow setRootViewController:self.main2ViewController];
            [self.gdWindow makeKeyAndVisible];
            
            // Set result so when unlock is invoked from within we can pass it on
            [self.main2ViewController setResult:result];
            [self.unlockViewController setResult:result];
            
            // Show the password unlock view controller
            //[self.unlockViewController setResult:result];

            // Below is required for easy activation to work
            if([self.main2ViewController easyActivation] == YES){
                [self.main2ViewController showUnlockWithResult:result];
            }
            // Reset values
            [self.main2ViewController setEasyActivation:NO];
            [self.main2ViewController setGetPasswordCancelled:NO];
            
            // Done
            break;
            
        case GetOldPassword:
            // setResult to string containing old password during password change
            // NA (NOT IMPLEMENTED YET IN SENTEGRITY)
            
            /* DESCRIPTION FROM API DOCS:
             * When a user password is being changed, this should present a screen requesting the user's old (existing) password.
             * DAFAppBase::passwordViewController provides a simple implementation of this function.
             */
            
            // Super
            [super showUIForAction:action withResult:result];
            
            // Done
            break;
            
        case GetNewPassword:
            // setResult to string containing new password during password change
            // NA (NOT IMPLEMENTED YET IN SENTEGRITY)
            
            /* DESCRIPTION FROM API DOCS:
             * When a user password is being changed, this should present a screen requesting the user to set a new password.
             * DAFAppBase::passwordViewController provides a simple implementation of this function.
             */
            
            // Super
            [super showUIForAction:action withResult:result];
            
            // Done
            break;

            
        case GetAuthToken:
            /* SENTEGRITY:
             * Start ACTIVITY DISPATCHER here prior to GetPassword running
             (gets a head start for async function when the app is already running)
             
             * DESCRIPTION FROM API DOCS
             * Occurs after the GD runtime is initialized, and before GD's 'authorize' is called.
             * The app should set a root view controller for DAFAppBase::gdWindow . Other views
             * (e.g. password entry) will appear over it. Typically the root view will allow maintenance
             * actions (such as 'lock application', 'change password') to be initiated.
             */
            
            // Wipe out all previous datasets (in the event this is not the first run)
            [Sentegrity_TrustFactor_Datasets selfDestruct];
            
            // Create the activity dispatcher
            if (!_activityDispatcher) {
                // Allocate the activity dispatcher
                _activityDispatcher = [[Sentegrity_Activity_Dispatcher alloc] init];
            }
            
            // Need to add dispatcher for "Route"
            
            // Start Netstat
            [_activityDispatcher startNetstat];
            
            // Start Bluetooth as soon as possible
            [_activityDispatcher startBluetoothBLE];
            
            // Super
            [super showUIForAction:action withResult:result];
            
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
    //NSLog(@"SentegrityTAF_AppDelegate: we got an event notification, type=%d message='%@'", event, msg);
    [super eventNotification:event withMessage:msg];
    
    //If == AuthorizationSucceeded, don't show Sentegrity Dashboard
    
    [self.main2ViewController updateUIForNotification:event];

}



#pragma mark - ISHPermissionKit

/*
- (void) welcomeFinished {
    
    //if there is permissions, show permissions view controllers
    NSArray *permissions = [self checkApplicationPermission];
    
    // Check if we need to prompt for permission
    if (permissions && permissions.count > 0) {
        
        // Create the permissions view controller
        ISHPermissionsViewController *vc = [ISHPermissionsViewController permissionsViewControllerWithCategories:permissions dataSource:self];
        vc.delegate = self;
        
        // Check the permission view controller is valid
        if (vc && vc != nil) {
            
            // Dismiss welcome and Present the permissions kit view controller
            [self.mainViewController dismissViewControllerAnimated:YES completion:^{
                [self.mainViewController presentViewController:vc animated:YES completion:nil];
            }];
            
            // Completion Block
            [vc setCompletionBlock:^{
                
                // Permissions view controller finished
                
                // Check if permissions were granted
                
                // Location
                if ([[ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse] permissionState] == ISHPermissionStateAuthorized) {
                    
                    // Location allowed
                    
                    // Start the location activity
                    [_activityDispatcher startLocation];
                    
                }
                
                // Activity
                if ([[ISHPermissionRequest requestForCategory:ISHPermissionCategoryActivity] permissionState] == ISHPermissionStateAuthorized) {
                    
                    // Activity allowed
                    
                    // Start the activity activity
                    [_activityDispatcher startActivity];
                }
                
            }]; // Done permissions view controller
            
        } // Done checking permissions array
        
    } // Done permissions kit
    else {
        //no permissions, just show password creation screen
        [self.mainViewController dismissViewControllerAnimated:YES completion:^{
            [self.mainViewController presentViewController:self.passwordCreationViewController animated:NO completion:nil];
        }];
    }
}


// Check if the application has permissions to run the different activities, set DNE status and return list of permission
- (NSArray *) checkApplicationPermission {
    ISHPermissionRequest *permissionLocationWhenInUse = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
    ISHPermissionRequest *permissionActivity = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
    
    // Get permissions
    NSMutableArray *permissions = [[NSMutableArray alloc] initWithCapacity:2];
    
    // Check if location permissions are authorized
    if ([permissionLocationWhenInUse permissionState] != ISHPermissionStateAuthorized) {
        
        // Location not allowed
        
        // Set location error
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setLocationDNEStatus:DNEStatus_unauthorized];
        
        // Set placemark error
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemarkDNEStatus:DNEStatus_unauthorized];
        
        // Add the permission
        [permissions addObject:@(ISHPermissionCategoryLocationWhenInUse)];
        
    } else {
        
        // Location Authorized
        
        // Start Motion (must be after location since it uses the locationDNE to decide which magnetometer to use)
        [_activityDispatcher startMotion];
        
    } // Done location permissions
    
    // Check if activity permissions are authorized
    if ([permissionActivity permissionState] != ISHPermissionStateAuthorized) {
        
        // Activity not allowed
        
        // The app isn't authorized to use motion activity support.
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unauthorized];
        
        // Add the permission
        [permissions addObject:@(ISHPermissionCategoryActivity)];
        
    } else {
        
        // Activity Authorized
        [_activityDispatcher startActivity];
        
    } // Done activity permissions
    
    return permissions;
}


- (void)permissionsViewControllerDidComplete:(ISHPermissionsViewController *)vc {
    
    //after location/activity permissions are finished, show password creation screen
    [self.mainViewController dismissViewControllerAnimated:YES
                                                completion:^{
                                                    [self.mainViewController presentViewController:self.passwordCreationViewController animated:NO completion:nil];

                                                }];
    
}


// Set the datasource method
- (ISHPermissionRequestViewController *)permissionsViewController:(ISHPermissionsViewController *)vc requestViewControllerForCategory:(ISHPermissionCategory)category {
    
    // Check which category
    if (category == ISHPermissionCategoryLocationWhenInUse) {

        // Create the location permission view controller
        LocationPermissionViewController *locationPermission = [[LocationPermissionViewController alloc] initWithNibName:@"LocationPermissionViewController" bundle:nil];
        
        // Return Location Permission View Controller
        return locationPermission;
    } else if (category == ISHPermissionCategoryActivity) {
        
        // Create the activity permission view controller
        ActivityPermissionViewController *activityPermission = [[ActivityPermissionViewController alloc] initWithNibName:@"ActivityPermissionViewController" bundle:nil];
        
        // Return Activity Permission View Controller
        return activityPermission;
    }
    
    // Don't know
    return nil;
}
 */

@end
