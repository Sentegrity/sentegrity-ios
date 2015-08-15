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
    
    [self performSelector:@selector(dismiss1) withObject:nil afterDelay:3.0f];
    

    
}
// Layout subviews
- (void)viewDidLayoutSubviews {
    // Call SuperClass
    [super viewDidLayoutSubviews];
    
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
