/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  SentegrityTAF_ViewController.h
//  Skeleton
//
//  Created by Ian Harvey on 14/03/2014.
//

#import <UIKit/UIKit.h>
#import <DAFSupport/DAFEventTypes.h>

// DAF View Controllers
#import "SentegrityTAF_UnlockViewController.h"

// General GD runtime
#import <GD/GDiOS.h>

#import "ILContainerView.h"


@interface SentegrityTAF_MainViewController : UIViewController

// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;

// View Controllers

@property (strong, nonatomic) DashboardViewController *dashboardViewController;


@property (strong, nonatomic) SentegrityTAF_UnlockViewController *unlockViewController;

@property (atomic) BOOL firstTime;

@property (atomic) BOOL easyActivation;
@property (atomic) BOOL getPasswordCancelled;

@property (weak, nonatomic) DAFWaitableResult *result;

@property (weak, nonatomic) IBOutlet ILContainerView *containerView;


@end
