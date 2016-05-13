//
//  ViewController.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// UIKit
#import <UIKit/UIKit.h>

// Circle Progress Bar
#import "CircleProgressBar.h"

// Hamburger Button
#import <JTHamburgerButton.h>

#import "DAFSupport/DAFAppBase.h"
#import "DAFSupport/DAFAuthState.h"


@interface DashboardViewController : UIViewController


// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;


/* Main Progress Bar */

// Main Progress Bar - middle
@property (weak, nonatomic) IBOutlet CircleProgressBar *trustScoreProgressBar;

// TrustScore Label - middle of Main Progress Bar
@property (strong, nonatomic) IBOutlet UILabel *trustScoreLabel;

// TrustScore Holding Label - middle, underneath TrustScore Label
@property (strong, nonatomic) IBOutlet UILabel *trustScoreHoldingLabel;

/* Top Bar */

// Menu Button - Top Right
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

// Sentegrity Button - Top Left
@property (strong, nonatomic) IBOutlet UIButton *sentegrityButton;

// Back Button - Top Right
@property (strong, nonatomic) IBOutlet UIButton *backButton;

/* Score Labels */

// Device View
@property (strong, nonatomic) IBOutlet UIView *deviceView;

// Device Image View
@property (strong, nonatomic) IBOutlet UIImageView *deviceImageView;

// Device Status Image View
@property (strong, nonatomic) IBOutlet UIImageView *deviceStatusImageView;

// Device Status Label
@property (strong, nonatomic) IBOutlet UILabel *deviceStatusLabel;

// User View
@property (strong, nonatomic) IBOutlet UIView *userView;

// User Image View
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

// User Status Image View
@property (strong, nonatomic) IBOutlet UIImageView *userStatusImageView;

// User Status Label
@property (strong, nonatomic) IBOutlet UILabel *userStatusLabel;

/* Bottom Bar */

// Reload Button
@property (strong, nonatomic) IBOutlet UIButton *reloadButton;

// Last Update Label
@property (strong, nonatomic) IBOutlet UILabel *lastUpdateLabel;

// Last Update Holding Label
@property (strong, nonatomic) IBOutlet UILabel *lastUpdateHoldingLabel;

/** Actions **/

// Reload
//- (IBAction)reload:(id)sender;

// Go Back
- (IBAction)goBack:(id)sender;

// Update the last update label
- (void)updateLastUpdateLabel:(id)sender;

/* Perform Core Detection */
- (void)updateComputationResults:(id)sender;

@end

