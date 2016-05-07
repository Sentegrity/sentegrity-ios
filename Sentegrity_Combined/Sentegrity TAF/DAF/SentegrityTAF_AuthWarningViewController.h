/*
 * (c) 2015 Good Technology Corporation. All rights reserved.
 */

#import <UIKit/UIKit.h>

#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"
#import "SentegrityTAF_BaseViewController.h"

@interface SentegrityTAF_AuthWarningViewController : SentegrityTAF_BaseViewController

@property (weak, nonatomic) DAFWaitableResult *result;

// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;

@end
