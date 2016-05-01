/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  DAFSkelUnlockViewController.m
//  Skeleton
//
//  Created by Ian Harvey on 17/03/2014.
//

#import "DAFSkelUnlockViewController.h"
#import "DAFSupport/DAFAppBase.h"
#import "DAFSupport/DAFAuthState.h"

@interface DAFSkelUnlockViewController ()

@end


@implementation DAFSkelUnlockViewController

@synthesize result;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIForNotification:(enum DAFUINotification)event
{
    if (event==ChangePasswordCancelled  && result != nil)
    {
        // Idle Lock (or other lock event) happened during change-passphrase sequence
        // Ensure this VC is dismissed if it's showing
        NSLog(@"DAFSkelUnlockViewController: cancelling change password");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"DAFSkelUnlockViewController"
                                                 code:101
                                             userInfo:@{NSLocalizedDescriptionKey:@"Change password cancelled"} ]];
            result = nil;
        }];
    }
    else if (event==GetPasswordCancelled  && result != nil) {
        
        NSLog(@"DAFSkelUnlockViewController: cancelling unlock");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"DAFSkelUnlockViewController"
                                                 code:102
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unlock cancelled"} ]];
            result = nil;
        }];
    }
    else if (event == AuthenticateWithWarnStarted)
    {
        NSLog(@"DAFSkelUnlockViewController: starting authenticateWithWarn");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"DAFSkelUnlockViewController"
                                                 code:103
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unlock cancelled"} ]];
            result = nil;
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"DAFSkelUnlockViewController: viewDidAppear");
    [super viewDidAppear:animated];
    
    // For demonstration purposes, retrieve startup data stored by FirstTimeViewController
    NSString *startupData = [DAFAuthState getInstance].vendorState;
    NSLog(@"DAFSkelUnlockViewController: startup data = <%@>", startupData);
}

- (IBAction)onContinuePressed:(id)sender
{
    NSLog(@"DAFSkelUnlockViewController: onContinuePressed");
    
    [self dismissViewControllerAnimated:NO completion: ^{
        NSLog(@"DAFSkelUnlockViewController: delivering auth token");
        NSData *authToken = [NSData dataWithBytes:"dummy" length:5];
        [result setResult:authToken];
        result = nil;
    }];
}

- (IBAction)onTempUnlockPressed:(id)sender
{
    NSLog(@"DAFSkelUnlockViewController: onTempUnlockPressed");
    
    [self dismissViewControllerAnimated:NO completion: ^{
        NSLog(@"DAFSkelUnlockViewController: requesting temporary unlock");
        [[DAFAppBase getInstance] requestRecovery:result];
        result = nil;
    }];
    
}

@end
