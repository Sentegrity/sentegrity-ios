/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  DAFSkelViewController.m
//  Skeleton
//
//  Created by Ian Harvey on 14/03/2014.
//

#import "DAFSkelMainViewController.h"
#import "DAFSupport/DAFAppBase.h"

@interface DAFSkelMainViewController ()

@end

@implementation DAFSkelMainViewController

- (void)viewDidLoad
{
    NSLog(@"DAFSkelViewController: viewDidLoad");
    [super viewDidLoad];
    
    // Start with Lock and Change Password buttons disabled.
    // They are enabled when the app becomes Authorized
    [self.lockButton setHidden:YES];
    [self.changePasswordButton setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIForNotification:(enum DAFUINotification)event
{
    NSLog(@"DAFSkelViewController: updateUIForNotification: %d", event);
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

- (IBAction)onLockPressed:(id)sender
{
    NSLog(@"DAFSkelViewController: onLockPressed:");
    [[DAFAppBase getInstance] deauthorize:@"User requested lock"];
}

- (IBAction)onChangePasswordPressed:(id)sender
{
    NSLog(@"DAFSkelViewController: onChangePasswordPressed:");
    if ( [[DAFAppBase getInstance] requestChangePassphrase] )
    {
        [self.changePasswordButton setHidden:NO];
        // We'll un-hide it on completion
    }
    else
    {
        NSLog(@"DAFSkelViewController: change password rejected");
    }
}

@end
