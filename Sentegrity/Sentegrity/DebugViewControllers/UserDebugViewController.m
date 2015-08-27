//
//  UserDebugViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 8/10/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "UserDebugViewController.h"

@interface UserDebugViewController () {
    // Is the view dismissing?
    BOOL isDismissing;
}

// Right Menu Button Press
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender;

@end

@implementation UserDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the menu button
    [self.menuButton setCurrentMode:JTHamburgerButtonModeCross];
    [self.menuButton setLineColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    [self.menuButton setLineWidth:40.0f];
    [self.menuButton setLineHeight:4.0f];
    [self.menuButton setLineSpacing:7.0f];
    [self.menuButton setShowsTouchWhenHighlighted:YES];
    [self.menuButton addTarget:self action:@selector(rightMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton updateAppearance];
    
    // Get last computation results
    self.computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    // Populate debug text
    [self setText];
    
}

#pragma mark - Actions

// Right Menu Button Pressed
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender {
    // Check which mode the menu button is in
    if (sender.currentMode == JTHamburgerButtonModeCross) {
        
        // Set is dismissing to yes
        isDismissing = YES;
        
        // Remove the view controller
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

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

- (void)setText {
    
    
    NSString *complete = @"";
    
    NSString *userTrustFactorsTriggered = @"\nTrustFactors Triggered\n++++++++++++++++++++++++++++++\n";
    for(Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in self.computationResults.userTrustFactorsTriggered){
        
        NSString *storedAssertions =@"";
        NSString *currentAssertions =@"";
        
        for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
            
            storedAssertions = [storedAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nLastTime: %@\n\n",stored.assertionHash,stored.hitCount,stored.lastTime];
        }
        
        for(Sentegrity_Stored_Assertion *current in trustFactorOutputObject.assertionObjects){
            
            currentAssertions = [currentAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nLastTime: %@\n\n",current.assertionHash,current.hitCount,current.lastTime];
        }
        userTrustFactorsTriggered = [userTrustFactorsTriggered stringByAppendingFormat:@"--Name: %@\n\nCurrent Assertion:\n%@Stored Assertions:\n%@",trustFactorOutputObject.trustFactor.name, currentAssertions,storedAssertions];
        
    }
    complete = [complete stringByAppendingString:userTrustFactorsTriggered];
    
    NSString *userTrustFactorsNotLearned = @"\nTrustFactors Not Leared\n++++++++++++++++++++++++++++++\n";
    for(Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in self.computationResults.userTrustFactorsNotLearned){
        
        NSString *storedAssertions =@"";
        NSString *currentAssertions =@"";
        
        for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
            
            storedAssertions = [storedAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nLastTime: %@\n\n",stored.assertionHash,stored.hitCount,stored.lastTime];
        }
        
        for(Sentegrity_Stored_Assertion *current in trustFactorOutputObject.assertionObjects){
            
            currentAssertions = [currentAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nLastTime: %@\n\n",current.assertionHash,current.hitCount,current.lastTime];
        }
        userTrustFactorsTriggered = [userTrustFactorsTriggered stringByAppendingFormat:@"--Name: %@\n\nCurrent Assertion:\n%@Stored Assertions:\n%@",trustFactorOutputObject.trustFactor.name, currentAssertions,storedAssertions];
    }
    complete = [complete stringByAppendingString:userTrustFactorsNotLearned];
    
    
    
    NSString *userTrustFactorsWithErrors = @"\nTrustFactors Errored\n++++++++++++++++++++++++++++++\n";
    for(Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in self.computationResults.userTrustFactorsWithErrors){
        
        userTrustFactorsWithErrors = [userTrustFactorsWithErrors stringByAppendingFormat:@"\nName: %@\nDNE: %u\n",trustFactorOutputObject.trustFactor.name,trustFactorOutputObject.statusCode];
        
    }
    
    complete = [complete stringByAppendingString:userTrustFactorsWithErrors];
    
    NSString *userTrustFactorsToWhitelist = @"\nTrustFactors To Whitelist\n++++++++++++++++++++++++++++++\n";
    for(Sentegrity_TrustFactor_Output_Object *trustFactorOutputObject in self.computationResults.protectModeUserWhitelist){
      
        NSString *storedAssertions =@"";
        NSString *currentAssertions =@"";
        
        for(Sentegrity_Stored_Assertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
            
            storedAssertions = [storedAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nLastTime: %@\n\n",stored.assertionHash,stored.hitCount,stored.lastTime];
        }
        
        for(Sentegrity_Stored_Assertion *current in trustFactorOutputObject.assertionObjects){
            
            currentAssertions = [currentAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nLastTime: %@\n\n",current.assertionHash,current.hitCount,current.lastTime];
        }
        userTrustFactorsTriggered = [userTrustFactorsTriggered stringByAppendingFormat:@"--Name: %@\n\nCurrent Assertion:\n%@Stored Assertions:\n%@",trustFactorOutputObject.trustFactor.name, currentAssertions,storedAssertions];
        
    }
    complete = [complete stringByAppendingString:userTrustFactorsToWhitelist];
    

    

    [self.userDebugOutput setEditable:NO];
    self.userDebugOutput.text = complete;
    

}

@end
