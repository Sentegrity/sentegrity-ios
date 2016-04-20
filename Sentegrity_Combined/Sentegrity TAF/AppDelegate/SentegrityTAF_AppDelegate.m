//
//  SentegrityTAF_AppDelegate.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_AppDelegate.h"


@implementation SentegrityTAF_AppDelegate

#pragma mark - Good DAF

// Setup NIBS
- (void)setupNibs {
    
    // Get the nib for the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.mainViewController = [[SentegrityTAF_MainViewController alloc]
                                   initWithNibName:@"SentegrityTAF_MainViewController_iPhone"
                                   bundle:nil];
        self.firstTimeViewController = [[SentegrityTAF_FirstTimeViewController alloc]
                                        initWithNibName:@"SentegrityTAF_FirstTimeViewController_iPhone"
                                        bundle:nil];
        self.unlockViewController = [[SentegrityTAF_UnlockViewController alloc]
                                     initWithNibName:@"SentegrityTAF_UnlockViewController_iPhone"
                                     bundle:nil];
        self.easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc]
                                             initWithNibName:@"SentegrityTAF_AuthWarningViewController_iPhone"
                                             bundle:nil];
        
    } else {
        self.mainViewController = [[SentegrityTAF_MainViewController alloc]
                                   initWithNibName:@"SentegrityTAF_MainViewController_iPad"
                                   bundle:nil];
        self.firstTimeViewController = [[SentegrityTAF_FirstTimeViewController alloc]
                                        initWithNibName:@"SentegrityTAF_FirstTimeViewController_iPad"
                                        bundle:nil];
        self.unlockViewController = [[SentegrityTAF_UnlockViewController alloc]
                                     initWithNibName:@"SentegrityTAF_UnlockViewController_iPad"
                                     bundle:nil];
        self.easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc]
                                             initWithNibName:@"SentegrityTAF_AuthWarningViewController_iPad"
                                             bundle:nil];
    }
}

// Show UI for action
- (void)showUIForAction:(enum DAFUIAction)action withResult:(DAFWaitableResult *)result {
    switch (action)
    {
        case AppStartup:
            // Startup
            [self setupNibs];
            [self.gdWindow setRootViewController:self.mainViewController];
            [self.gdWindow makeKeyAndVisible];
            break;
            
        case GetAuthToken_FirstTime:
            // Activation UI
            [self.firstTimeViewController setResult:result];
            [self.mainViewController presentViewController:self.firstTimeViewController animated:NO completion:nil];
            break;
            
        case GetAuthToken:
            // Unlock UI
            [self.unlockViewController setResult:result];
            [self.mainViewController presentViewController:self.unlockViewController animated:NO completion:nil];
            break;
            
        case GetAuthToken_WithWarning:
            // Auth Token (with warning)
            [self.easyActivationViewController setResult:result];
            [self.mainViewController presentViewController:self.easyActivationViewController animated:NO completion:nil];
            break;
            
        case GetPassword_FirstTime:
        case GetPassword:
        case GetOldPassword:
        case GetNewPassword:
        default:
            // Pass on all password requests (and any actions added in future)
            // to DAFAppBase's default implementation.
            [super showUIForAction:action withResult:result];
            break;
    }
}

// Event notification
- (void)eventNotification:(enum DAFUINotification)event withMessage:(NSString *)msg {
    // Pass the message to super (important)
    [super eventNotification:event withMessage:msg];
    
    // Pass the message to all of the view controllers
    [self.mainViewController updateUIForNotification:event];
    [self.firstTimeViewController updateUIForNotification:event];
    [self.unlockViewController updateUIForNotification:event];
    [self.easyActivationViewController updateUIForNotification:event];
}

@end
