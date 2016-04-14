//
//  ViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Main View Controller
#import "LoginViewController.h"

// App Delegate
#import "AppDelegate.h"

// Permissions
#import "ISHPermissionKit.h"
#import "LocationPermissionViewController.h"
#import "ActivityPermissionViewController.h"

// Import the datasets
#import "Sentegrity_TrustFactor_Datasets.h"

// Startup Store
#import "Sentegrity_Startup_Store.h"

// Authentication helper
#import "Sentegrity_LoginAction.h"

@interface LoginViewController () <ISHPermissionsViewControllerDataSource>

/* Properties */

@property (nonatomic,strong) Sentegrity_TrustScore_Computation *computationResults;


@end


@implementation LoginViewController

static MBProgressHUD *HUD;

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// View Loaded
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
    // Update Status Bar appearance
    [self setNeedsStatusBarAppearanceUpdate];
}


// View did appear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Log the start time
    NSDate *methodStart = [NSDate date];
    
    /** START SENTEGRITY CODE **/
    
    // Wipe out all previous datasets (in the event this is not the first run)
    [Sentegrity_TrustFactor_Datasets selfDestruct];

    
    // Start Netstat
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startNetstat];
    
    // Start Bluetooth as soon as possible
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startBluetoothBLE];
    
    // Check if the application has permissions to run the different activities
    ISHPermissionRequest *permissionLocationWhenInUse = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
    ISHPermissionRequest *permissionActivity = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
    
    // Check if permissions are authorized
    if ([permissionLocationWhenInUse permissionState] != ISHPermissionStateAuthorized || [permissionActivity permissionState] != ISHPermissionStateAuthorized) {
        
        if([permissionLocationWhenInUse permissionState] != ISHPermissionStateAuthorized) {
            // Set location error
            [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setLocationDNEStatus:DNEStatus_unauthorized];
            
            // Set placemark error
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemarkDNEStatus:DNEStatus_unauthorized];
        }
        
        // Start Motion (must be after location since it uses the locationDNE to decide which magnetometer to use)
        [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startMotion];
        
        if([permissionActivity permissionState] != ISHPermissionStateAuthorized) {
            
            // The app isn't authorized to use motion activity support.
            [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unauthorized];
        }
        
        
        // Prompt for user to allow motion and location activity gathering
        NSArray *permissions = @[@(ISHPermissionCategoryLocationWhenInUse), @(ISHPermissionCategoryActivity)];
        
        // Create the view controller
        ISHPermissionsViewController *vc = [ISHPermissionsViewController  permissionsViewControllerWithCategories:permissions dataSource:self];
        
        
        
        // Check the permission view controller is valid
        if (vc) {
            
            // Present the permissions kit view controller
            [self presentViewController:vc animated:YES completion:nil];
            
            // Completion Block
            [vc setCompletionBlock:^{
                
                // Permissions view controller finished
                
                // Check if permissions were granted
                
                // Location
                if ([[ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse] permissionState] == ISHPermissionStateAuthorized) {
                    
                    // Location allowed
                    
                    // Start the location activity
                    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startLocation];
                    
                }
                
                // Activity
                if ([[ISHPermissionRequest requestForCategory:ISHPermissionCategoryActivity] permissionState] == ISHPermissionStateAuthorized) {
                    
                    // Activity allowed
                    
                    // Start the activity activity
                    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startActivity];
                }
                
            }];
        }
        
    } else {
        
        // Start the location activity
        [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startLocation];
        
        // Start the activity activity
        [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startActivity];
        
        // Start Motion (must be after locaation since it uses the locationDNE to decide which magnetometer to use)
        [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startMotion];
        
    }
    

    
    // Show Animation
    HUD =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    HUD.labelText = @"Analyzing";
    HUD.labelFont = [UIFont fontWithName:@"OpenSans-Bold" size:25.0f];
    
    HUD.detailsLabelText = @"Mobile Security Posture";
    HUD.detailsLabelFont = [UIFont fontWithName:@"OpenSans-Regular" size:18.0f];
    
    @autoreleasepool {
        
        dispatch_queue_t myQueue = dispatch_queue_create("Core_Detection_Queue",NULL);
        
        dispatch_async(myQueue, ^{
            
            // Perform Core Detection
            [self performCoreDetection:self];
            
        });
    }
    
    // Log the finish time
    NSDate *methodFinish = [NSDate date];
    
    // Get the execution Time
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    
    // Log the TrustFactor Execution Time
    NSLog(@"Core Detection Kickoff - Execution Time = %f seconds", executionTime);
    
}

// Perform Core Detection
- (void)performCoreDetection:(id)sender {
    
    
    // upload run history (if necessary) and check for new policy
    [[Sentegrity_Network_Manager shared] uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback:^(BOOL successfullyExecuted, BOOL successfullyUploaded, BOOL newPolicyDownloaded, NSError *error) {
        
        if (!successfullyExecuted) {
            // something went wrong somewhere (uploading, or new policy)
            NSLog(@"Error unable to run Network Manager:\n %@", error.debugDescription);
        }
        
        if (successfullyUploaded) {
            //error maybe occured on policy download, but it succesfully uploaded runHistoryObjects report
            [[Sentegrity_Startup_Store sharedStartupStore] setStartupStoreWithError:&error];
            
            // Check for an error
            if (error != nil) {
                // Unable to remove the store
                NSLog(@"Error unable to update startup store: %@", error.debugDescription);
            }
            else {
                NSLog(@"Network manager: Succesfully uploaded runHistoryObjects.");
            }
        }
        if (newPolicyDownloaded) {
            NSLog(@"Network manager: New policy downloaded and stored for the next run.");
        }
    }];
    
    
    
    /* Perform Core Detection */
    
    
    // Run Core Detection
    [[CoreDetection sharedDetection] performCoreDetectionWithCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
        
        // Check if core detection completed successfully
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [self analyzePreAuthenticationActionsWithError:error];
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                
            });
            
            // Log the errors
            NSLog(@"\n\nErrors: %@", [*error localizedDescription]);
            
        } else {
            // Core Detection Failed
            NSLog(@"Failed to run Core Detection: %@", [*error localizedDescription] ); // Here's why
        }
        
    }]; // End of the Core Detection Block
    
} // End of Core Detection Function


// Set up the customizations for the view
- (void)analyzePreAuthenticationActionsWithError:(NSError **)error {
    
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    switch (computationResults.preAuthenticationAction) {
        case preAuthenticationAction_TransparentlyAuthenticate:
        {
            // Attempt to login
            // we have no input to pass, use nil
            Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:nil andError:error];
            
            // Set the authentication response code
            computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
            
            // Set history now, we have all the info we need
            [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
            
            // Go through the authentication results
            switch (computationResults.authenticationResult) {
                case authenticationResult_Success:{ // No transparent auth errors
                    
                    // Now we could pass the key to the GD runtime
                    NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
                    
                    // For demo purposes we just go to landing page
                    // Show the landing page since we've been transparently authenticated
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                    
                    // Nick's Addition: Moved Break
                    break;
                    
                }
                default: //Transparent auth errored, something very wrong happened because the transparent module found a match earlier...
                {
                    // Have the user interactive login
                    // Manually override the preAuthenticationAction and recall this function, we don't need to run core detection again
                    
                    computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
                    computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
                    
                    [self analyzePreAuthenticationActionsWithError:error];
                    
                    // Nick's Addition: Moved Break
                    break;
                    
                }
                    
            } // Done Switch AuthenticationResult
            
            // Nick's Addition: Moved Break
            break;
            
        }
            
        case preAuthenticationAction_BlockAndWarn:
        {
            
            Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:nil andError:error];
            
            // Set the authentication response code
            computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
            
            // Set history now, we already have all the info we need
            [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
            
            SCLAlertView *blocked = [[SCLAlertView alloc] init];
            blocked.backgroundType = Shadow;
            [blocked removeTopCircle];
            
            [blocked addButton:@"TrustScore Details" actionBlock:^(void) {
                // Get the storyboard
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                // Create the main view controller
                DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                [self.navigationController pushViewController:mainViewController animated:NO];
            }];
            
            [blocked showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
            
            // Nick's Addition: Moved Break
            break;
            
        }
            
        case preAuthenticationAction_PromptForUserPassword:
        {
            
            SCLAlertView *userInput = [[SCLAlertView alloc] init];
            userInput.backgroundType = Transparent;
            userInput.showAnimationType = SlideInFromBottom;
            [userInput removeTopCircle];
            
            UITextField *userText = [userInput addTextField:@"Demo password is: user"];
            
            
            [userInput addButton:@"Login" actionBlock:^(void) {
                
                Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:userText.text andError:error];
                
                // Set the authentication response code
                computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
                
                // Set history now, we already have all the info we need
                [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
                
                // Success and recoverable errors operate the same since we still managed to get a decrypted master key
                if(computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError ) {
                    
                    // Now we could pass the key to the GD runtime
                    NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
                    
                    // For demo purposes we just go to landing page
                    
                    // Show the landing page since we've been transparently authenticated
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                    
                    
                }
                else if(computationResults.authenticationResult == authenticationResult_incorrectLogin)
                {
                    
                    // Show alert window
                    SCLAlertView *incorrect = [[SCLAlertView alloc] init];
                    incorrect.backgroundType = Shadow;
                    [incorrect removeTopCircle];
                    
                    [incorrect addButton:@"Retry" actionBlock:^(void) {
                        
                        // Call this function again
                        [self analyzePreAuthenticationActionsWithError:error];
                        
                    }];
                    
                    [incorrect showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
                    
                }
                else if (computationResults.authenticationResult == authenticationResult_irrecoverableError)
                {
                    
                    // Show alert window
                    SCLAlertView *error = [[SCLAlertView alloc] init];
                    error.backgroundType = Shadow;
                    [error removeTopCircle];
                    
                    [error addButton:@"Retry" actionBlock:^(void) {
                        
                        // Go to back to login view which also re-runs core detection, hopefully fixing the error
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        LoginViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"];
                        [self.navigationController pushViewController:loginViewController animated:NO];
                        
                    }];
                    
                    [error showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
                    
                }
                
            }];
            
            [userInput showCustom:self image:nil color:[UIColor grayColor] title:@"User Login" subTitle:@"Enter user password" closeButtonTitle:nil duration:0.0f];
            
            // Nick's Addition: Moved Break
            break;
        }
            
        case preAuthenticationAction_PromptForUserPasswordAndWarn:
        {
            SCLAlertView *userInput = [[SCLAlertView alloc] init];
            userInput.backgroundType = Transparent;
            userInput.showAnimationType = SlideInFromBottom;
            [userInput removeTopCircle];
            
            UITextField *userText = [userInput addTextField:@"Demo password is: user"];
            
            
            [userInput addButton:@"Login" actionBlock:^(void) {
                
                Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:userText.text andError:error];
                
                // Set the authentication response code
                computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
                
                // Set history now, we already have all the info we need
                [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
                
                // Success and recoverable errors operate the same since we still managed to get a decrypted master key
                if(computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError ) {
                    
                    // Now we could pass the key to the GD runtime
                    NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
                    
                    // For demo purposes we just go to landing page
                    
                    // Show the landing page since we've been transparently authenticated
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                    
                    
                }
                else if(computationResults.authenticationResult == authenticationResult_incorrectLogin)
                {
                    
                    // Show alert window
                    SCLAlertView *incorrect = [[SCLAlertView alloc] init];
                    incorrect.backgroundType = Shadow;
                    [incorrect removeTopCircle];
                    
                    [incorrect addButton:@"Retry" actionBlock:^(void) {
                        
                        // Call this function again
                        [self analyzePreAuthenticationActionsWithError:error];
                        
                    }];
                    
                    [incorrect showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
                    
                }
                else if (computationResults.authenticationResult == authenticationResult_irrecoverableError)
                {
                    
                    // Show alert window
                    SCLAlertView *error = [[SCLAlertView alloc] init];
                    error.backgroundType = Shadow;
                    [error removeTopCircle];
                    
                    [error addButton:@"Retry" actionBlock:^(void) {
                        
                        // Go to back to login view which also re-runs core detection, hopefully fixing the error
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        LoginViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"];
                        [self.navigationController pushViewController:loginViewController animated:NO];
                        
                    }];
                    
                    [error showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
                    
                }
                
            }];
            
            // Show the warning
            [userInput showCustom:self image:nil color:[UIColor grayColor] title:@"Warning" subTitle:@"This device is high risk or in violation of policy, this access attempt will be reported." closeButtonTitle:nil duration:0.0f];
            
            // Nick's Addition: Moved Break
            break;
        }
            
        default:
            break;
            
    } // Done switch preauthentication action
    
    
}


// Layout subviews
- (void)viewDidLayoutSubviews {
    // Call SuperClass
    [super viewDidLayoutSubviews];
    
}

#pragma mark - ISHPermissionKit

// Set the datasource method
- (ISHPermissionRequestViewController *)permissionsViewController:(ISHPermissionsViewController *)vc requestViewControllerForCategory:(ISHPermissionCategory)category {
    
    // Check which category
    if (category == ISHPermissionCategoryLocationWhenInUse) {
        // Get the storyboard
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        // Create the location permission view controller
        LocationPermissionViewController *locationPermission = [mainStoryboard instantiateViewControllerWithIdentifier:@"LocationPermissionViewController"];
        
        // Return Location Permission View Controller
        return locationPermission;
    } else if (category == ISHPermissionCategoryActivity) {
        // Get the storyboard
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        // Create the activity permission view controller
        ActivityPermissionViewController *activityPermission = [mainStoryboard instantiateViewControllerWithIdentifier:@"ActivityPermissionViewController"];
        
        // Return Activity Permission View Controller
        return activityPermission;
    }
    
    // Don't know
    return nil;
}

#pragma mark - Status Bar Appearance

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end