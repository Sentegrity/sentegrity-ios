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


@interface SentegrityTAF_MainViewController () <SentegrityTAF_basicProtocol>
{
    BOOL once;
}

@end

@implementation SentegrityTAF_MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.containerView setCurrentViewController:self];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.firstTime = [DAFAuthState getInstance].firstTime;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
   self.deauthorizing= [NSNumber numberWithInteger:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissSuccesfullyFinishedViewController:(UIViewController *)vc {
    
    //clear current state
    CurrentState lastCurrentState = _currentState;
    _currentState = CurrentStateUnknown;
    
    //after welcome screen, we need to show permission screen
    if (lastCurrentState == CurrentStateWelcome) {
        [self showAskingForPermissions];
    }
    
    //after permission screen, we need to show password creation screen
    else  if (lastCurrentState == CurrentStateAskingPermissions) {
        [self showPasswordCreationWithResult:self.result];
    }
    
    //after password creation screen, we need to show unlock
    else  if (lastCurrentState == CurrentStatePasswordCreation) {
        [self showUnlockWithResult:self.result];
    }
    
    else {
        // Don't show anything unless we've already created password and activated
        if(self.firstTime==NO && self.easyActivation==NO && self.getPasswordCancelled==NO){
            
            // If we have no results to display, run detection, otherwise we will keep the last ones
            if([[CoreDetection sharedDetection] getLastComputationResults] == nil)
            {
                //[self dismissViewControllerAnimated:NO completion:nil];
                
                // we run core detection again by sending to the unlock vc
                [self showUnlockWithResult:self.result];
            }
            else{
                [self showDashboard];
            }
        }
    }
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //if nothing is on the screen, try to show dashboard/unlock
    if (!once && self.currentState == CurrentStateUnknown)
        [self dismissSuccesfullyFinishedViewController:nil];
    
    once = YES;
}




// Update the UI for Notification
- (void)updateUIForNotification:(enum DAFUINotification)event {
    NSLog(@"SentegrityTAF_ViewController: updateUIForNotification: %d", event);
    
        //if any of below viewController is currenlty active, forward this event to update result
        [self.dashboardViewController updateUIForNotification:event];
        [self.unlockViewController updateUIForNotification:event];
        [self.passwordCreationViewController updateUIForNotification:event];
        [self.easyActivationViewController updateUIForNotification:event];
        
        
        
        
        switch (event)
        {
            case AuthorizationSucceeded:
                // Authorization succeeded
                
                //Reset
                
                // Don't allow getPasswordCancelled again until after we finish deauthorizing
                self.deauthorizing= [NSNumber numberWithInteger:0];
                self.getPasswordCancelled=NO;
                self.easyActivation=NO;
                
                // For some reason we only get this policy after activation
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
                
                self.deauthorizing= [NSNumber numberWithInteger:0];
                self.getPasswordCancelled=NO;
                self.easyActivation=NO;
                
                break;
                
            case IdleLocked:
                // Locked from idle timeout
                
                // Jason Added:
                // Need to show unlock screen here since its an idle lock
                // We don't have a valid result object but just want to show the unlock screen
                // this prevents someone unauthorized from viewing  dashboard
                
                //Deauthorize, this will restart the runtime process
                
                // If we are already deauthorizing and receive another GetPasswordCancelled, ignore it to avoid a loop
                // caused by GetPasswordCancelled constantly re-invoking deauthorization
                
                // Removed because it shouldnt be necessary to deauth here

                [[DAFAppBase getInstance] deauthorize:@"Deauthorizing after idleLock"];
                
                /*
                 {
                 DAFWaitableResult *result = nil;
                 [self showUnlockWithResult:result];
                 }
                 */
                
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
                
                // Temp removed for testing of unlock otherwise it may run core detection twice
                //[self showUnlockWithResult:self.result];
                
                // If we are already deauthorizing and receive another GetPasswordCancelled, ignore it to avoid a loop
                // caused by GetPasswordCancelled constantly re-invoking deauthorization
                
                // This may trigger the DAF to restart auth
                self.result=nil;
                /*
                if([self.deauthorizing intValue]==0){
                    
                    [[DAFAppBase getInstance] deauthorize:@"Deauthorizing after cancell event"];
                    
                    self.deauthorizing=[NSNumber numberWithInteger:1];
                }
                 */
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
                self.deauthorizing= [NSNumber numberWithInteger:0];

                break;
                
            default:
                
                break;
        }
    
}


#pragma mark - setters

- (void) setCurrentViewController:(UIViewController *)currentViewController {
    
    //show currentViewController on the screen
    [self.containerView setChildViewController:currentViewController];
    
    _currentViewController = currentViewController;

}


#pragma mark - public methods for show screen

- (void) showWelcomePermissionAndPassWordCreationWithResult:(DAFWaitableResult *)result {
    self.result = result;
    [self showWelcome];
}


- (void) showWelcome {
    SentegrityTAF_WelcomeViewController *welcome = [[SentegrityTAF_WelcomeViewController alloc] init];
    welcome.delegate = self;
    
    //set new screen and state
    self.currentState = CurrentStateWelcome;
    self.welcomeViewController = welcome;
    self.currentViewController = welcome;
}

- (void) showAskingForPermissions {
    SentegrityTAF_AskPermissionsViewController *askingPermission = [[SentegrityTAF_AskPermissionsViewController alloc] init];
    askingPermission.delegate = self;
    askingPermission.permissions = [self checkApplicationPermission];
    askingPermission.activityDispatcher = self.activityDispatcher;
    
    //set new screen and state
    self.currentState = CurrentStateAskingPermissions;
    self.askPermissionsViewController = askingPermission;
    self.currentViewController = askingPermission;
}

- (void) showPasswordCreationWithResult: (DAFWaitableResult *)result {
    
    SentegrityTAF_PasswordCreationViewController *passwordCreationViewController;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        // iPhone View Controllers
        passwordCreationViewController = [[SentegrityTAF_PasswordCreationViewController alloc] initWithNibName:@"SentegrityTAF_PasswordCreationViewController_iPhone" bundle:nil];
        
    } else {
        
        // iPad View Controllers
        passwordCreationViewController = [[SentegrityTAF_PasswordCreationViewController alloc] initWithNibName:@"SentegrityTAF_PasswordCreationViewController_iPad" bundle:nil];
    }
    
    passwordCreationViewController.delegate = self;
    [passwordCreationViewController setResult:result];
    
    //set new screen and state
    self.currentState = CurrentStatePasswordCreation;
    self.passwordCreationViewController = passwordCreationViewController;
    self.currentViewController = passwordCreationViewController;
}


- (void) showUnlockWithResult: (DAFWaitableResult *)result{
    
    // Don't show the unlock if we don't have a result as nothing will happen once user enters password
   // if(result==nil){
        //[[DAFAppBase getInstance] deauthorize:@"Result object empty when showing unlockViewController"];
   // }
   // else{
        
        SentegrityTAF_UnlockViewController *unlockViewController;
        
        // Get the nib for the device
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            // iPhone View Controllers
            unlockViewController = [[SentegrityTAF_UnlockViewController alloc] initWithNibName:@"SentegrityTAF_UnlockViewController_iPhone" bundle:nil];
            
        } else {
            
            // iPad View Controllers
            unlockViewController = [[SentegrityTAF_UnlockViewController alloc] initWithNibName:@"SentegrityTAF_UnlockViewController_iPad" bundle:nil];
        }
        
        unlockViewController.delegate = self;
        [unlockViewController setResult:result];
    
        //set new screen and state
        self.currentState = CurrentStateUnlock;
        self.unlockViewController = unlockViewController;
        self.currentViewController = unlockViewController;
        
    //}
 
}



- (void) showAuthWarningWithResult: (DAFWaitableResult *)result {

    SentegrityTAF_AuthWarningViewController *easyActivationViewController;

    // Get the nib for the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        // iPhone View Controllers
        easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc] initWithNibName:@"SentegrityTAF_AuthWarningViewController_iPhone" bundle:nil];
        
        
    } else {
        
        // iPad View Controllers
        easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc] initWithNibName:@"SentegrityTAF_AuthWarningViewController_iPad" bundle:nil];
    }
    

    easyActivationViewController.delegate = self;
    [easyActivationViewController setResult:result];
    
    //set new screen and state
    self.currentState = CurrentStateAuthWarning;
    self.currentViewController = easyActivationViewController;
    self.easyActivationViewController = easyActivationViewController;
}

- (void) showDashboard {
    
    
   
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DashboardViewController *dashboardViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
    
    //Allow dashboardViewController to reset deauthorizing if it's foreground is called when mainView is not
    dashboardViewController.deauthorizing = self.deauthorizing;
    
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
    
    
    //set new screen and state
    self.currentState = CurrentStateDashboard;
    self.currentViewController = navController;
    self.dashboardViewController = dashboardViewController;
}


#pragma mark - permissions

// Check if the application has permissions to run the different activities, set DNE status and return list of permission
- (NSArray *) checkApplicationPermission {
    ISHPermissionRequest *permissionLocationWhenInUse = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
    ISHPermissionRequest *permissionActivity = [ISHPermissionRequest requestForCategory:ISHPermissionCategoryLocationWhenInUse];
    
    // Get permissions
    NSMutableArray *permissions = [[NSMutableArray alloc] initWithCapacity:2];
    
    // Check if location permissions are authorized
    if ([permissionLocationWhenInUse permissionState] != ISHPermissionStateAuthorized) {
        
        // Location not allowed
        
        // Set location error
        [[Sentegrity_TrustFactor_Datasets sharedDatasets]  setLocationDNEStatus:DNEStatus_unauthorized];
        
        // Set placemark error
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setPlacemarkDNEStatus:DNEStatus_unauthorized];
        
        // Add the permission
        [permissions addObject:@(ISHPermissionCategoryLocationWhenInUse)];
        
    } 
    
    // Check if activity permissions are authorized
    if ([permissionActivity permissionState] != ISHPermissionStateAuthorized) {
        
        // Activity not allowed
        
        // The app isn't authorized to use motion activity support.
        [[Sentegrity_TrustFactor_Datasets sharedDatasets] setActivityDNEStatus:DNEStatus_unauthorized];
        
        // Add the permission
        [permissions addObject:@(ISHPermissionCategoryActivity)];
        
    }
    
    return permissions;
}




@end
