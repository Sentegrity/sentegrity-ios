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

// System Score Progress Bar

/* Actions */

// Reload
- (IBAction)reload:(id)sender;



@end

