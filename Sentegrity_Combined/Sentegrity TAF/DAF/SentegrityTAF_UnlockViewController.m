/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  SentegrityTAF_UnlockViewController.m
//  Skeleton
//
//  Created by Ian Harvey on 17/03/2014.
//

#import "SentegrityTAF_UnlockViewController.h"
#import "DAFSupport/DAFAppBase.h"
#import "DAFSupport/DAFAuthState.h"

@interface SentegrityTAF_UnlockViewController ()

@end


@implementation SentegrityTAF_UnlockViewController

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
        NSLog(@"SentegrityTAF_UnlockViewController: cancelling change password");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_UnlockViewController"
                                                 code:101
                                             userInfo:@{NSLocalizedDescriptionKey:@"Change password cancelled"} ]];
            result = nil;
        }];
    }
    else if (event==GetPasswordCancelled  && result != nil) {
        
        NSLog(@"SentegrityTAF_UnlockViewController: cancelling unlock");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_UnlockViewController"
                                                 code:102
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unlock cancelled"} ]];
            result = nil;
        }];
    }
    else if (event == AuthenticateWithWarnStarted)
    {
        NSLog(@"SentegrityTAF_UnlockViewController: starting authenticateWithWarn");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_UnlockViewController"
                                                 code:103
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unlock cancelled"} ]];
            result = nil;
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"SentegrityTAF_UnlockViewController: viewDidAppear");
    [super viewDidAppear:animated];
    
    // For demonstration purposes, retrieve startup data stored by FirstTimeViewController
    NSString *startupData = [DAFAuthState getInstance].vendorState;
    NSLog(@"SentegrityTAF_UnlockViewController: startup data = <%@>", startupData);
}

- (IBAction)onContinuePressed:(id)sender
{
    NSLog(@"SentegrityTAF_UnlockViewController: onContinuePressed");
    
    [self dismissViewControllerAnimated:NO completion: ^{
        NSLog(@"SentegrityTAF_UnlockViewController: delivering auth token");
        NSData *authToken = [NSData dataWithBytes:"dummy" length:5];
        [result setResult:authToken];
        result = nil;
    }];
}

- (IBAction)onTempUnlockPressed:(id)sender
{
    NSLog(@"SentegrityTAF_UnlockViewController: onTempUnlockPressed");
    
    [self dismissViewControllerAnimated:NO completion: ^{
        NSLog(@"SentegrityTAF_UnlockViewController: requesting temporary unlock");
        [[DAFAppBase getInstance] requestRecovery:result];
        result = nil;
    }];
    
}

@end
