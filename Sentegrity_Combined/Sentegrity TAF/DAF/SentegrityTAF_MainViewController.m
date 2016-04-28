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

@interface SentegrityTAF_MainViewController ()

@end

@implementation SentegrityTAF_MainViewController

// View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)viewWillAppear:(BOOL)animated{
    
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
    [self presentViewController:navController animated:YES completion:^{
        
        // Completed presenting
        
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
