//
//  SentegrityTAF_BaseNavigationController.m
//  Sentegrity
//
//  Created by Ivo Leko on 25/01/2017.
//  Copyright © 2017 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseNavigationController.h"

@interface SentegrityTAF_BaseNavigationController ()

@end

@implementation SentegrityTAF_BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
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
