//
//  LocationPermissionViewController.m
//  Sentegrity
//
//  Created by Kramer on 9/30/15.
//  Copyright © 2015 Sentegrity. All rights reserved.
//

#import "LocationPermissionViewController.h"

@interface LocationPermissionViewController ()

@end

@implementation LocationPermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)accept:(id)sender {
    [self requestPermissionFromSender:sender];
}

- (IBAction)decline:(id)sender {
    [self changePermissionStateToDontAskFromSender:sender];
}
@end
