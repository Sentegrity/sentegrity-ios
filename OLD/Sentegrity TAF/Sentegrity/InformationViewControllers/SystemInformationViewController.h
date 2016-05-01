//
//  SystemInformationViewController.h
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

@interface SystemInformationViewController : UIViewController

// Computation Results
@property (nonatomic,strong) Sentegrity_TrustScore_Computation *computationResults;

/* Menu Buttons */

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

// Back Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *backButton;

/* Progress Bar */

// Device Score Progress Bar
@property (strong, nonatomic) IBOutlet CircleProgressBar *systemScoreProgressBar;

// Device Score Label
@property (strong, nonatomic) IBOutlet UILabel *systemScoreLabel;

// Device Score Holding Label
@property (strong, nonatomic) IBOutlet UILabel *systemScoreHoldingLabel;

/* Score Labels */

// System View
@property (strong, nonatomic) IBOutlet UIView *systemView;

// System Image View
@property (strong, nonatomic) IBOutlet UIImageView *systemImageView;

// System Status Image View
@property (strong, nonatomic) IBOutlet UIImageView *systemStatusImageView;

// System Status Label
@property (strong, nonatomic) IBOutlet UILabel *systemStatusLabel;

/* Text View */

// System Text View
@property (strong, nonatomic) IBOutlet UITextView *systemTextView;

@end
