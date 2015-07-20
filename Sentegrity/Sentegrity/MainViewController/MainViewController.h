//
//  ViewController.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>

// Circle Progress Bar
#import "CircleProgressBar.h"

// Hamburger Button
#import <JTHamburgerButton.h>


@interface MainViewController : UIViewController 


/* Properties */

// Main Progress Bar
@property (weak, nonatomic) IBOutlet CircleProgressBar *trustScoreProgressBar;

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

// TrustScore Label
@property (strong, nonatomic) IBOutlet UILabel *trustScoreLabel;

// TrustScore Holding Label
@property (strong, nonatomic) IBOutlet UILabel *trustScoreHoldingLabel;

// Reload Button
@property (strong, nonatomic) IBOutlet UIButton *reloadButton;

// Last Update Label
@property (strong, nonatomic) IBOutlet UILabel *lastUpdateLabel;

// Last Update Holding Label
@property (strong, nonatomic) IBOutlet UILabel *lastUpdateHoldingLabel;

// Device Image View
@property (strong, nonatomic) IBOutlet UIImageView *deviceImageView;

// Device Status Image View
@property (strong, nonatomic) IBOutlet UIImageView *deviceStatusImageView;

// Device Status Label
@property (strong, nonatomic) IBOutlet UILabel *deviceStatusLabel;

// User Image View
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

// User Status Image View
@property (strong, nonatomic) IBOutlet UIImageView *userStatusImageView;

// User Status Label
@property (strong, nonatomic) IBOutlet UILabel *userStatusLabel;

/* Actions */

// Reload
- (IBAction)reload:(id)sender;



@end

