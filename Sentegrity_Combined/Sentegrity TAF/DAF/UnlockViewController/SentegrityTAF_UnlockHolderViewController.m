//
//  SentegrityTAF_HolderForUnlockViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 21/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_UnlockHolderViewController.h"
#import "SentegrityTAF_UnlockViewController.h"
#import "ILContainerView.h"

@interface SentegrityTAF_UnlockHolderViewController ()

@property (nonatomic, strong) SentegrityTAF_UnlockViewController *unlockViewController;

@property (weak, nonatomic) IBOutlet ILContainerView *containerView;


@end

@implementation SentegrityTAF_UnlockHolderViewController
@synthesize result;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.containerView setCurrentViewController:self];
    [self.containerView setChildViewController:self.unlockViewController];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) loadNewUnlockViewController {
    self.unlockViewController = [[SentegrityTAF_UnlockViewController alloc] init];
    [self.containerView setChildViewController:self.unlockViewController];
}
- (void) setResult:(DAFWaitableResult *)resultT {
    [self.unlockViewController setResult:resultT];
}
- (DAFWaitableResult *) result {
    return self.unlockViewController.result;
}

- (void)updateUIForNotification:(enum DAFUINotification)event {
    [self.unlockViewController updateUIForNotification:event];
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
