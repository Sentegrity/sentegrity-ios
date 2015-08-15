//
//  ViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Main View Controller
#import "LoginViewController.h"

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Custom Alert View
#import "SCLAlertView.h"

#import "Sentegrity.h"

// Dashboard View Controller
#import "DashboardViewController.h"

// Landing Page View Controller
#import "LandingViewController.h"


@interface LoginViewController ()

/* Properties */

@property (nonatomic,strong) Sentegrity_TrustScore_Computation *computationResults;


@end


@implementation LoginViewController

static MBProgressHUD *HUD;

// View Loaded
- (void)viewDidLoad {
    
    // Show Animation

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    
}

// View did appear
- (void)viewDidAppear:(BOOL)animated {
    
    // Show Animation
    HUD =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    HUD.labelText = @"Authenticating";
    HUD.labelFont = [UIFont fontWithName:@"OpenSans-Bold" size:25.0f];
    
    HUD.detailsLabelText = @"Attempting Transparent Authentication";
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
    [[CoreDetection sharedDetection] performCoreDetectionWithPolicy:policy withTimeout:30 withCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
        
        // Check if core detection completed successfully
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self analyzeResults:computationResults withPolicy:policy];
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
        // Stop analyzing screen
        HUD.labelText = @"Downloading ...";
        
        [MBProgressHUD hideHUDForView:self.view animated:NO];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // Create the main view controller
        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
        [self.navigationController pushViewController:landingViewController animated:NO];

        
    }
    else{
        
        [[ProtectMode sharedProtectMode] setPolicy:policy];
        
        [[ProtectMode sharedProtectMode] setTrustFactorsToWhitelist:computationResults.protectModeWhitelist];
        
        //check protect mode action
        switch (computationResults.protectModeAction) {
            case 0:
                break;
            case 1:
                break;
            case 2: { //USER PROTECT MODE
                
                // Active protect mode
                [[ProtectMode sharedProtectMode] activateProtectModeUser];
                
                // Stop analyzing screen
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                
                // Setup login box
                SCLAlertView *userPIN = [[SCLAlertView alloc] init];
                userPIN.backgroundType = Transparent;
                [userPIN removeTopCircle];
                
                UITextField *userText = [userPIN addTextField:@"Enter User Password"];
                
                // Show deactivation textbox
                
                [userPIN addButton:@"Login" actionBlock:^(void) {
                    
                    // If pw was correct
                    if([[ProtectMode sharedProtectMode] deactivateProtectModeUserWithPIN:userText.text]==YES){
    
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
                //UIImage *bgImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg"]]
                UIImage *popup = [UIImage  imageNamed:@"Sentegrity_Logo"];
                
                [userPIN addButton:@"View Dashboard" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                
                
                [userPIN showCustom:self image:popup color:[UIColor grayColor] title:@"Authentication Failed" subTitle:@"User password required for access" closeButtonTitle:nil duration:0.0f];
                
                
            }
                break;
                
            case 3: { // POLICY PROTECT MODE
                
                // Active protect mode
                [[ProtectMode sharedProtectMode] activateProtectModePolicy];
                
                // Stop analyzing screen
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                
                // Setup login box
                SCLAlertView *policyPIN = [[SCLAlertView alloc] init];
                //policyPIN.customViewColor = [UIColor grayColor];
                policyPIN.backgroundType = Transparent;
                
                
                UITextField *policyText = [policyPIN addTextField:@"Enter Administrator PIN"];
                
                // Show deactivation textbox
                [policyPIN addButton:@"Override" actionBlock:^(void) {
                    
                    // If pw is correct
                    if([[ProtectMode sharedProtectMode] deactivateProtectModePolicyWithPIN:policyText.text]==YES){
                        
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
                
                [policyPIN addButton:@"View Dashboard" actionBlock:^(void) {
                    // Get the storyboard
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    // Create the main view controller
                    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                    [self.navigationController pushViewController:mainViewController animated:NO];
                }];
                

                
                [policyPIN showWarning:self title:@"High Risk Device" subTitle:@"Administrator authorization required for access" closeButtonTitle:nil duration:0.0f];
                
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


@end
