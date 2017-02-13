//
//  SentegrityTAF_BlankAuthViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 31/07/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BlankAuthViewController.h"
#import "ILContainerView.h"

@interface SentegrityTAF_BlankAuthViewController ()

@end

@implementation SentegrityTAF_BlankAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    ILContainerView *containerView = [[ILContainerView alloc] initWithFrame:self.view.bounds];
    containerView.currentViewController = self;
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:containerView];
    
    UIStoryboard *launchScreen = [UIStoryboard storyboardWithName:@"LaunchScreen-Blackberry" bundle:nil];
    [containerView setChildViewController:[launchScreen instantiateInitialViewController]];
    
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self dismissViewControllerAnimated:NO completion: ^{
        
        //delivering dummy authToken
#warning dummy
        NSData *authToken = [NSData dataWithBytes:"dummy" length:5];
        [self.result setResult:authToken];
        self.result = nil;
    }];

}

- (void) skipScreen {

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIForNotification:(enum DAFUINotification)event {
    
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
