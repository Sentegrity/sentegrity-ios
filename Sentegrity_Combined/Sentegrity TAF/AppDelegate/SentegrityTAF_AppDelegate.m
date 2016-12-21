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


#pragma mark - Good DAF


- (void)setupNibs
{
    NSLog(@"DAFSkelAppDelegate: setupNibs");
    
    
    self.easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc] initWithNibName:@"SentegrityTAF_AuthWarningViewController" bundle:nil];
    self.mainViewController = [[SentegrityTAF_MainViewController alloc] init];
    self.authFirstTimeViewController = [[SentegrityTAF_BlankAuthViewController alloc] init];
    self.authViewController = [[SentegrityTAF_BlankAuthViewController alloc] init];
    self.activityDispatcher = [[Sentegrity_Activity_Dispatcher alloc] init];
    self.unlockHolderViewController = [[SentegrityTAF_UnlockHolderViewController alloc] init];

    /*
    NSArray *fontFamilies = [UIFont familyNames];
    
    for (int i = 0; i < [fontFamilies count]; i++)
    {
        NSString *fontFamily = [fontFamilies objectAtIndex:i];
        NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
        NSLog (@"%@: %@", fontFamily, fontNames);
    }
    */


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
            //FirstTimeViewController contains multiple viewControllers, so we want a fresh instance if (for some reason) GetPassword_FirstTime is called twice
            self.firstTimeViewController = [[SentegrityTAF_FirstTimeViewController alloc] init];
            self.firstTimeViewController.result = result;
            self.firstTimeViewController.applicationPermissions = [self checkApplicationPermission];
            self.firstTimeViewController.activityDispatcher = self.activityDispatcher;
            ret = self.firstTimeViewController;
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
                //we want a fresh instance of UnlockViewController because of Core Detection
                [self.unlockHolderViewController loadNewUnlockViewController];
                self.unlockHolderViewController.result = result;
                ret = self.unlockHolderViewController;
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
    NSLog(@";: we got an event notification, type=%d message='%@'", event, msg);
    
    [super eventNotification:event withMessage:msg];
    
    //IMPORTANT - Need to check is viewController visible (active) before calling updateUIForNotification:
    if ([self isViewControllerVisible:self.mainViewController])
        [self.mainViewController updateUIForNotification:event];
    
    if ([self isViewControllerVisible:self.easyActivationViewController])
        [self.easyActivationViewController updateUIForNotification:event];
    
    if ([self isViewControllerVisible:self.unlockHolderViewController])
        [self.unlockHolderViewController updateUIForNotification:event];
    
    if ([self isViewControllerVisible:self.firstTimeViewController])
        [self.firstTimeViewController updateUIForNotification:event];
    
    if (event == ChangePasswordFailed ) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:NULL];
        
        [alert addAction:okAction];
        
        [self.mainViewController presentViewController:alert animated:YES completion:NULL];
    }
}


- (BOOL) isViewControllerVisible: (UIViewController *) viewController {
    if (viewController.isViewLoaded && viewController.view.window) {
        // viewController is visible
        return YES;
    }
    return NO;
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
