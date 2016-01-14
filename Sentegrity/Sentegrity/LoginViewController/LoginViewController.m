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
    
    // Start the location activity
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startLocation];
    
    // Start the activity activity
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] activityDispatcher] startActivity];
    
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
        
    } else {
        
        // Device is not trusted
        
        // Create the protect mode object
        ProtectMode *currentProtectMode = [[ProtectMode alloc] initWithPolicy:policy andTrustFactorsToWhitelist:computationResults.protectModeWhitelist];
        
        // check protect mode action
        switch (computationResults.protectModeAction) {
            case 0:
                break;
            case 1:
                break;
            case 2: {
                //USER PROTECT MODE
                
                // Active protect mode
                [currentProtectMode activateProtectModeUser];
                
                // Setup login box
                SCLAlertView *userPIN = [[SCLAlertView alloc] init];
                userPIN.backgroundType = Transparent;
                userPIN.showAnimationType = SlideInFromBottom;
                [userPIN removeTopCircle];
                
                UITextField *userText = [userPIN addTextField:@"Demo password is \"user\""];
                
                // Show deactivation textbox
                
                [userPIN addButton:@"Login" actionBlock:^(void) {
                    
                    // Create an error
                    NSError *error = nil;
                    
                    // If the password was correct was correct
                    if ([currentProtectMode deactivateProtectModeUserWithPIN:userText.text andError:&error] && error == nil) {
                        
                        // Show the landing page
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        // Create the main view controller
                        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
                        [self.navigationController pushViewController:landingViewController animated:NO];
                    
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
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"userinformationviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                
                [userPIN showCustom:self image:nil color:[UIColor grayColor] title:@"Unauthorized" subTitle:@"Password Required" closeButtonTitle:nil duration:0.0f];
                
                
            }
                break;
                
            case 3: {
                // POLICY PROTECT MODE
                
                // Active protect mode
                [currentProtectMode activateProtectModePolicy];
                
                // Setup login box
                SCLAlertView *policyPIN = [[SCLAlertView alloc] init];
                policyPIN.backgroundType = Transparent;
                [policyPIN removeTopCircle];
                
                
                UITextField *policyText = [policyPIN addTextField:@"Demo password is \"user\""];
                
                // Show deactivation textbox
                [policyPIN addButton:@"Login" actionBlock:^(void) {
                    
                    // Create an error
                    NSError *error = nil;
                    
                    // If pw is correct
                    if ([currentProtectMode deactivateProtectModePolicyWithPIN:policyText.text andError:&error] == YES) {
                        
                        // Show demo landing page
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        // Create the main view controller
                        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
                        [self.navigationController pushViewController:landingViewController animated:NO];
                        
                    } else {
                        
                        // Prompt them again
                        [self analyzeResults:computationResults withPolicy:policy];
                        
                    }
                    
                }];
                
                [policyPIN addButton:@"View Issues" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"systeminformationviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                [policyPIN showCustom:self image:nil color:[UIColor grayColor] title:@"High Risk Device" subTitle:@"Access may result in data breach, this attempt has been recorded. \n\nEnter password to continue." closeButtonTitle:nil duration:0.0f];
                
                
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