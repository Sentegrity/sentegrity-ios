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
    
    // If this is the first run
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]==NO)
    {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Prompt for user to allow motion and location activity gathering
        NSArray *permissions = @[@(ISHPermissionCategoryLocationWhenInUse), @(ISHPermissionCategoryActivity)];
        
        ISHPermissionsViewController *vc = [ISHPermissionsViewController  permissionsViewControllerWithCategories:permissions  dataSource:self];
        
        // Check the permission view controller
        if (vc) {
            [self presentViewController:vc
                               animated:YES
                             completion:^(void) {
                                 
       
                                     // this completion gets called way early, lame
                                     //[(AppDelegate *)[[UIApplication sharedApplication] delegate] runCoreDetectionActivities];
                                 
                             
                             }];
        }
        
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
        
        
        [super viewDidAppear:animated];

        

    

 
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
    [[CoreDetection sharedDetection] performCoreDetectionWithPolicy:policy withTimeout:5.0f withCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
        
        // Check if core detection completed successfully
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self analyzeResults:computationResults withPolicy:policy];
                [MBProgressHUD hideHUDForView:self.view animated:NO];

            });
            
            
            NSLog(@"\n\nErrors: %@", [*error localizedDescription]);
            
        } else {
            // Core Detection Failed
            NSLog(@"Failed to run Core Detection: %@", [*error localizedDescription] ); // Here's why
        }
        
    }]; // End of the Core Detection Block
    


} // End of Core Detection Function


// Set up the customizations for the view
- (void)analyzeResults:(Sentegrity_TrustScore_Computation *)computationResults withPolicy:(Sentegrity_Policy *)policy {
    
    
        
    if(computationResults.deviceTrusted==YES){

        // Show landing page
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // Create the main view controller
        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
        [self.navigationController pushViewController:landingViewController animated:NO];

        
    } else {
        
        // Create the protect mode object
        ProtectMode *currentProtectMode = [[ProtectMode alloc] initWithPolicy:policy andTrustFactorsToWhitelist:computationResults.protectModeWhitelist];
        
        //check protect mode action
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
                    
                    // If pw was correct
                    if ([currentProtectMode deactivateProtectModeUserWithPIN:userText.text andError:&error] == YES){
    
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        // Create the main view controller
                        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
                        [self.navigationController pushViewController:landingViewController animated:NO];
                    }
                    else{
                        
                        // Prompt them again
                        [self analyzeResults:computationResults withPolicy:policy];
                        
                    }
                    
                }];
                
                [userPIN addButton:@"View Dashboard" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                
                [userPIN showCustom:self image:nil color:[UIColor grayColor] title:@"User Anomaly" subTitle:@"User Password Required" closeButtonTitle:nil duration:0.0f];
                
                
            }
                break;
                
            case 3: { // POLICY PROTECT MODE
                
                // Active protect mode
                [currentProtectMode activateProtectModePolicy];
                
                // Setup login box
                SCLAlertView *policyPIN = [[SCLAlertView alloc] init];
                policyPIN.backgroundType = Transparent;
                [policyPIN removeTopCircle];

                
                UITextField *policyText = [policyPIN addTextField:@"Demo password is \"admin\""];
                
                // Show deactivation textbox
                [policyPIN addButton:@"Unlock" actionBlock:^(void) {
                    
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

                [policyPIN addButton:@"View Dashboard" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                [policyPIN showCustom:self image:nil color:[UIColor grayColor] title:@"High Risk Device" subTitle:@"Administrator Approval Required" closeButtonTitle:nil duration:0.0f];
            
                
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
