//
//  ViewController.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "ViewController.h"

// Flat Colors
#import "Chameleon.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set the background color
    [self.view setBackgroundColor:[UIColor flatWhiteColor]];
    
    // Cutting corners here
    self.view.layer.cornerRadius = 20.0;
    self.view.layer.masksToBounds = YES;
    
    // Set the progress bar
    [self.progressBar setProgressBarProgressColor:[UIColor flatYellowColorDark]];
    [self.progressBar setProgressBarTrackColor:[UIColor flatWhiteColorDark]];
    [self.progressBar setBackgroundColor:[UIColor clearColor]];
    [self.progressBar setStartAngle:90.0f];
    [self.progressBar setHintHidden:YES];
    [self.progressBar setProgressBarWidth:25.0f];
    [self.progressBar setProgress:0.62f animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
