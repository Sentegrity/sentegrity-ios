//
//  UserInformationViewController.h
//  Sentegrity
//
//  Created by Kramer on 8/12/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>

// Menu Bar Button
#import "JTHamburgerButton.h"

@interface UserInformationViewController : UIViewController

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

// Back Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *backButton;

@end
