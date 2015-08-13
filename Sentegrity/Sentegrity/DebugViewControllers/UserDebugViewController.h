//
//  UserDebugViewController.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 8/10/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Sentegrity
#import "Sentegrity.h"

#import <UIKit/UIKit.h>

// Menu Bar Button
#import "JTHamburgerButton.h"


@interface UserDebugViewController : UIViewController

// Computation Results
@property (nonatomic,strong) Sentegrity_TrustScore_Computation *computationResults;

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

// Main Progress Bar - middle
@property (strong, nonatomic) IBOutlet UITextView *userDebugOutput;


@end
