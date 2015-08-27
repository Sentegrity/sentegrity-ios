//
//  ViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

// Main View Controller
#import "LandingViewController.h"

#import "DashboardViewController.h"

#import "SCLAlertView.h"

#import "Sentegrity.h"


@interface LandingViewController ()

@end


@implementation LandingViewController

@synthesize subview;
@synthesize tapRecognizer;

// View Loaded
- (void)viewDidLoad {
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:tapRecognizer];

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    
}

// View did appear
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(showButton) withObject:nil afterDelay:1.0f];
    

    
}
// Layout subviews
- (void)viewDidLayoutSubviews {
    // Call SuperClass
    [super viewDidLayoutSubviews];
    
 }

-(void) showButton
{
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:tapRecognizer];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    SCLAlertView *unlocked = [[SCLAlertView alloc] init];
    unlocked.backgroundType = Shadow;
    //unlocked.backgroundViewColor = [UIColor colorWithRed:213.0f/255.0f green:44.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    [unlocked removeTopCircle];
    
    
    [unlocked addButton:@"View Dashboard" actionBlock:^(void) {
        // Get the storyboard
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // Create the main view controller
        DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
        [self.navigationController pushViewController:mainViewController animated:NO];
    }];
   
    Sentegrity_TrustScore_Computation *computation = [[CoreDetection sharedDetection] getLastComputationResults];
    
    if(computation.deviceTrusted==YES){ // Transparently authentication
        
            [unlocked showCustom:self image:nil color:[UIColor grayColor] title:@"Success!" subTitle:@"You've been transparently authenticated. You and your device are TRUSTED." closeButtonTitle:nil duration:0.0f];
        
//try to open inbox (airwatch)
        
        // Opens the Receiver app if installed, otherwise displays an error
        UIApplication *ourApplication = [UIApplication sharedApplication];
        NSURL *ourURL = [NSURL URLWithString:@"awemailclient://"];
        if ([ourApplication canOpenURL:ourURL]) {
            [ourApplication openURL:ourURL];
        }
        else {
            //Display error
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Receiver Not Found" message:@"The Receiver App is not installed. It must be installed to send text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
    }else if((computation.userTrusted==NO) && (computation.systemTrusted==YES)){ // User anomaly
            [unlocked showCustom:self image:nil color:[UIColor grayColor] title:@"What happened?" subTitle:@"Transparent authentication FAILED due to user anomalies that require explicit authentication." closeButtonTitle:nil duration:0.0f];
    }else{ // Policy violation
        
            [unlocked showCustom:self image:nil color:[UIColor grayColor] title:@"What happened?" subTitle:@"A policy exception (administrator PIN) was required due to HIGH RISK device conditions." closeButtonTitle:nil duration:0.0f];
    }

    
}
-(void) dismiss1
{
    
    // Get the storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // Create the main view controller
    DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
    
    [self.navigationController pushViewController:mainViewController  animated:NO];

}

- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded){
        [self dismiss1];
    }
}


@end
