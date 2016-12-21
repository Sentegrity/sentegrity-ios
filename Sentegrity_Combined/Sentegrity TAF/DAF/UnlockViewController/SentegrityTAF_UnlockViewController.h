/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  SentegrityTAF_UnlockViewController.h
//  Skeleton
//
//  Created by Ian Harvey on 17/03/2014.
//

#import <UIKit/UIKit.h>

#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"

#import "SentegrityTAF_BaseViewController.h"

#import "Sentegrity_Crypto.h"

#import "DashboardViewController.h"


@interface SentegrityTAF_UnlockViewController : SentegrityTAF_BaseViewController

@property (weak, nonatomic) DAFWaitableResult *result;


// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;

@end
