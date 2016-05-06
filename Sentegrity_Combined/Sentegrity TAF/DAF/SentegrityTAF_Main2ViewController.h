//
//  SentegrityTAF_Main2ViewController.h
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


// General GD runtime
#import <GD/GDiOS.h>

#import "ILContainerView.h"

typedef enum {
    CurrentStateTypeWelcome = 0,
    CurrentStateTypePasswordCreation,
    CurrentStateTypeUnlock,
    CurrentStateTypeAuthWarning,
    CurrentStateDashboard
} CurrentStateType;



@interface SentegrityTAF_Main2ViewController : UIViewController


// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;

@property (nonatomic) CurrentStateType stateType;

// View Controllers

@property (strong, nonatomic) DashboardViewController *dashboardViewController;
@property (strong, nonatomic) SentegrityTAF_UnlockViewController *unlockViewController;
@property (strong, nonatomic) SentegrityTAF_PasswordCreationViewController *passwordCreationViewController;
@property (strong, nonatomic) SentegrityTAF_AuthWarningViewController *easyActivationViewController;


@property (atomic) BOOL firstTime;

@property (atomic) BOOL easyActivation;
@property (atomic) BOOL getPasswordCancelled;

@property (weak, nonatomic) DAFWaitableResult *result;


@property (weak, nonatomic) IBOutlet ILContainerView *containerView;


//methods
- (void) showAuthWarningWithResult: (DAFWaitableResult *)result;
- (void) showWelcomePermissionAndPassWordCreationWithResult:(DAFWaitableResult *)result;
- (void) showUnlockWithResult: (DAFWaitableResult *)result;

@end
