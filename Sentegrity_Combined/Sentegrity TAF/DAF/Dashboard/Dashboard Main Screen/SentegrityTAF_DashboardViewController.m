//
//  SentegrityTAF_DashboardViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 22/11/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_DashboardViewController.h"
#import "Sentegrity_SubClassResult_Object.h"
#import "Sentegrity_TrustScore_Computation.h"
#import "SentegrityTAF_UserDeviceInformationViewController.h"

#import "NSDate+DateTools.h"
#import "CircularProgressView.h"
#import "Sentegrity_Constants.h"

// Side Menu
#import "RESideMenu.h"
#import "JTHamburgerButton.h"
#import "UIViewController+RESideMenu.h"



@interface SentegrityTAF_DashboardViewController () <RESideMenuDelegate>

// data objects
@property (nonatomic, strong) Sentegrity_TrustScore_Computation *computationResults;


// UI elements
@property (weak, nonatomic) IBOutlet UILabel *labelLastRun;
@property (weak, nonatomic) IBOutlet UILabel *labelPercent;
@property (weak, nonatomic) IBOutlet UILabel *labelDashboardText;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUserError;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewUserNormal;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDeviceError;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDeviceNormal;

@property (weak, nonatomic) IBOutlet UIView *viewHolderForScore;
@property (weak, nonatomic) IBOutlet CircularProgressView *circularProgressView;


//Hamburger menu
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;



- (IBAction)pressedUser:(id)sender;
- (IBAction)pressedDevice:(id)sender;




@end

@implementation SentegrityTAF_DashboardViewController


#pragma mark - view-lifecycle

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // observe application will enter foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    /*
     *  Navigation bar (header)
     */
    
    //remove blur
    self.navigationController.navigationBar.translucent = NO;
    
    //background color of bar (#444444)
    self.navigationController.navigationBar.barTintColor = kDefaultDashboardBarColor;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //color of buttons
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //title logo
    UIImageView *imageViewTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sentegrity_white"]];
    [self.navigationItem setTitleView:imageViewTitle];
    
    
    /**
     *  Circular Progress View setup
     */
    
    self.circularProgressView.circleWidth = 10.0;
    self.circularProgressView.circleColor = kCircularProgressEmptyColor;
    self.circularProgressView.circleProgressColor = kCircularProgressFillColor;
    self.circularProgressView.progress = 0;
    

    
    /**
     * Hamburger Menu
     */
    
    // Get policy to check for debug
    // Get the policy
    NSError *error;
    Sentegrity_Policy *policy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
    
    if (policy.debugEnabled.intValue==1) {
        self.sideMenuViewController.delegate = self;
        self.menuButton = [[JTHamburgerButton alloc] initWithFrame:CGRectMake(0, 0, 40, 33)];
        [self.menuButton setCurrentMode:JTHamburgerButtonModeHamburger];
        [self.menuButton setLineColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
        [self.menuButton setLineWidth:40.0f];
        [self.menuButton setLineHeight:4.0f];
        [self.menuButton setLineSpacing:7.0f];
        [self.menuButton setShowsTouchWhenHighlighted:YES];
        [self.menuButton addTarget:self action:@selector(leftMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuButton updateAppearance];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
        self.navigationItem.leftBarButtonItem = buttonItem;
    }
    
    
    //Prepare for animation
    self.viewHolderForScore.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    self.viewHolderForScore.alpha = 0;
    
    self.circularProgressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    self.circularProgressView.alpha = 0;
    
    
}




- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    [self updateLabelsAndButtonsFromObject];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateAndUpdateProgress];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    [self updateLabelsAndButtonsFromObject];
    [self animateAndUpdateProgress];
}



#pragma mark - private methods

- (void) updateLabelsAndButtonsFromObject {
    
    
    
    // Set the trustscore
    self.labelPercent.text = [NSString stringWithFormat:@"%d", self.computationResults.deviceScore];
    
    
    // Last Run
    NSDate *lastRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"kLastRun"];
    
    // Check if the last run date exists
    if (!lastRunDate) {
        // Never updated
        self.labelLastRun.text = @"Last Run\nNever";
    } else {
        // Set the last update to when the last check was run
        self.labelLastRun.text = [NSString stringWithFormat:@"Last Run\n%@", [lastRunDate timeAgoSinceNow]];
    }
    
    
    // Dashboard text
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:5.0];
    style.alignment                = NSTextAlignmentCenter;
    
    NSDictionary *attribs = @{
                NSParagraphStyleAttributeName: style,
                NSForegroundColorAttributeName: kDefaultDashboardBarColor,
                NSFontAttributeName: [UIFont fontWithName:@"Lato-Light" size:22.0]
                };
    
   
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.computationResults.dashboardText attributes:attribs];
    self.labelDashboardText.attributedText = attributedString;
    
    
    
    // user button icon
    if (self.computationResults.userTrusted) {
        self.imageViewUserError.hidden = YES;
        self.imageViewUserNormal.hidden = NO;
    }
    else {
        self.imageViewUserError.hidden = NO;
        self.imageViewUserNormal.hidden = YES;
    }
    
    
    // device button icon
    if (self.computationResults.systemTrusted) {
        self.imageViewDeviceError.hidden = YES;
        self.imageViewDeviceNormal.hidden = NO;
    }
    else {
        self.imageViewDeviceError.hidden = NO;
        self.imageViewDeviceNormal.hidden = YES;
    }
    
}

- (void) animateAndUpdateProgress {
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.viewHolderForScore.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        self.circularProgressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);

        self.viewHolderForScore.alpha = 1;
        self.circularProgressView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self.circularProgressView setProgress:self.computationResults.deviceScore withAnimationDuration:1.0];
}



#pragma mark - IBActions


- (IBAction)pressedUser:(id)sender {
    SentegrityTAF_UserDeviceInformationViewController *vc = [[SentegrityTAF_UserDeviceInformationViewController alloc] init];
    vc.informationType = InformationTypeUser;
    vc.arrayOfSubClassResults = [NSArray arrayWithArray: self.computationResults.userSubClassResultObjects];

    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)pressedDevice:(id)sender {
    SentegrityTAF_UserDeviceInformationViewController *vc = [[SentegrityTAF_UserDeviceInformationViewController alloc] init];
    vc.informationType = InformationTypeDevice;
    vc.arrayOfSubClassResults = [NSArray arrayWithArray: self.computationResults.systemSubClassResultObjects];
    
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - RESideMenu

// Side Menu finished showing menu
- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController {
    // Set the hamburger button back
    [self.menuButton setCurrentModeWithAnimation:JTHamburgerButtonModeHamburger];
}


// Right Menu Button Pressed
- (void)leftMenuButtonPressed:(JTHamburgerButton *)sender {
    // Check which mode the menu button is in
    if (sender.currentMode == JTHamburgerButtonModeHamburger) {
        // Set it to arrow
        [sender setCurrentModeWithAnimation:JTHamburgerButtonModeArrow];
        
        // Present the right menu
        [self presentLeftMenuViewController:self];
    } else {
        // Set it to hamburger
        [sender setCurrentModeWithAnimation:JTHamburgerButtonModeHamburger];
    }
}



@end
