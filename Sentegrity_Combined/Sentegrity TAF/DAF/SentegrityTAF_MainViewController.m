//
//  SentegrityTAF_MainViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 06/05/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

//permissions
#import "ISHPermissionKit.h"

#import "SentegrityTAF_MainViewController.h"

// Side Menu
#import "RESideMenu.h"


@interface SentegrityTAF_MainViewController () <SentegrityTAF_basicProtocol>
{
    BOOL once;
}

@property (nonatomic) BOOL firstTime;

@property (weak, nonatomic) IBOutlet ILContainerView *containerView;
@property (strong, nonatomic) DashboardViewController *dashboardViewController;
@property (nonatomic, strong) UIViewController *currentViewController;


@end

@implementation SentegrityTAF_MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.containerView setCurrentViewController:self];
    
    self.firstTime = [DAFAuthState getInstance].firstTime;
    // Do any additional setup after loading the view from its nib.
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)updateUIForNotification:(enum DAFUINotification)event
{
    NSLog(@"SentegrityTAF_MainViewController: updateUIForNotification: %d", event);
    switch (event)
    {
        case AuthorizationSucceeded: {
            NSError *error;
            
            NSString *currentEmail = [[[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error] email];
            
            // For some reason we only get this policy after activation
            // but check everytime if does not get set for whatever reason
            if(self.firstTime==YES || !currentEmail)
            {
                
                NSString *email = [[[GDiOS sharedInstance] getApplicationConfig] objectForKey:(NSString *)GDAppConfigKeyUserId];
                
                // Update the startup file with the email
                
                [[Sentegrity_Startup_Store sharedStartupStore] updateStartupFileWithEmail:email withError:&error];
                
                // Set firsttime to NO such that after password creation the user will see the trustscore screen
                self.firstTime=NO;
            }
            
            //show dashboard
            [self showDashboard];
            
            break;
            
        }
        case AuthorizationFailed:
        case IdleLocked:
            //[self.lockButton setHidden:YES];
            //[self.changePasswordButton setHidden:YES];
            break;
            
        case ChangePasswordSucceeded:
        case ChangePasswordFailed:
           // [self.changePasswordButton setHidden:NO];
            break;
            
        default:
            break;
    }
}


- (void) setCurrentViewController:(UIViewController *)currentViewController {
    
    //show currentViewController on the screen
    [self.containerView setChildViewController:currentViewController];
    
    _currentViewController = currentViewController;

}


- (void) showDashboard {
    
   
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DashboardViewController *dashboardViewController = [[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:nil];
    
    //Allow dashboardViewController to reset deauthorizing if it's foreground is called when mainView is not
    //dashboardViewController.deauthorizing = self.deauthorizing;
    
    // Hide the dashboard view controller
    [dashboardViewController.menuButton setHidden:YES];
    
    // We want the user to be able to go back from here
    [dashboardViewController.backButton setHidden:YES];
    
    // Set the last-updated text and reload button hidden
    [dashboardViewController.reloadButton setHidden:YES];
    
    // Navigation Controller
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dashboardViewController];
    [navController setNavigationBarHidden:YES];
    
    // Hide the dashboard view controller
    [dashboardViewController.menuButton setHidden:YES];
    
    // We want the user to be able to go back from here
    [dashboardViewController.backButton setHidden:YES];
    
    // Set the last-updated text and reload button hidden
    [dashboardViewController.reloadButton setHidden:YES];
    
    
    // Get policy to check for debug
    // Get the policy
    NSError *error;
    Sentegrity_Policy *policy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
    
    if (policy.debugEnabled.intValue==1) {
        //added to support right menu for debugging
        RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navController leftMenuViewController:nil rightMenuViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"rightmenuviewcontroller"]];
        self.currentViewController = sideMenuViewController;
    }
    else {
        self.currentViewController = navController;
    }
    
    
    //set new screen and state
    self.dashboardViewController = dashboardViewController;
}


- (void) dismissSuccesfullyFinishedViewController:(UIViewController *) vc withInfo: (NSDictionary *) info {
    
}

@end
