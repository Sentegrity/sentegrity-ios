//
//  ViewController.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// UIKit
#import <UIKit/UIKit.h>

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Custom Alert View
#import "SCLAlertView.h"

// Sentegrity
#import "Sentegrity.h"

// Dashboard View Controller
#import "DashboardViewController.h"

// Landing Page View Controller
#import "LandingViewController.h"

@interface LoginViewController : UIViewController

/* Perform Core Detection */
- (void)performCoreDetection:(id)sender;

@end

