/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  DAFSkelFirstTimeViewController.m
//  Skeleton
//
//  Created by Ian Harvey on 17/03/2014.
//

#import "DAFSkelFirstTimeViewController.h"

#import "DAFSupport/DAFAuthState.h"

@interface DAFSkelFirstTimeViewController ()

@end


@implementation DAFSkelFirstTimeViewController

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
    // We don't expect this VC to be active during a change-password
    // sequence. If this becomes a valid situation, fix this code to dismiss
    // this VC (see DAFSkelUnlockViewController).
    NSAssert( !(event == ChangePasswordCancelled && result != nil), @"Unexpected ChangePasswordCancelled");
}

- (IBAction)onContinuePressed:(id)sender
{
    NSLog(@"DAFSkelFirstTimeViewController: onContinuePressed");
    
    // Typically we'll record some startup data here
    [[DAFAuthState getInstance] setVendorState:@"example startup data"];
    
    [self dismissViewControllerAnimated:NO completion: ^{
        NSLog(@"DAFSkelFirstTimeViewController: delivering auth token");
        NSData *authToken = [NSData dataWithBytes:"dummy" length:5];
        [result setResult:authToken];
        result = nil;
    }];
}

@end
