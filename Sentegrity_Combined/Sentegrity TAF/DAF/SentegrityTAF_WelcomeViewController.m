//
//  SentegrityTAF_WelcomeViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 06/05/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_WelcomeViewController.h"

@interface SentegrityTAF_WelcomeViewController ()
- (IBAction)pressedContinue:(id)sender;

@end

@implementation SentegrityTAF_WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)pressedContinue:(id)sender {
    [self.delegate dismissSuccesfullyFinishedViewController:self];
}
@end
