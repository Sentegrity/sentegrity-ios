//
//  ViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Main View Controller
#import "MainViewController.h"

// Device Information Controller
#import "SystemInformationViewController.h"

// User Information Controller
#import "UserInformationViewController.h"

// Sentegrity
#import "Sentegrity.h"
#import "Sentegrity_TrustFactor_Output_Object.h"

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


@interface MainViewController () <RESideMenuDelegate>

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


@implementation MainViewController

static MBProgressHUD *HUD;

// View Loaded
- (void)viewDidLoad {
    
    // Show Animation

    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    @autoreleasepool {
        
        dispatch_queue_t myQueue = dispatch_queue_create("Core_Detection_Queue",NULL);
        
        dispatch_async(myQueue, ^{

            // Perform Core Detection
            [self performCoreDetection:self];
            
             });
    }
    
}

// View did appear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set the side menu delegate
    [self.sideMenuViewController setDelegate:self];
    
    // Customize the view
    [self customizeView];
}

// Set up the customizations for the view
- (void)customizeView {
    
    
    // Set the background color
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Set the status bar color to white
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Set the TrustScore progress bar
    [self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
    //[self.trustScoreProgressBar setProgressBarProgressColor:[UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:self.trustScoreProgressBar.frame andColors:@[[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f], [UIColor flatOrangeColor]]]];
    [self.trustScoreProgressBar setProgressBarTrackColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    //[self.progressBar setProgressBarTrackColor:[UIColor colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:self.progressBar.frame andColors:@[[UIColor flatWhiteColorDark], [UIColor flatGrayColor]]]];
    [self.trustScoreProgressBar setBackgroundColor:[UIColor clearColor]];
    [self.trustScoreProgressBar setStartAngle:90.0f];
    [self.trustScoreProgressBar setHintHidden:YES];
    [self.trustScoreProgressBar setProgressBarWidth:18.0f];
    
    // Set the menu button
    [self.menuButton setCurrentMode:JTHamburgerButtonModeHamburger];
    [self.menuButton setLineColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    [self.menuButton setLineWidth:40.0f];
    [self.menuButton setLineHeight:4.0f];
    [self.menuButton setLineSpacing:7.0f];
    [self.menuButton setShowsTouchWhenHighlighted:YES];
    [self.menuButton addTarget:self action:@selector(rightMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton updateAppearance];
    
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
- (void)performCoreDetection:(id)sender {
    
    /* Perform Core Detection */
    
    // Show Animation
    dispatch_async(dispatch_get_main_queue(), ^{
        // Show Animation
        HUD =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        HUD.labelText = @"Analyzing Device";
    });
    
    
    // Create an error
    NSError *error;
    
    // Get the policy
    NSURL *policyPath = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"policy"]];
    
    // Parse the policy
    Sentegrity_Policy *policy = [[CoreDetection sharedDetection] parsePolicy:policyPath withError:&error];
    
    // Run Core Detection
    [[CoreDetection sharedDetection] performCoreDetectionWithPolicy:policy withTimeout:30 withCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
        
        // Update the GUI on the main thread
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
            
            // Update the last update label
            [self updateLastUpdateLabel:self];
            
        }); // End main thread
        
        // Check if core detection completed successfully
        if (success) {
            // Completed Successfully
            dispatch_async(dispatch_get_main_queue(), ^{
                // Analyze the computation results
                [self analyzeResults:computationResults withPolicy:policy withError:error];
            }); // End main thread
            
            /* Computation Information */
            
            // Set the computation info property
            self.computationResults = computationResults;
            
            NSLog(@"\n\nErrors: %@", [*error localizedDescription]);
            
        } else {
            // Core Detection Failed
            NSLog(@"Failed to run Core Detection: %@", [*error localizedDescription] ); // Here's why
        }
        
        
    }]; // End of the Core Detection Block

} // End of Core Detection Function


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
            //alert.customViewColor = [UIColor grayColor];
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
            //userPIN.customViewColor = [UIColor grayColor];
            
            UITextField *userText = [userPIN addTextField:@"User Password"];
            UIFont * font = [UIFont fontWithName:@"Helvetica-Bold"
                                            size:[UIFont systemFontSize]];
            [userText setFont:font];
            
            [userPIN setTitleFontFamily:@"Helvetics-Bold" withSize:[UIFont systemFontSize]];
            
            // Show deactivation textbox
            
            [userPIN addButton:@"Unlock" actionBlock:^(void) {
                
                
                [[ProtectMode sharedProtectMode] deactivateProtectModeUserWithPIN:userText.text withError:error];
               
            }];
            //UIImage *bgImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg"]]
            UIImage *popup = [UIImage  imageNamed:@"Sentegrity_Logo"];

            //[userPIN showCustom:self title:@"Unlock" subTitle:@"User Authentication is Required" closeButtonTitle:@"Cancel" duration:0.0f];
            
            [userPIN showCustom:self image:popup color:[UIColor grayColor] title:@"User Password" subTitle:@"User Authentication is Required" closeButtonTitle:@"Cancel" duration:0.0f];
            
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

// Set the status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle {
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
    
    @autoreleasepool {
        
        dispatch_queue_t myQueue = dispatch_queue_create("Core_Detection_Queue",NULL);
        
        dispatch_async(myQueue, ^{
            
            // Perform Core Detection
            [self performCoreDetection:self];
            
        });
    }

}

@end
