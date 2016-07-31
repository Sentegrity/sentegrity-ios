//
//  SentegrityTAF_AppDelegate.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_AppDelegate.h"

// Permissions
#import "SentegrityTAF_WelcomeViewController.h"


// Animated Progress Alerts
#import "MBProgressHUD.h"

// Sentegrity
#import "Sentegrity.h"



// Private
@interface SentegrityTAF_AppDelegate (private)



@end

@implementation SentegrityTAF_AppDelegate

#pragma mark - getters

- (SentegrityTAF_UnlockViewController *) unlockViewController {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return  [[SentegrityTAF_UnlockViewController alloc] initWithNibName:@"SentegrityTAF_UnlockViewController_iPhone" bundle:nil];
    }
    else {
        return [[SentegrityTAF_UnlockViewController alloc] initWithNibName:@"SentegrityTAF_UnlockViewController_iPad" bundle:nil];
        }
}

- (SentegrityTAF_FirstTimeViewController *) firstTimeViewController {
    return [[SentegrityTAF_FirstTimeViewController alloc] init];
}





#pragma mark - Good DAF


- (void)setupNibs
{
    NSLog(@"DAFSkelAppDelegate: setupNibs");
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc] initWithNibName:@"SentegrityTAF_AuthWarningViewController_iPhone" bundle:nil];

    }
    else {
        self.easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc] initWithNibName:@"SentegrityTAF_AuthWarningViewController_iPad" bundle:nil];

    }
    
    self.mainViewController = [[SentegrityTAF_MainViewController alloc] init];
    self.authFirstTimeViewController = [[SentegrityTAF_BlankAuthViewController alloc] init];
    self.authViewController = [[SentegrityTAF_BlankAuthViewController alloc] init];
    self.activityDispatcher = [[Sentegrity_Activity_Dispatcher alloc] init];

}





- (UIViewController *)getUIForAction:(enum DAFUIAction)action withResult:(DAFWaitableResult *)result
{
    NSLog(@"SentegrityTAF_AppDelegate: getUIForAction (%d)", action);
    UIViewController *ret = NULL;
    
    switch (action)
    {
        case AppStartup:
            [self setupNibs];
            ret = self.mainViewController;
            break;
            
        case GetAuthToken_FirstTime:
            [self.authFirstTimeViewController setResult:result];
            ret = self.authFirstTimeViewController;
            break;
            
        case GetAuthToken:
            [self.authViewController setResult:result];
            ret = self.authViewController;
            break;
            
        case GetAuthToken_WithWarning:
            self.easyActivationViewController.result = result;
            ret = self.easyActivationViewController;
            break;
            
        case GetPassword_FirstTime:
            
        {
            SentegrityTAF_FirstTimeViewController *firstTimeViewController = self.firstTimeViewController;
            firstTimeViewController.result = result;
            firstTimeViewController.applicationPermissions = [self checkApplicationPermission];
            firstTimeViewController.activityDispatcher = self.activityDispatcher;
            ret = firstTimeViewController;
        }
            
            break;
            
        case GetPassword:
            // Wipe out all previous datasets (in the event this is not the first run)
            [Sentegrity_TrustFactor_Datasets selfDestruct];

            //Check application's permissions to run the different activities and set DNE status
            [self checkApplicationPermission];

            // run all async activities
            [self.activityDispatcher runCoreDetectionActivities];

            {
                SentegrityTAF_UnlockViewController *unlockViewController = self.unlockViewController;
                unlockViewController.result = result;
                ret = unlockViewController;
            }
            break;
            
        case GetOldPassword:
        case GetNewPassword:
        default:
            // Pass on all password requests (and any actions added in future)
            // to DAFAppBase's default implementation.
            return [super getUIForAction:action withResult:result];
    }
    
    return ret;
}

- (void)eventNotification:(enum DAFUINotification)event withMessage:(NSString *)msg
{
    NSLog(@"SentegrityTAF_AppDelegate: we got an event notification, type=%d message='%@'", event, msg);
    
    [super eventNotification:event withMessage:msg];
    
    [self.mainViewController updateUIForNotification:event];
    [self.easyActivationViewController updateUIForNotification:event];
    
    if (event == ChangePasswordFailed ) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:NULL];
        
        [alert addAction:okAction];
        
        [self.mainViewController presentViewController:alert animated:YES completion:NULL];
    }
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
