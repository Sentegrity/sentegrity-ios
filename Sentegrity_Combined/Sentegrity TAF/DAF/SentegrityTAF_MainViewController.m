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
#import "DAFSupport/DAFAuthState.h"

// Dashboard View Controller
#import "DashboardViewController.h"

#import <UIKit/UIKit.h>

// Sentegrity
#import "Sentegrity.h"

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Custom Alert View
#import "SCLAlertView.h"
#import "ILContainerView.h"

@interface SentegrityTAF_MainViewController ()

@property (weak, nonatomic) IBOutlet ILContainerView *containerView;



@end

@implementation SentegrityTAF_MainViewController

// View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.containerView setCurrentViewController:self];
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
     self.firstTime = [DAFAuthState getInstance].firstTime;
    if(self.firstTime==NO && self.easyActivation==NO && self.getPasswordCancelled==NO){
        
        // If we have no results to display, run detection, otherwise we will keep the last ones
        if([[CoreDetection sharedDetection] getLastComputationResults] == nil)
        {
            [self setupNibs];
            //[self dismissViewControllerAnimated:NO completion:nil];
            
            // we run core detection again by sending to the unlock vc
            [self.unlockViewController setResult:self.result];
            [self presentViewController:self.unlockViewController animated:NO completion:nil];
            
        }
        else{
            [self showDashboardViewController];
        }
    }
    
    //reset
    
    
}

- (void) showDashboardViewController {
    [self.containerView setChildViewController:nil];
    
    // Show the landing page since we've been transparently authenticated
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Create the main view controller
    self.dashboardViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
    
    //self.dashboardViewController.userClicked = YES;
    
    // Hide the dashboard view controller
    [self.dashboardViewController.menuButton setHidden:YES];
    
    // We want the user to be able to go back from here
    [self.dashboardViewController.backButton setHidden:YES];
    
    // Set the last-updated text and reload button hidden
    [self.dashboardViewController.reloadButton setHidden:YES];
    
    // Navigation Controller
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.dashboardViewController];
    [navController setNavigationBarHidden:YES];
    
    
    [self.containerView setChildViewController:navController];
    
    // Hide the dashboard view controller
    [self.dashboardViewController.menuButton setHidden:YES];
    
    // We want the user to be able to go back from here
    [self.dashboardViewController.backButton setHidden:YES];
    
    // Set the last-updated text and reload button hidden
    [self.dashboardViewController.reloadButton setHidden:YES];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Update the UI for Notification
- (void)updateUIForNotification:(enum DAFUINotification)event {
    NSLog(@"SentegrityTAF_ViewController: updateUIForNotification: %d", event);
    
    // Close dashboard if shown
    [self.dashboardViewController dismissViewControllerAnimated:NO completion:nil];
    
    switch (event)
    {
        case AuthorizationSucceeded:
            // Authorization succeeded
            
            //Reset
            self.getPasswordCancelled=NO;
            self.easyActivation=NO;
            
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
            
            // Present unlock
           // [self.unlockViewController dismissViewControllerAnimated:NO completion:nil];
           // [self.unlockViewController setResult:self.result];
           // [self presentViewController:self.unlockViewController animated:NO completion:nil];
            
            break;
            
        case ChangePasswordSucceeded:
            // Change password succeeded
            break;
            
        case ChangePasswordFailed:
            // Change password failed
            break;
            
        case GetPasswordCancelled:
            // Means that an app requested our services but we are/were already showing the password screen
            // We should re-run core detection to get new data when this is the case
            // Therefore, re-request the unlock screen
            
          //  if(self.result!=nil){
          //      self.result=nil;
           // }
            // Present unlock
            //if(self.result !=nil){
                [self.unlockViewController dismissViewControllerAnimated:NO completion:nil];
                [self.unlockViewController setResult:self.result];
                [self presentViewController:self.unlockViewController animated:NO completion:nil];
          //  }
            //[[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
            self.getPasswordCancelled=YES;

            break;
            
        case AuthenticateWithWarnStarted:
            /*
            [self dismissViewControllerAnimated:NO completion:nil];
            [self.unlockViewController dismissViewControllerAnimated:NO completion:nil];
            [self.unlockViewController setResult:self.result];
            [self presentViewController:self.unlockViewController animated:NO completion:nil];
             
             */
            
            self.easyActivation=YES;
            break;
        
        
            
        default:
            
            break;
    }
}


@end
