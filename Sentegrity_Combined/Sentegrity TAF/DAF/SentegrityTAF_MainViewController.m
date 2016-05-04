/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  SentegrityTAF_ViewController.m
//  Skeleton
//
//  Created by Ian Harvey on 14/03/2014.
//

#import "SentegrityTAF_MainViewController.h"
#import "DAFSupport/DAFAppBase.h"

// Dashboard View Controller
#import "DashboardViewController.h"

#import <UIKit/UIKit.h>

// Sentegrity
#import "Sentegrity.h"

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Custom Alert View
#import "SCLAlertView.h"

@interface SentegrityTAF_MainViewController ()

@end

@implementation SentegrityTAF_MainViewController

// View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    

}

// Setup NIBS
- (void)setupNibs {
    
    // Get the nib for the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        // iPhone View Controllers
        self.unlockViewController = [[SentegrityTAF_UnlockViewController alloc] initWithNibName:@"SentegrityTAF_UnlockViewController_iPhone" bundle:nil];
       
        
    } else {
        
        // iPad View Controllers

        self.unlockViewController = [[SentegrityTAF_UnlockViewController alloc] initWithNibName:@"SentegrityTAF_UnlockViewController_iPad" bundle:nil];

        
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    // Don't show anything unless we've already created password and activated
    if(self.firstTime==NO){
        
        // If we have no results to display, run detection, otherwise we will keep the last ones
        if([[CoreDetection sharedDetection] getLastComputationResults] == nil)
        {
            [self setupNibs];
            [self dismissViewControllerAnimated:NO completion:nil];
            
            [self.unlockViewController setResult:self.result];
            [self presentViewController:self.unlockViewController animated:NO completion:nil];
            
        }
        else{
        
        // Show the landing page since we've been transparently authenticated
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        // Create the main view controller
        DashboardViewController *dashboardViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
        
        // Hide the dashboard view controller
        [dashboardViewController.menuButton setHidden:YES];
        
        // Set the last-updated text and reload button hidden
        [dashboardViewController.reloadButton setHidden:YES];
        [dashboardViewController.lastUpdateLabel setHidden:YES];
        [dashboardViewController.lastUpdateHoldingLabel setHidden:YES];
        
        // Navigation Controller
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dashboardViewController];
        [navController setNavigationBarHidden:YES];
        
        // Present the view controller
        [self presentViewController:navController animated:NO completion:^{
            
            // Hide the dashboard view controller
            [dashboardViewController.menuButton setHidden:YES];
            
            // Set the last-updated text and reload button hidden
            [dashboardViewController.reloadButton setHidden:YES];
            [dashboardViewController.lastUpdateLabel setHidden:YES];
            [dashboardViewController.lastUpdateHoldingLabel setHidden:YES];
            
            // Un-Hide the back button
            [dashboardViewController.backButton setHidden:NO];
            
        }];
        
        }
        
    }
    
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Update the UI for Notification
- (void)updateUIForNotification:(enum DAFUINotification)event {
    NSLog(@"SentegrityTAF_ViewController: updateUIForNotification: %d", event);
    switch (event)
    {
        case AuthorizationSucceeded:
            // Authorization succeeded
            
            if(self.firstTime==YES){
                
                NSError *error;
                NSString *email = [[[GDiOS sharedInstance] getApplicationConfig] objectForKey:GDAppConfigKeyUserId];
                
                // Update the startup file with the email
                
                [[Sentegrity_Startup_Store sharedStartupStore] updateStartupFileWithEmail:email withError:&error];
                
                // Set firsttime to NO such that after password creation the user will see the trustscore screen
                self.firstTime=NO;
            }
            
            break;
            
        case AuthorizationFailed:
            // Authorization failed
            break;
            
        case IdleLocked:
            // Locked from idle timeout
            break;
            
        case ChangePasswordSucceeded:
            // Change password succeeded
            break;
            
        case ChangePasswordFailed:
            // Change password failed
            break;
            
        default:
            
            break;
    }
}


@end
