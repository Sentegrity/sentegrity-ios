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
    
    [self performSelector:@selector(showButton) withObject:nil afterDelay:1.5f];
    

    
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
        
            [unlocked showCustom:self image:nil color:[UIColor grayColor] title:@"Welcome!" subTitle:@"Access to this app required NO PASSWORD! View the Sentegrity dashboard for more details." closeButtonTitle:nil duration:0.0f];
        
    }else if((computation.userTrusted==NO) && (computation.systemTrusted==YES)){ // User anomaly
            [unlocked showCustom:self image:nil color:[UIColor grayColor] title:@"Password Required" subTitle:@"Access to this app required a password. View the Sentegrity dashboard for more details." closeButtonTitle:nil duration:0.0f];
    }else{ // Policy violation
        
            [unlocked showCustom:self image:nil color:[UIColor grayColor] title:@"Policy Exception" subTitle:@"Access to this app required a policy exception. View the Sentegrity dashboard for more details." closeButtonTitle:nil duration:0.0f];
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
