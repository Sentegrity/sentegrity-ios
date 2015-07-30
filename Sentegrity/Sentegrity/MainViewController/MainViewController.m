//
//  ViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "MainViewController.h"

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

// Animation
#import "MBProgressHUD.h"

#import "SCLAlertView.h"


@interface MainViewController () <RESideMenuDelegate>

// Set up the customizations for the view
- (void)customizeView;

// Right Menu Button Press
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender;

/* Perform Core Detection */
- (void)performCoreDetection;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Customize the view
    [self customizeView];

    // Perform Core Detection
    [self performCoreDetection];
    

}



// Perform Core Detection
- (void)performCoreDetection {
    /* Perform Core Detection */
    
    // Show Animation
    MBProgressHUD *HUD =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"Analyzing Device";
    //HUD.detailsLabelText = @"Just relax";
    //HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    
    // Create an error
    NSError *error;
    
    // Get the policy
    NSURL *policyPath = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"policy"]];
    
    // Parse the policy
    Sentegrity_Policy *policy = [[CoreDetection sharedDetection] parsePolicy:policyPath withError:&error];
    
    // Run Core Detection
    // Doing something on the main thread
    @autoreleasepool {
        
        dispatch_queue_t myQueue = dispatch_queue_create("Core_Detection_Queue",NULL);
        
        dispatch_async(myQueue, ^{
            
            //[NSThread sleepForTimeInterval:1];
            
            [[CoreDetection sharedDetection] performCoreDetectionWithPolicy:policy withTimeout:30 withCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Stop animation
                    [MBProgressHUD hideHUDForView:self.view animated:NO];
                    
                    // Computation results here!
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kLastRun"];
                    
                    /* Set the label and progress bar */
                    
                    // Trust Score
                    CGFloat trustScore = computationResults.deviceScore;
                    
                    // Set the trustscore
                    [self.trustScoreLabel setText:[NSString stringWithFormat:@"%.0f", trustScore]];
                    
                    // Set the progress bar
                    [self.trustScoreProgressBar setProgress:trustScore/100.0f animated:YES];
                    
                    // Set the device message
                    [self.deviceStatusLabel setText:computationResults.systemGUIIconText];
                    // Set the user message
                    [self.userStatusLabel setText:computationResults.userGUIIconText];
                    
                    // Set the device image
                    if (computationResults.systemGUIIconID == 0) {
                        [self.deviceStatusImageView setImage:[UIImage imageNamed:@"shield_gold"]];
                        self.deviceStatusImageView.backgroundColor = [UIColor clearColor];
                    }
                    // Set the user image
                    if (computationResults.userGUIIconID == 0) {
                        [self.userStatusImageView setImage:[UIImage imageNamed:@"shield_gold"]];
                        self.userStatusImageView.backgroundColor = [UIColor clearColor];
                    }
                    
                    // Remove animations from the reload button after a delay
                    [IIDelayedAction delayedAction:^{
                        // Remove all reload button animations
                        [self.reloadButton.layer removeAllAnimations];
                    } withDelay:1.0];
                    
                    // Set the last run date
                    NSDate *lastRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"kLastRun"];
                    if (!lastRunDate) {
                        
                        [UIView transitionWithView:self.lastUpdateLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            // Set the text to never
                            [self.lastUpdateLabel setText:@"Never"];
                        } completion:nil];
                    } else {
                        
                        [UIView transitionWithView:self.lastUpdateLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            [self.lastUpdateLabel setText:[lastRunDate timeAgoSinceNow]];
                        } completion:nil];
                    }
                    
                });
                if (success) {
                    
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [self analyzeResults:computationResults withPolicy:policy withError:error];
                         
                     });
                    
                    NSLog(@"\n\n+++ Core Detection Classification Scores +++ \n\nBreach Indicator:%d, \nSystem Security:%d, \nSystem Policy:%d, \nUser Anomaly:%d, \nUser Policy:%d\n\n", computationResults.systemBreachScore, computationResults.systemSecurityScore, computationResults.systemPolicyScore, computationResults.userAnomalyScore,computationResults.userPolicyScore );
                    
                    NSLog(@"\n\n+++ Core Detection Composite Results +++ \n\nDevice:%d, \nSystem:%d, \nUser:%d\n\n", computationResults.deviceScore, computationResults.systemScore, computationResults.userScore );
                    
                    NSLog(@"\n\n+++ Core Detection Trust Determinations +++\n\nDevice:%d, \nSystem:%d, \nUser:%d\n\n", computationResults.deviceTrusted, computationResults.systemTrusted, computationResults.userTrusted);
                    
                    NSLog(@"\n\n+++ Dashboard Data +++\n\nDevice Score:%d, \nSystem Icon:%d,  \nSystem Icon Text:%@, \nUser Icon:%d, \nUser Icon Text:%@\n\n", computationResults.deviceScore, computationResults.systemGUIIconID, computationResults.systemGUIIconText, computationResults.userGUIIconID, computationResults.userGUIIconText);
                    
                    NSLog(@"\n\n+++ System Detailed View +++\n\nSystem Score:%d, \nSystem Icon:%d,  \nSystem Icon Text:%@, \nIssues:%@, \nSuggestions:%@, \nAnalysis:%@\n\n", computationResults.systemScore, computationResults.systemGUIIconID, computationResults.systemGUIIconText, computationResults.systemGUIIssues, computationResults.systemGUISuggestions, computationResults.systemGUIAnalysis);
                    
                    NSLog(@"\n\n+++ User Detailed View +++\n\nUser Score:%d, \nUser Icon:%d,  \nUser Icon Text:%@, \nIssues:%@, \nSuggestions:%@, \nAnalysis:%@\n\n", computationResults.userScore, computationResults.userGUIIconID, computationResults.userGUIIconText, computationResults.userGUIIssues, computationResults.userGUISuggestions, computationResults.userGUIAnalysis);
                    
                    NSLog(@"\n\n+++ Rule Information +++\n\nRules Not Learned:%@, \nRules Triggered:%@, \nRules To Whitelist:%@\n\n", computationResults.trustFactorsNotLearned, computationResults.trustFactorsTriggered , computationResults.protectModeWhitelist);
                    
                    
                    NSLog(@"\n\nErrors: %@", [*error localizedDescription]);

                }
                else {NSLog(@"Failed to run Core Detection: %@", [*error localizedDescription] );}
                
                
            }];
            
            
        });

    }
    
 

}


// Set up the customizations for the view
- (void)analyzeResults:(Sentegrity_TrustScore_Computation *)computationResults withPolicy:(Sentegrity_Policy *)policy withError:(NSError **)error {
    
    //check for errors
    if (!computationResults || computationResults == nil) {
        // Error out, no trustFactorOutputObject were able to be added
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        [errorDetails setValue:@"No computationResults to analyze" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"Sentegrity" code:SACannotPerformAnalysis userInfo:errorDetails];

    }
    
    // Set static vars
    
    [[ProtectMode sharedProtectMode] setPolicy:policy];
    
    [[ProtectMode sharedProtectMode] setTrustFactorsToWhitelist:computationResults.protectModeWhitelist];
    

    
    //check protect mode action
    switch (computationResults.protectModeAction) {
        case 0:
            //do nothing but provide score to app
            break;
            
        case 1: {
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            alert.customViewColor = [UIColor grayColor];
            // Show wipe warning
            [alert addButton:@"Wipe" actionBlock:^{
                // Active protect mode
                [[ProtectMode sharedProtectMode] activateProtectModeWipeWithError:error];
                
            }];
            // Show the alert
            [alert showWarning:self title:@"Wipe Data" subTitle:@"Continue with Protect Mode Wipe?" closeButtonTitle:@"Cancel" duration:0.0f]; // Warning

        }
            break;
            
        case 2: {
            
            // Active protect mode
            [[ProtectMode sharedProtectMode] activateProtectModeUserWithError:error];
            
            SCLAlertView *userPIN = [[SCLAlertView alloc] init];
            userPIN.customViewColor = [UIColor grayColor];
            
            UITextField *userText = [userPIN addTextField:@"User Password"];
            
            // Show deactivation textbox
            
            [userPIN addButton:@"Unlock" actionBlock:^(void) {
                
                
                [[ProtectMode sharedProtectMode] deactivateProtectModeUserWithPIN:userText.text withError:error];
               
            }];
            
            [userPIN showEdit:self title:@"Unlock" subTitle:@"User Authentication is Required" closeButtonTitle:@"Cancel" duration:0.0f];
            
        }
            break;
            
        case 3: {
            
            // Active protect mode
            [[ProtectMode sharedProtectMode] activateProtectModePolicyWithError:error];
            
            SCLAlertView *policyPIN = [[SCLAlertView alloc] init];
            policyPIN.customViewColor = [UIColor grayColor];
            UITextField *policyText = [policyPIN addTextField:@"Administrator Password"];
            
            // Show deactivation textbox
            
            [policyPIN addButton:@"Unlock" actionBlock:^(void) {

                
                [[ProtectMode sharedProtectMode] deactivateProtectModePolicyWithPIN:policyText.text withError:error];
                
            }];
            
            [policyPIN showEdit:self title:@"Unlock" subTitle:@"Policy Override is Required" closeButtonTitle:@"Cancel" duration:0.0f];
            
        }
            break;
            
        default:
            break;
            
    }

    
  
    

}
// Set up the customizations for the view
- (void)customizeView {
    // Set the background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Set the status bar color to white
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Set the TrustScore progress bar
    [self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
    //[self.progressBar setProgressBarProgressColor:[UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:self.progressBar.frame andColors:@[[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f], [UIColor flatOrangeColor]]]];
    [self.trustScoreProgressBar setProgressBarTrackColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    //[self.progressBar setProgressBarTrackColor:[UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:self.progressBar.frame andColors:@[[UIColor flatWhiteColorDark], [UIColor flatGrayColor]]]];
    [self.trustScoreProgressBar setBackgroundColor:[UIColor clearColor]];
    [self.trustScoreProgressBar setStartAngle:90.0f];
    [self.trustScoreProgressBar setHintHidden:YES];
    [self.trustScoreProgressBar setProgressBarWidth:21.0f];
    
    // Set the menu button
    [self.menuButton setCurrentMode:JTHamburgerButtonModeHamburger];
    [self.menuButton setLineColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    [self.menuButton setLineWidth:40.0f];
    [self.menuButton setLineHeight:4.0f];
    [self.menuButton setLineSpacing:7.0f];
    [self.menuButton setShowsTouchWhenHighlighted:YES];
    [self.menuButton addTarget:self action:@selector(rightMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Set the trustscore holding label
    [self.trustScoreHoldingLabel setTextColor:[UIColor flatWhiteColorDark]];
    
    // Set the side menu delegate
    [self.sideMenuViewController setDelegate:self];
    
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
    
    // Set the last run date
    NSDate *lastRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"kLastRun"];
    if (!lastRunDate) {
        
        [UIView transitionWithView:self.lastUpdateLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            // Set the text to never
            [self.lastUpdateLabel setText:@"Never"];
        } completion:nil];
    } else {
        
        [UIView transitionWithView:self.lastUpdateLabel duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.lastUpdateLabel setText:[lastRunDate timeAgoSinceNow]];
        } completion:nil];
    }
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
    
    // Set the frame - depending on the orientation
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        // Landscape
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    } else {
        // Portrait
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + [UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, self.view.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
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

- (IBAction)reload:(id)sender {
    // Animate the reload button
    //CABasicAnimation *rotationAnimation;
    //rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    //rotationAnimation.duration = 2.0;
    //rotationAnimation.cumulative = YES;
   // rotationAnimation.repeatCount = HUGE_VALF;
   // [self.reloadButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    // Perform Core Detection
    [self performCoreDetection];
}

@end
