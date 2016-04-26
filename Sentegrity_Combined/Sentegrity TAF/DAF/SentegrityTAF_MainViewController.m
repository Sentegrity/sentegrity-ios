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
            // Authorization succeeded
            
            break;
            
        case AuthorizationFailed:
            // Authorization failed
            break;
            
        case IdleLocked:
            // Locked from idle timeout
            break;
            
        case ChangePasswordSucceeded:
            // Change password succeeded
            break;
            
        case ChangePasswordFailed:
            // Change password failed
            break;
            
        default:
            break;
    }
}


@end
