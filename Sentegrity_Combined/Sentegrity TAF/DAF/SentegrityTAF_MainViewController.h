//
//  SentegrityTAF_MainViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 06/05/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DAFSupport/DAFEventTypes.h>

// DAF View Controllers
#import "SentegrityTAF_UnlockViewController.h"
#import "SentegrityTAF_PasswordCreationViewController.h"
#import "SentegrityTAF_AuthWarningViewController.h"
#import "SentegrityTAF_WelcomeViewController.h"
#import "SentegrityTAF_AskPermissionsViewController.h"

// Activity Dispatcher
#import "Sentegrity_Activity_Dispatcher.h"

// General GD runtime
#import <GD/GDiOS.h>

#import "ILContainerView.h"

typedef enum {
    CurrentStateUnknown = 0,
    CurrentStateWelcome,
    CurrentStateAskingPermissions,
    CurrentStatePasswordCreation,
    CurrentStateUnlock,
    CurrentStateAuthWarning,
    CurrentStateDashboard
} CurrentState;



@interface SentegrityTAF_MainViewController : UIViewController


// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;

// Activity Dispatcher
@property (strong, atomic) Sentegrity_Activity_Dispatcher *activityDispatcher;

// this viewController will be automatically showed on the screen
@property (nonatomic, strong) UIViewController *currentViewController;

//all viewControllers are weak -> will be destroyed as soon as another viewController is presented
@property (weak, nonatomic) DashboardViewController *dashboardViewController;
@property (weak, nonatomic) SentegrityTAF_UnlockViewController *unlockViewController;
@property (weak, nonatomic) SentegrityTAF_PasswordCreationViewController *passwordCreationViewController;
@property (weak, nonatomic) SentegrityTAF_AuthWarningViewController *easyActivationViewController;
@property (weak, nonatomic) SentegrityTAF_AskPermissionsViewController *askPermissionsViewController;
@property (weak, nonatomic) SentegrityTAF_WelcomeViewController *welcomeViewController;

//current Sentegrity state
@property (nonatomic) CurrentState currentState;



@property (atomic) BOOL firstTime;

@property (atomic) BOOL easyActivation;
@property (atomic) BOOL getPasswordCancelled;

@property (weak, nonatomic) DAFWaitableResult *result;


@property (weak, nonatomic) IBOutlet ILContainerView *containerView;


//public methods
- (NSArray *) checkApplicationPermission;
- (void) showAuthWarningWithResult: (DAFWaitableResult *)result;
- (void) showWelcomePermissionAndPassWordCreationWithResult:(DAFWaitableResult *)result;
- (void) showUnlockWithResult: (DAFWaitableResult *)result;
- (void) showDashboard;

@end
