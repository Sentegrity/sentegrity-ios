//
//  UserInformationViewController.m
//  Sentegrity
//
//  Created by Kramer on 8/12/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//


#import "UserInformationViewController.h"

// Side Menu
#import "RESideMenu.h"

// Flat Colors
#import "Chameleon.h"

@interface UserInformationViewController () <RESideMenuDelegate> {
    // Is the view dismissing?
    BOOL isDismissing;
}

// Right Menu Button Pressed
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender;

// Back Button Pressed
- (void)backButtonPressed:(JTHamburgerButton *)sender;

@end

@implementation UserInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set last computation
    self.computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    // Set the TrustScore progress bar
    // ORIG: [self.userScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:205.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f]];
    // Set color red of progress bar based on trust
    // Set color red of progress bar based on trust
    if (self.computationResults.systemTrusted==NO){
        
        // Set to red (Good color)
        [self.userScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:213.0f/255.0f green:44.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
        
        // Gold
        //[self.systemScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
        
        
    }
    else{
        
        // Set to red (Good color)
        [self.userScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:213.0f/255.0f green:44.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
        
        //Grey
        //[self.systemScoreProgressBar setProgressBarProgressColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
        
        // Gold
        //[self.systemScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
    }
    
    [self.userScoreProgressBar setProgressBarTrackColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    [self.userScoreProgressBar setBackgroundColor:[UIColor clearColor]];
    [self.userScoreProgressBar setStartAngle:90.0f];
    [self.userScoreProgressBar setHintHidden:YES];
    [self.userScoreProgressBar setProgressBarWidth:10.0f];
    
    // Set the trustscore holding label
    [self.userScoreHoldingLabel setTextColor:[UIColor flatWhiteColorDark]];
    
    // Set last computation
    self.computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    

    // Set the menu button
    
    // Hidden for pilot
    [self.menuButton setHidden:YES];
    
    /*
    [self.menuButton setCurrentMode:JTHamburgerButtonModeHamburger];
    [self.menuButton setLineColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    [self.menuButton setLineWidth:40.0f];
    [self.menuButton setLineHeight:4.0f];
    [self.menuButton setLineSpacing:7.0f];
    [self.menuButton setShowsTouchWhenHighlighted:YES];
    [self.menuButton addTarget:self action:@selector(rightMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton updateAppearance];
     */
    
    // Set the back button
    [self.backButton setCurrentMode:JTHamburgerButtonModeArrow];
    [self.backButton setLineColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    [self.backButton setLineWidth:40.0f];
    [self.backButton setLineHeight:4.0f];
    [self.backButton setLineSpacing:7.0f];
    [self.backButton setShowsTouchWhenHighlighted:YES];
    [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton updateAppearance];
    
    // Set the side menu delegate
    [self.sideMenuViewController setDelegate:self];
    
    // Round out the device status image view
    self.userStatusImageView.layer.cornerRadius = self.userStatusImageView.frame.size.height /2;
    self.userStatusImageView.layer.masksToBounds = YES;
    self.userStatusImageView.layer.borderWidth = 0;
    
    // Set the user Text View Font
    [self.userTextView setFont:[UIFont fontWithName:self.userStatusLabel.font.familyName size:16]];
}

#pragma mark - RESideMenu Delegate

// Side Menu finished showing menu
- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController {
    // Set the hamburger button back
    [self.menuButton setCurrentModeWithAnimation:JTHamburgerButtonModeHamburger];
}

#pragma mark - Actions

// Right Menu Button Pressed
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender {
    // Check which mode the menu button is in
    if (sender.currentMode == JTHamburgerButtonModeHamburger) {
        // Set it to arrow
        [sender setCurrentModeWithAnimation:JTHamburgerButtonModeArrow];
        
        // Present the right menu
        [self presentRightMenuViewController:self];
    } else {
        // Set it to hamburger
        [sender setCurrentModeWithAnimation:JTHamburgerButtonModeHamburger];
    }
}

// Back Button Pressed
- (void)backButtonPressed:(JTHamburgerButton *)sender {
    // Check which mode the menu button is in
    if (sender.currentMode == JTHamburgerButtonModeArrow) {
        
        // Set is dismissing to yes
        isDismissing = YES;
        
        // Push the view back
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

#pragma mark - Overrides

// Layout subviews
/*
- (void)viewDidLayoutSubviews {
    // Call SuperClass
    [super viewDidLayoutSubviews];
    
    // Don't show if dismissing
    if (isDismissing) {
        return;
    }
    
    // Cutting corners here
    //self.view.layer.cornerRadius = 7.0;
    //self.view.layer.masksToBounds = YES;
    self.view.layer.mask = nil;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(7.0, 7.0)].CGPath;
    self.view.layer.mask = maskLayer;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Use the screen rectangle, not the current size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Set the frame - depending on the orientation
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        // Landscape
        [self.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    } else {
        // Portrait
        [self.view setFrame:CGRectMake(0, 0 + [UIApplication sharedApplication].statusBarFrame.size.height, screenRect.size.width, screenRect.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
    }
}


// Set the status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
