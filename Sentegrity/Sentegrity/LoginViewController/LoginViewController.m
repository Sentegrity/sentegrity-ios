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

@interface LoginViewController () <ISHPermissionsViewControllerDataSource>

/* Properties */

@property (nonatomic,strong) Sentegrity_TrustScore_Computation *computationResults;


@end


@implementation LoginViewController

static MBProgressHUD *HUD;

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

// View Loaded
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
}


// View did appear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    
}

// Perform Core Detection
- (void)performCoreDetection:(id)sender {
    
    /* Perform Core Detection */
    
    // Create an error
    NSError *error;
    
    // Get the policy
    NSURL *policyPath = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"policy"]];
    
    // Parse the policy
    Sentegrity_Policy *policy = [[CoreDetection sharedDetection] parsePolicy:policyPath withError:&error];
    
    // Run Core Detection
    [[CoreDetection sharedDetection] performCoreDetectionWithPolicy:policy withCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
        
        // Check if core detection completed successfully
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self analyzeResults:computationResults withPolicy:policy];
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
- (void)analyzeResults:(Sentegrity_TrustScore_Computation *)computationResults withPolicy:(Sentegrity_Policy *)policy {
    
    // Check if the device is trusted
    if (computationResults.deviceTrusted) {
        
        // Device is trusted
        
        // Show the landing page
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        // Create the main view controller
        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
        [self.navigationController pushViewController:landingViewController animated:NO];
        
        // Set the current state in the startup file
        [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Landing View"];
        
    } else {
        
        // Device is not trusted
        
        // Create the protect mode object
        ProtectMode *currentProtectMode = [[ProtectMode alloc] initWithPolicy:policy andTrustFactorsToWhitelist:computationResults.protectModeWhitelist];
        
        // check protect mode action
        switch (computationResults.protectModeAction) {
            case 1: {
                //REQUIRE USER PASSWORD
                
                // Set the current state in the startup file
                [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Waiting for user password after anomaly"];
                
                // Setup login box
                SCLAlertView *userPIN = [[SCLAlertView alloc] init];
                userPIN.backgroundType = Transparent;
                userPIN.showAnimationType = SlideInFromBottom;
                [userPIN removeTopCircle];
                
                UITextField *userText = [userPIN addTextField:@"No password required for demo"];
                
                // Show deactivation textbox
                
                [userPIN addButton:@"Login" actionBlock:^(void) {
                    
                    // Create an error
                    NSError *error = nil;

                    // Try to deactivate
                    if ([currentProtectMode deactivateProtectModeAction:computationResults.protectModeAction withInput:userText.text andError:&error] && error == nil) {
                        
                        // Show the landing page
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        // Create the main view controller
                        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
                        [self.navigationController pushViewController:landingViewController animated:NO];
                        
                        // Set the current state in the startup file
                        [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Landing View"];
                    
                    } else {
                        
                        // Log the error (if any)
                        if (error) {
                            NSLog(@"Error Thrown: %@", error.debugDescription);
                        }
                        
                        // Prompt them again
                        [self analyzeResults:computationResults withPolicy:policy];
                        
                    }
                    
                }];
                
                [userPIN addButton:@"View Issues" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                
                [userPIN showCustom:self image:nil color:[UIColor grayColor] title:@"Login Required" subTitle:@"Enter password to continue." closeButtonTitle:nil duration:0.0f];
                
                
            }
                break;
                
            case 2: {
                // REQUIRE USER PASSWORD AND WARN ABOUT POLICY VIOLATION
                
                // Set the current state in the startup file
                [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Waiting for user password after policy violation"];
  
                
                // Setup login box
                SCLAlertView *policyPIN = [[SCLAlertView alloc] init];
                policyPIN.backgroundType = Transparent;
                [policyPIN removeTopCircle];
                
                
                UITextField *policyText = [policyPIN addTextField:@"No password required for demo"];
                
                // Show deactivation textbox
                [policyPIN addButton:@"Login" actionBlock:^(void) {
                    
                    // Create an error
                    NSError *error = nil;
                    
                    // Try to deactivate
                    if ([currentProtectMode deactivateProtectModeAction:computationResults.protectModeAction withInput:policyText.text andError:&error] && error == nil) {
                        
                        // Show demo landing page
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        // Create the main view controller
                        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
                        [self.navigationController pushViewController:landingViewController animated:NO];
                        
                        // Set the current state in the startup file
                        [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Landing View"];
                        
                    } else {
                        
                        // Prompt them again
                        [self analyzeResults:computationResults withPolicy:policy];
                        
                    }
                    
                }];
                
                [policyPIN addButton:@"View Issues" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                [policyPIN showCustom:self image:nil color:[UIColor grayColor] title:@"Policy Violation" subTitle:@"You are in violation of a policy. This attempt has been recorded. \n\nEnter password to continue." closeButtonTitle:nil duration:0.0f];
                
                
            }
                break;
            case 3: {
                // REQUIRE USER PASSWORD AND WARN ABOUT DATA BREACH
                
                // Set the current state in the startup file
                [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Waiting for user password after warning"];
                
                // Setup login box
                SCLAlertView *policyPIN = [[SCLAlertView alloc] init];
                policyPIN.backgroundType = Transparent;
                [policyPIN removeTopCircle];
                
                
                UITextField *policyText = [policyPIN addTextField:@"No password required for demo"];
                
                // Show deactivation textbox
                [policyPIN addButton:@"Login" actionBlock:^(void) {
                    
                    // Create an error
                    NSError *error = nil;
                    
                    if ([currentProtectMode deactivateProtectModeAction:computationResults.protectModeAction withInput:policyText.text andError:&error] && error == nil) {
                        
                        // Show demo landing page
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        // Create the main view controller
                        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
                        [self.navigationController pushViewController:landingViewController animated:NO];
                        
                        // Set the current state in the startup file
                        [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Landing View"];
                        
                    } else {
                        
                        // Prompt them again
                        [self analyzeResults:computationResults withPolicy:policy];
                        
                    }
                    
                }];
                
                [policyPIN addButton:@"View Issues" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                [policyPIN showCustom:self image:nil color:[UIColor grayColor] title:@"High Risk Device" subTitle:@"Access may result in data breach. This attempt has been recorded. \n\nEnter password to continue." closeButtonTitle:nil duration:0.0f];
                
                
            }
                break;
                
            case 4: {
                // PREVENT ACCESS
                
                // Set the current state in the startup file
                [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Waiting after locking out"];
                
                
                // Setup login box
                SCLAlertView *policyPIN = [[SCLAlertView alloc] init];
                policyPIN.backgroundType = Transparent;
                [policyPIN removeTopCircle];
                
                
                
                [policyPIN showCustom:self image:nil color:[UIColor grayColor] title:@"Application locked" subTitle:@"Access denied. \n" closeButtonTitle:nil duration:0.0f];
                
                // Create an error
                NSError *error = nil;
                [currentProtectMode deactivateProtectModeAction:computationResults.protectModeAction withInput:@"" andError:&error];
                
                
            }
                break;
            case 5: {
                // REQUIRE ADMIN PASSWORD
                
                // Set the current state in the startup file
                [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Waiting for user override password"];
 
                
                // Setup login box
                SCLAlertView *policyPIN = [[SCLAlertView alloc] init];
                policyPIN.backgroundType = Transparent;
                [policyPIN removeTopCircle];
                
                
                UITextField *policyText = [policyPIN addTextField:@"No password required for demo"];
                
                // Show deactivation textbox
                [policyPIN addButton:@"Unlock" actionBlock:^(void) {
                    
                    // Create an error
                    NSError *error = nil;
                    
                    if ([currentProtectMode deactivateProtectModeAction:computationResults.protectModeAction withInput:policyText.text andError:&error] && error == nil) {
                        
                        // Show demo landing page
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        // Create the main view controller
                        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
                        [self.navigationController pushViewController:landingViewController animated:NO];
                        
                        // Set the current state in the startup file
                        [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Landing View"];
                        
                    } else {
                        
                        // Prompt them again
                        [self analyzeResults:computationResults withPolicy:policy];
                        
                    }
                    
                }];
                
                [policyPIN addButton:@"View Issues" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                [policyPIN showCustom:self image:nil color:[UIColor grayColor] title:@"High Risk Device" subTitle:@"The conditions of this device require administrator approval to continue. \n\nEnter override PIN to continue." closeButtonTitle:nil duration:0.0f];
                
                
            }
                break;
                
        }
        
    }
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


@end