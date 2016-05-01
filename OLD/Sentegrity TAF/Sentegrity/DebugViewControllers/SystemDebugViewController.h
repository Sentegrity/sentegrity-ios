//
//  SystemDebugViewController.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 8/10/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "Sentegrity.h"

#import <UIKit/UIKit.h>

// Menu Bar Button
#import "JTHamburgerButton.h"

@interface SystemDebugViewController : UIViewController

// Computation Results
@property (nonatomic,strong) Sentegrity_TrustScore_Computation *computationResults;

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

@property (strong, nonatomic) IBOutlet UITextView *systemDebugOutput;


@end
