/*
 * (c) 2015 Good Technology Corporation. All rights reserved.
 */

#import <UIKit/UIKit.h>

#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"

@interface SentegrityTAF_AuthWarningViewController : UIViewController

@property (weak, nonatomic) DAFWaitableResult *result;

// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;

@end
