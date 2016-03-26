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
#import "LoginAction.h"

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
    
    // Run Core Detection
    [[CoreDetection sharedDetection] performCoreDetectionWithCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
        
        // Check if core detection completed successfully
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self analyzeActionsWithComputationResults:computationResults withError:error];
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
- (void)analyzeActionsWithComputationResults:(Sentegrity_TrustScore_Computation *)computationResults withError:(NSError **)error {

    NSString *messageTitle;
    NSString *messageDescription;
    

    
    // Check the violationActionCode to determine what we should do GUI or login wise
    
    switch (computationResults.violationActionCode) {
        case violationActionCode_TransparentlyAuthenticate:
        {
            // Set history now, we already have all the info we need
            [[Sentegrity_Startup_Store sharedStartupStore] setHistoryFileWithComputationResult:computationResults withError:error];
            
            // Master key should have already been decrypted during transparent auth
            // We don't use it for anything in the demo, but this would be presented to the parent app for authentication
            NSData *decryptedMasterKey = [[Sentegrity_Crypto sharedCrypto] decryptedMasterKeyData];
            
            // Show the landing page since we've been transparently authenticated
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            // Create the main view controller
            LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
            [self.navigationController pushViewController:landingViewController animated:NO];

        }
            break;
        case violationActionCode_BlockAndWarn:
        {

            messageTitle = @"Access Denied";
            messageDescription = @"This device is at high risk of data breach or in violation of policy";
            
                       // Set history now, we already have all the info we need
            // Set the run history using current computationResults object
            [[Sentegrity_Startup_Store sharedStartupStore] setHistoryFileWithComputationResult:computationResults withError:error];
            
            
            SCLAlertView *blocked = [[SCLAlertView alloc] init];
            blocked.backgroundType = Shadow;
            [blocked removeTopCircle];
            
            [blocked showCustom:self image:nil color:[UIColor grayColor] title:messageTitle subTitle:messageDescription closeButtonTitle:nil duration:0.0f];

            
        }
            break;
        case violationActionCode_PromptForUserPassword:
        {
            
            // authenticationResponseCode will hold nothing if this is the first time
            
            switch (computationResults.authenticationResponseCode) {
                case authenticationResponseCode_incorrectLogin:
                    messageTitle=@"Incorrect Login";
                    messageDescription = @"Please re-enter your password.";
                    break;
                case authenticationResponseCode_UnknownError:
                    messageTitle=@"Error";
                    messageDescription = @"Please re-enter your password. If this problem persists, reinstall the application.";
                    break;
                case authenticationResponseCode_WhitelistError:
                    messageTitle=@"Error";
                    messageDescription = @"Please re-enter your password. If this problem persists, reinstall the application.";
                    break;
                default:
                    messageTitle = @"User Login";
                    messageDescription = @"Please enter your password.";
                    break;
            }
            

            
            // Wait until after login to set history file so that we see the result or failure
            
            // For all other results, setup login box
            SCLAlertView *userInput = [[SCLAlertView alloc] init];
            userInput.backgroundType = Transparent;
            userInput.showAnimationType = SlideInFromBottom;
            [userInput removeTopCircle];
            
            UITextField *userText = [userInput addTextField:@"Password is: user"];

            
            [userInput addButton:@"Login" actionBlock:^(void) {
                
                computationResults.authenticationResponseCode = [LoginAction attemptLoginWithViolationActionCode:computationResults.violationActionCode withAuthenticationCode:computationResults.authenticationActionCode withUserInput:userText.text andError:error];
                
                // Set the run history using current computationResults object
                [[Sentegrity_Startup_Store sharedStartupStore] setHistoryFileWithComputationResult:computationResults withError:&error];
                
                switch (computationResults.authenticationResponseCode) {
                    case authenticationResponseCode_Success:{
                        
                        // If attemptLogin was successful the master key should be decrypted in memory by now
                        NSData *decryptedMasterKey = [[Sentegrity_Crypto sharedCrypto] decryptedMasterKeyData];
                        
                        // Go to landing page now that we have the master key
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        // Create the main view controller
                        LandingViewController *landingViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"landingviewcontroller"];
                        [self.navigationController pushViewController:landingViewController animated:NO];
                        
                    }
                        break;
                    case authenticationResponseCode_incorrectLogin:{
                        
                    }
                        break;
                    case authenticationResponseCode_UnknownError:{
                        
                    }
                        break;
                    case authenticationResponseCode_WhitelistError:{
                        
                    }
                        break;
                        
                    default:
                        break;
                }
            }];
            
            
            [userInput showCustom:self image:nil color:[UIColor grayColor] title:messageTitle subTitle:messageDescription closeButtonTitle:nil duration:0.0f];
            
        }
            break;
        case violationActionCode_PromptForUserPasswordAndWarn:
        {
            
            NSString *messageTitle = @"Warning";
            NSString *messageDescription = @"This device is at high risk of data breach or in violation of policy, this login will be reported.";
            
            
            // Set history now, we already have all the info we need
            // Set the run history using current computationResults object
            [[Sentegrity_Startup_Store sharedStartupStore] setHistoryFileWithComputationResult:computationResults withError:error];
            
            
            
        }
            break;
            
        default:
            break;
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