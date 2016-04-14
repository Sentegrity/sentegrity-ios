/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  DAFSkelFirstTimeViewController.h
//  Skeleton
//
//  Created by Ian Harvey on 17/03/2014.
//

#import <UIKit/UIKit.h>

#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"

@interface DAFSkelFirstTimeViewController : UIViewController

@property (weak, nonatomic) DAFWaitableResult *result;

// Called by DAFSkelAppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;

// UI elements
- (IBAction)onContinuePressed:(id)sender;

@end
