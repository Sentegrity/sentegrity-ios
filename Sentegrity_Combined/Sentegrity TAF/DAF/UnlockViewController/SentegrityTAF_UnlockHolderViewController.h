//
//  SentegrityTAF_UnlockHolderViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 21/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"

#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"

@interface SentegrityTAF_UnlockHolderViewController : SentegrityTAF_BaseViewController


@property (weak, nonatomic) DAFWaitableResult *result;


// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;
- (void) loadNewUnlockViewController;

@end
