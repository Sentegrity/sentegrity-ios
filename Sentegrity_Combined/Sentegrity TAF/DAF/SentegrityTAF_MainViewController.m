/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  SentegrityTAF_ViewController.m
//  Skeleton
//
//  Created by Ian Harvey on 14/03/2014.
//

#import "SentegrityTAF_MainViewController.h"
#import "DAFSupport/DAFAppBase.h"

@interface SentegrityTAF_MainViewController ()

@end

@implementation SentegrityTAF_MainViewController

// View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Start with Lock and Change Password buttons disabled.
    // They are enabled when the app becomes Authorized
    [self.lockButton setHidden:YES];
    [self.changePasswordButton setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Update the UI for Notification
- (void)updateUIForNotification:(enum DAFUINotification)event {
    NSLog(@"SentegrityTAF_ViewController: updateUIForNotification: %d", event);
    switch (event)
    {
        case AuthorizationSucceeded:
            [self.lockButton setHidden:NO];
            [self.changePasswordButton setHidden:NO];
            break;
            
        case AuthorizationFailed:
        case IdleLocked:
            [self.lockButton setHidden:YES];
            [self.changePasswordButton setHidden:YES];
            break;
            
        case ChangePasswordSucceeded:
        case ChangePasswordFailed:
            [self.changePasswordButton setHidden:NO];
            break;
            
        default:
            break;
    }
}

- (IBAction)onLockPressed:(id)sender {
    NSLog(@"SentegrityTAF_ViewController: onLockPressed:");
    [[DAFAppBase getInstance] deauthorize:@"User requested lock"];
}

- (IBAction)onChangePasswordPressed:(id)sender {
    NSLog(@"SentegrityTAF_ViewController: onChangePasswordPressed:");
    if ( [[DAFAppBase getInstance] requestChangePassphrase] )
    {
        [self.changePasswordButton setHidden:NO];
        // We'll un-hide it on completion
    }
    else
    {
        NSLog(@"SentegrityTAF_ViewController: change password rejected");
    }
}

@end
