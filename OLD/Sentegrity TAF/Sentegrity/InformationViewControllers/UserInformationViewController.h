//
//  UserInformationViewController.h
//  Sentegrity
//
//  Created by Kramer on 8/12/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>

// Sentegrity
#import "Sentegrity.h"

// Circle Progress Bar
#import "CircleProgressBar.h"

// Menu Bar Button
#import "JTHamburgerButton.h"

@interface UserInformationViewController : UIViewController

// Computation Results
@property (nonatomic,strong) Sentegrity_TrustScore_Computation *computationResults;

/* Menu Buttons */

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

// Back Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *backButton;

/* Progress Bar */

// User Score Progress Bar
@property (strong, nonatomic) IBOutlet CircleProgressBar *userScoreProgressBar;

// User Score Label
@property (strong, nonatomic) IBOutlet UILabel *userScoreLabel;

// User Score Holding Label
@property (strong, nonatomic) IBOutlet UILabel *userScoreHoldingLabel;

/* Score Labels */

// User View
@property (strong, nonatomic) IBOutlet UIView *userView;

// User Image View
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

// User Status Image View
@property (strong, nonatomic) IBOutlet UIImageView *userStatusImageView;

// User Status Label
@property (strong, nonatomic) IBOutlet UILabel *userStatusLabel;

/* Text View */

// User Text View
@property (strong, nonatomic) IBOutlet UITextView *userTextView;

@end
