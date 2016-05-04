//
//  ViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Main View Controller
#import "DashboardViewController.h"

// Login view Controller
#import "LoginViewController.h"

// App Delegate
#import "AppDelegate.h"

// Device Information Controller
#import "SystemInformationViewController.h"

// User Information Controller
#import "UserInformationViewController.h"

// TrustFactor Datasets
#import "Sentegrity_TrustFactor_Datasets.h"

// Startup File
#import "Sentegrity_Startup_Store.h"

// Sentegrity
#import "Sentegrity.h"

// Flat Colors
#import "Chameleon.h"

// Side Menu
#import "RESideMenu.h"

// Delayed block
#import "IIDelayedAction.h"

// Date tools
#import "DateTools.h"

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Custom Alert View
#import "SCLAlertView.h"


@interface DashboardViewController () <RESideMenuDelegate>

/* Properties */

// Computation Results
@property (nonatomic,strong) Sentegrity_TrustScore_Computation *computationResults;

/* Actions */

// Set up the customizations for the view
- (void)customizeView;

// Right Menu Button Press
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender;

// Device Information Press
- (void)deviceInformationPressed:(UITapGestureRecognizer *)sender;

// User Information Press
- (void)userInformationPressed:(UITapGestureRecognizer *)sender;

@end


@implementation DashboardViewController

static MBProgressHUD *HUD;

// View Loaded
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Customize the view
    [self customizeView];
}

// View did appear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set last computation
    self.computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    [self updateComputationResults:self];
    
    // Set the current state in the startup file
    [[Sentegrity_Startup_Store sharedStartupStore] setCurrentState:@"Dashboard"];
    
    // Set the side menu delegate
    [self.sideMenuViewController setDelegate:self];
    
    // Set the status bar color to white
    [self setNeedsStatusBarAppearanceUpdate];
    
    //BOOL doesContain = [self.view.subviews containsObject:pageShadowView];
    
}

// Set up the customizations for the view
- (void)customizeView {

    // Set the background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Set the background color Good
    // [self.view setBackgroundColor:[UIColor colorWithRed:213.0f/255.0f green:44.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
    
    // Set the TrustScore progress bar
    
    // Sentegrity Gold
    [self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
    
    // Red (Good For Enterprise) color
    //[self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:213.0f/255.0f green:44.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];

    //Gradient
    //[self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:self.trustScoreProgressBar.frame andColors:@[[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f], [UIColor flatOrangeColor]]]];
    
    [self.trustScoreProgressBar setProgressBarTrackColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    
    //[self.trustScoreProgressBar setProgressBarTrackColor:[UIColor whiteColor]];
    
    //[self.progressBar setProgressBarTrackColor:[UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:self.progressBar.frame andColors:@[[UIColor flatWhiteColorDark], [UIColor flatGrayColor]]]];
    [self.trustScoreProgressBar setBackgroundColor:[UIColor clearColor]];
    [self.trustScoreProgressBar setStartAngle:90.0f];
    [self.trustScoreProgressBar setHintHidden:YES];
    [self.trustScoreProgressBar setProgressBarWidth:18.0f];
    
    // Set the menu button
    //Default to hidden and allow other VCs to change it (e.g., unlock)
    //[self.menuButton setHidden:YES];
    
    //Only show menu button if the user actively entered the dashboard, this allows them to go back
    //If you keep this here when there is no "back" screen it will just flash and try to run core detection again
    if(self.userClicked==NO){

        [self.menuButton setHidden:YES];
    }
    else{
        [self.menuButton setHidden:NO];
        [self.menuButton setCurrentMode:JTHamburgerButtonModeHamburger];
        [self.menuButton setLineColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
        [self.menuButton setLineWidth:40.0f];
        [self.menuButton setLineHeight:4.0f];
        [self.menuButton setLineSpacing:7.0f];
        [self.menuButton setShowsTouchWhenHighlighted:YES];
        [self.menuButton addTarget:self action:@selector(rightMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuButton updateAppearance];
    }


    //Reset user clicked for next time
    self.userClicked=NO;
    
    // Set the trustscore holding label
    [self.trustScoreHoldingLabel setTextColor:[UIColor flatWhiteColorDark]];
    
    // Set the button image to aspect fill
    [self.reloadButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    // Round out the device status image view
    self.deviceStatusImageView.layer.cornerRadius = self.deviceStatusImageView.frame.size.height /2;
    self.deviceStatusImageView.layer.masksToBounds = YES;
    self.deviceStatusImageView.layer.borderWidth = 0;
    
    // Round out the user status image view
    self.userStatusImageView.layer.cornerRadius = self.userStatusImageView.frame.size.height /2;
    self.userStatusImageView.layer.masksToBounds = YES;
    self.userStatusImageView.layer.borderWidth = 0;
    
    // Set the device view target for touches
    UITapGestureRecognizer *deviceTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(deviceInformationPressed:)];
    [self.deviceView addGestureRecognizer:deviceTap];
    
    // Set the user view target for touches
    UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(userInformationPressed:)];
    [self.userView addGestureRecognizer:userTap];
    
    // Setup Back button
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
    [self.backButton setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];

    // Update the last update label
    [self updateLastUpdateLabel:self];
}

// Update the last update label
- (void)updateLastUpdateLabel:(id)sender {
    // Set the last run date
    NSDate *lastRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"kLastRun"];
    
    // Check if the last run date exists
    if (!lastRunDate) {
        // Never updated
        [UIView transitionWithView:self.lastUpdateLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            // Set the text to never
            [self.lastUpdateLabel setText:@"Never"];
        } completion:nil];
    } else {
        // Updated before
        [UIView transitionWithView:self.lastUpdateLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            // Set the last update to when the last check was run
            [self.lastUpdateLabel setText:[lastRunDate timeAgoSinceNow]];
        } completion:nil];
    }
}

// Perform Core Detection
- (void)updateComputationResults:(id)sender {
    
    /* Perform Core Detection */
    
    // Computation results here!
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kLastRun"];
    
    /* Set the label and progress bar */
    
    // Set color red of progress bar based on trust
    /*
    if (self.computationResults.deviceTrusted==NO){
        
        //Red (Good color)
        //[self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:213.0f/255.0f green:44.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
        
        // Sentegrity Gold
        //[self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
        
       // [self.sentegrityButton setImage:[UIImage imageNamed:@"Sentegrity_Logo"] forState:UIControlStateNormal];
       // [self.sentegrityButton setAlpha:1];

    }
    else{
        // Un-Dim logo
        //[self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
        
        // Sentegrity Gold
        //[self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];

       // [self.sentegrityButton setImage:[UIImage imageNamed:@"Sentegrity_Logo"] forState:UIControlStateNormal];
       // [self.sentegrityButton setAlpha:1];
    }
    */
    // Trust Score
    CGFloat trustScore = self.computationResults.deviceScore;
    
    // Set the trustscore
    [self.trustScoreLabel setText:[NSString stringWithFormat:@"%.0f", trustScore]];
    
    
    // Set the progress bar
    [self.trustScoreProgressBar setProgress:trustScore/100.0f animated:YES];
    
    // Set the device message
    [self.deviceStatusLabel setText:self.computationResults.systemGUIIconText];
    // Set the user message
    [self.userStatusLabel setText:self.computationResults.userGUIIconText];
    
    // Set the device image
    if (self.computationResults.systemGUIIconID == 0) {
        [self.deviceStatusImageView setImage:[UIImage imageNamed:@"shield_black"]];
        self.deviceStatusImageView.backgroundColor = [UIColor clearColor];
    }
    // Set the user image
    if (self.computationResults.userGUIIconID == 0) {
        [self.userStatusImageView setImage:[UIImage imageNamed:@"shield_black"]];
        self.userStatusImageView.backgroundColor = [UIColor clearColor];
    }
    
    // Remove animations from the reload button after a delay
    
    [IIDelayedAction delayedAction:^{
        // Remove all reload button animations
        [self.reloadButton.layer removeAllAnimations];
    } withDelay:1.0];
    
    // Update the last update label
    //[self updateLastUpdateLabel:self];
    

    

} // End of Core Detection Function

// Go back
- (IBAction)goBack:(id)sender {
    
    // Go back
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

// Layout subviews
- (void)viewDidLayoutSubviews {
    // Call SuperClass
    [super viewDidLayoutSubviews];
    
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

// Device Information View Pressed
- (void)deviceInformationPressed:(UITapGestureRecognizer *)sender {
    
    // Show device information
    
    // Get the storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Create the system info view controller
    SystemInformationViewController *deviceInfoController = [mainStoryboard instantiateViewControllerWithIdentifier:@"systeminformationviewcontroller"];
    
    // Set the computation results if it exists
    if (self.computationResults != nil) {
        // Push it
        [self.navigationController pushViewController:deviceInfoController animated:YES];
    }
    

    
}

// User Information View Pressed
- (void)userInformationPressed:(UITapGestureRecognizer *)sender {
    
    // Show user information
    
    // Get the storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Create the system debug view controller
    UserInformationViewController *userInfoController = [mainStoryboard instantiateViewControllerWithIdentifier:@"userinformationviewcontroller"];
    
    // Set the computation results if it exists
    if (self.computationResults != nil) {
        // Push it
        [self.navigationController pushViewController:userInfoController animated:YES];
    }
    

    
}

- (IBAction)reload:(id)sender {
    
    
    // Animate the reload button
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1.0f;
    [self.reloadButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    // Show popup
    SCLAlertView *untrusted = [[SCLAlertView alloc] init];
    untrusted.showAnimationType = SlideInFromRight;
    untrusted.backgroundType = Shadow;
    [untrusted removeTopCircle];
    
    [untrusted addButton:@"Yes" actionBlock:^(void) {
        
        // Show the landing page
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        // Create the login view controller
        LoginViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"];
        
        // Push the login view controller
        [self.navigationController pushViewController:loginViewController animated:NO];
    }];
    

    [untrusted showCustom:self image:nil color:[UIColor grayColor] title:@"Refresh" subTitle:@"Do you want to run detection again and update the score?" closeButtonTitle:@"Cancel" duration:0.0f];

}

#pragma mark - Status Bar Appearance

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
