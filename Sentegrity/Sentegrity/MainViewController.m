//
//  ViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "MainViewController.h"

// Flat Colors
#import "Chameleon.h"

// Side Menu
#import "RESideMenu.h"

@interface MainViewController () <RESideMenuDelegate>

// Right Menu Button Press
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Trust Score
    CGFloat trustScore = 56.0f;
    // System Score
    CGFloat systemScore = 75.0f;
    // User Score
    CGFloat userScore = 37.0f;
    
    // Set the background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Cutting corners here
    self.view.layer.cornerRadius = 7.0;
    self.view.layer.masksToBounds = YES;
    
    // Set the status bar color to white
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Set the TrustScore progress bar
    [self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
    //[self.progressBar setProgressBarProgressColor:[UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:self.progressBar.frame andColors:@[[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f], [UIColor flatOrangeColor]]]];
    [self.trustScoreProgressBar setProgressBarTrackColor:[UIColor flatWhiteColor]];
    //[self.progressBar setProgressBarTrackColor:[UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:self.progressBar.frame andColors:@[[UIColor flatWhiteColorDark], [UIColor flatGrayColor]]]];
    [self.trustScoreProgressBar setBackgroundColor:[UIColor clearColor]];
    [self.trustScoreProgressBar setStartAngle:90.0f];
    [self.trustScoreProgressBar setHintHidden:YES];
    [self.trustScoreProgressBar setProgressBarWidth:18.0f];
    [self.trustScoreProgressBar setProgress:trustScore/100.0f animated:YES];
    
    // Set the menu button
    [self.menuButton setCurrentMode:JTHamburgerButtonModeHamburger];
    [self.menuButton setLineColor:[UIColor flatWhiteColor]];
    [self.menuButton setLineWidth:30.0f];
    [self.menuButton setLineHeight:3.0f];
    [self.menuButton setShowsTouchWhenHighlighted:YES];
    [self.menuButton addTarget:self action:@selector(rightMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set the info button
    [self.infoButton setTintColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
    
    // Set the trustscore
    [self.trustScoreLabel setText:[NSString stringWithFormat:@"%.0f", trustScore]];
    
    // Set the trustscore holding label
    [self.trustScoreHoldingLabel setTextColor:[UIColor flatGrayColor]];
    
    // Set the SystemScore progress bar
    [self.systemScoreProgressBar setProgressBarProgressColor:[UIColor flatGrayColor]];
    [self.systemScoreProgressBar setProgressBarTrackColor:[UIColor flatWhiteColor]];
    [self.systemScoreProgressBar setBackgroundColor:[UIColor clearColor]];
    [self.systemScoreProgressBar setStartAngle:90.0f];
    [self.systemScoreProgressBar setHintHidden:YES];
    [self.systemScoreProgressBar setProgressBarWidth:9.0f];
    [self.systemScoreProgressBar setProgress:systemScore/100.0f animated:YES];
    
    // Set the systemscore
    [self.systemScoreLabel setText:[NSString stringWithFormat:@"%.0f", systemScore]];
    
    // Set the systemscore holding label
    [self.systemScoreHoldingLabel setTextColor:[UIColor flatGrayColor]];
    
    // Set the UserScore progress bar
    [self.userScoreProgressBar setProgressBarProgressColor:[UIColor flatGrayColor]];
    [self.userScoreProgressBar setProgressBarTrackColor:[UIColor flatWhiteColor]];
    [self.userScoreProgressBar setBackgroundColor:[UIColor clearColor]];
    [self.userScoreProgressBar setStartAngle:90.0f];
    [self.userScoreProgressBar setHintHidden:YES];
    [self.userScoreProgressBar setProgressBarWidth:9.0f];
    [self.userScoreProgressBar setProgress:userScore/100.0f animated:YES];
    
    // Set the userscore
    [self.userScoreLabel setText:[NSString stringWithFormat:@"%.0f", userScore]];
    
    // Set the userscore holding label
    [self.userScoreHoldingLabel setTextColor:[UIColor flatGrayColor]];
    
    // Set the side menu delegate
    [self.sideMenuViewController setDelegate:self];
}

// Layout subviews
- (void)viewDidLayoutSubviews {
    // Set the frame - depending on the orientation
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        // Landscape
        [self.view setFrame:CGRectMake(self.view.frame.origin.x + 7, self.view.frame.origin.y + 21, self.view.frame.size.width - 14, self.view.frame.size.height - 33)];
    } else {
        // Portrait
        [self.view setFrame:CGRectMake(self.view.frame.origin.x + 7, self.view.frame.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width - 14, self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - 10)];
    }
}

// Set the status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

// More Information
- (IBAction)moreInfo:(id)sender {
    NSLog(@"Info Button Clicked");
    [self.reloadButton.layer removeAllAnimations];
}

- (IBAction)reload:(id)sender {
    NSLog(@"Reload Button Clicked");
    
    // Animate the reload button
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 2.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.reloadButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
