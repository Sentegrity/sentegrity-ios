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
    if (self.computationResults.userTrusted==NO){
        
        // Set to red (Good color)
        //[self.self.userScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:213.0f/255.0f green:44.0f/255.0f blue:38.0f/255.0f alpha:1.0f]];
        
        //Gold
        [self.userScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
        
    }
    else{
        
        //Grey
        //[self.self.userScoreProgressBar setProgressBarProgressColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
        
        //Gold
        [self.userScoreProgressBar setProgressBarProgressColor:[UIColor colorWithRed:249.0f/255.0f green:191.0f/255.0f blue:48.0f/255.0f alpha:1.0f]];
    }
    
    [self.userScoreProgressBar setProgressBarTrackColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    [self.userScoreProgressBar setBackgroundColor:[UIColor clearColor]];
    [self.userScoreProgressBar setStartAngle:90.0f];
    [self.userScoreProgressBar setHintHidden:YES];
    [self.userScoreProgressBar setProgressBarWidth:12.0f];
    
    // Set the trustscore holding label
    [self.userScoreHoldingLabel setTextColor:[UIColor flatWhiteColorDark]];
    
    // Set last computation
    self.computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    // Check if the computation results were parsed
    if (self.computationResults != nil) {
        
        // User Score
        CGFloat userScore = self.computationResults.userScore;
        
        // Set the User Score
        [self.userScoreLabel setText:[NSString stringWithFormat:@"%.0f", userScore]];
        
        // Set the progress bar
        [self.userScoreProgressBar setProgress:userScore/100.0f animated:YES];
        
        // Set the device message
        [self.userStatusLabel setText:self.computationResults.userGUIIconText];
        
        // Set the device image
        if (self.computationResults.userGUIIconID == 0) {
            
            // Set the image view to the shield if it passed
            [self.userStatusImageView setImage:[UIImage imageNamed:@"shield_black"]];
            
            // Set the background color to clear
            self.userStatusImageView.backgroundColor = [UIColor clearColor];
        }
        
        // Create a string that will hold all of our textview info
        NSMutableAttributedString *userAttributedString = [[NSMutableAttributedString alloc] init];
        
        // Create an attributed string dictionary for section info
        NSDictionary *sectionStringDict = @{NSFontAttributeName : [UIFont fontWithName:@"OpenSans-Bold" size:32.0f], NSForegroundColorAttributeName : [UIColor colorWithRed:205.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f]};
        
        // Create an attributed string dictionary for content
        NSDictionary *contentStringDict = @{NSFontAttributeName : [UIFont fontWithName:self.userStatusLabel.font.fontName size:16.0f], NSForegroundColorAttributeName : [UIColor blackColor]};
      
        // Check if there are any GUI authenticators in use
        if (self.computationResults.userDynamicTwoFactors.count > 0 && self.computationResults.userDynamicTwoFactors != nil) {
            
            // Set the issues section
            NSAttributedString *dynamicTwoFactorsSection = [[NSAttributedString alloc] initWithString:@"Dynamic Two Factor\n" attributes:sectionStringDict];
            
            // Append the section
            [userAttributedString appendAttributedString:dynamicTwoFactorsSection];
            
            // Run through all the user GUI authenticators
            for (NSString *string in self.computationResults.userDynamicTwoFactors) {
                
                // Create the checkmark image in the string
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.image = [UIImage imageNamed:@"CheckMark"];
                textAttachment.bounds = CGRectMake(10.0f, -7.0f, textAttachment.image.size.width, textAttachment.image.size.height);
                
                NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                // Append the string
                [userAttributedString appendAttributedString:attrStringWithImage];
                
                // Create the authenticator string
                NSAttributedString *authenticator = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n", string] attributes:contentStringDict];
                
                // Append the string
                [userAttributedString appendAttributedString:authenticator];
            }
            
            // Append a newline
            [userAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        

        
        // Check if there are any GUI issues
        if (self.computationResults.userIssues.count > 0 && self.computationResults.userIssues != nil) {
            
            // Set the issues section
            NSAttributedString *issueSection = [[NSAttributedString alloc] initWithString:@"Issues\n" attributes:sectionStringDict];
            
            // Append the section
            [userAttributedString appendAttributedString:issueSection];
            
            // Run through all the user GUI issues
            for (NSString *string in self.computationResults.userIssues) {
                
                // Create the X image in the string
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.image = [UIImage imageNamed:@"Close"];
                textAttachment.bounds = CGRectMake(10.0f, -7.0f, textAttachment.image.size.width, textAttachment.image.size.height);
                
                NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                // Append the string
                [userAttributedString appendAttributedString:attrStringWithImage];
                
                // Create the issue string
                NSAttributedString *issue = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n", string] attributes:contentStringDict];
                
                // Append the string
                [userAttributedString appendAttributedString:issue];
            }
            
            // Append a newline
            [userAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        

        
        // Check if there are any GUI suggestions
        if (self.computationResults.userSuggestions.count > 0 && self.computationResults.userSuggestions != nil) {
            
            // Set the suggestions section
            NSAttributedString *section = [[NSAttributedString alloc] initWithString:@"Suggestions\n" attributes:sectionStringDict];
            
            // Append the section
            [userAttributedString appendAttributedString:section];
            
            // Run through all the user GUI suggestions
            for (NSString *string in self.computationResults.userSuggestions) {
                
                // Create the checkmark image in the string
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.image = [UIImage imageNamed:@"CheckMark"];
                textAttachment.bounds = CGRectMake(10.0f, -7.0f, textAttachment.image.size.width, textAttachment.image.size.height);
                
                NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                // Append the string
                [userAttributedString appendAttributedString:attrStringWithImage];
                
                // Create the suggestion string
                NSAttributedString *issue = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n", string] attributes:contentStringDict];
                
                // Append the string
                [userAttributedString appendAttributedString:issue];
            }
            
            // Append a newline
            [userAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        

        
        // Check if there are any GUI analysis
        if (self.computationResults.userAnalysisResults.count > 0 && self.computationResults.userAnalysisResults != nil) {
            
            // Set the suggestions section
            NSAttributedString *section = [[NSAttributedString alloc] initWithString:@"Analysis\n" attributes:sectionStringDict];
            
            // Append the section
            [userAttributedString appendAttributedString:section];
            
            // Run through all the user GUI suggestions
            for (NSString *string in self.computationResults.userAnalysisResults) {
                
                // Check if the string contains the word failed
                if (![string containsString:@"complete"]) {
                    // Create the X image in the string
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    textAttachment.image = [UIImage imageNamed:@"Close"];
                    textAttachment.bounds = CGRectMake(10.0f, -7.0f, textAttachment.image.size.width, textAttachment.image.size.height);
                    
                    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    
                    // Append the string
                    [userAttributedString appendAttributedString:attrStringWithImage];
                } else {
                    // Create the checkmark image in the string
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                    textAttachment.image = [UIImage imageNamed:@"CheckMark"];
                    textAttachment.bounds = CGRectMake(10.0f, -7.0f, textAttachment.image.size.width, textAttachment.image.size.height);
                    
                    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    
                    // Append the string
                    [userAttributedString appendAttributedString:attrStringWithImage];
                }
                
                // Create the analysis string
                NSAttributedString *issue = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n", string] attributes:contentStringDict];
                
                // Append the string
                [userAttributedString appendAttributedString:issue];
            }
        }
        
        // Set the user Text View Text
        [self.userTextView setAttributedText:userAttributedString];
        
    }
    
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
