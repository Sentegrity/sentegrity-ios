//
//  SentegrityTAF_AppDelegate.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>

// DAF Support
#import "DAFSupport/DAFAppBase.h"

// General GD runtime
#import <GD/GDiOS.h>


// DAF View Controllers
#import "SentegrityTAF_MainViewController.h"
#import "SentegrityTAF_UnlockViewController.h"
#import "SentegrityTAF_AuthWarningViewController.h"
#import "SentegrityTAF_PasswordCreationViewController.h"

// Activity Dispatcher
#import "Sentegrity_Activity_Dispatcher.h"

// Implement the DAFAppBase delegate and conform to GDiOSDelegate protocol

@interface SentegrityTAF_AppDelegate : DAFAppBase 

// Activity Dispatcher
@property (strong, atomic) Sentegrity_Activity_Dispatcher *activityDispatcher;

// View Controllers
@property (strong, nonatomic) DashboardViewController *dashboardViewController;

@property (strong, nonatomic) SentegrityTAF_MainViewController *mainViewController;
@property (strong, nonatomic) SentegrityTAF_UnlockViewController *unlockViewController;
@property (strong, nonatomic) SentegrityTAF_AuthWarningViewController *easyActivationViewController;
@property (strong, nonatomic) SentegrityTAF_PasswordCreationViewController *passwordCreationViewController;

@end

