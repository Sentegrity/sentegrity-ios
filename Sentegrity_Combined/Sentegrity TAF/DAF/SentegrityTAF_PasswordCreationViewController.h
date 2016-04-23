//
//  InitialPasswordCreation.h
//  GOOD
//
//  Created by Ivo Leko on 16/04/16.
//  Copyright © 2016 Ivo Leko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SentegrityTAF_BaseViewController.h"

// DAF Support
#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"

@interface SentegrityTAF_PasswordCreationViewController : SentegrityTAF_BaseViewController

// Result
@property (weak, nonatomic) DAFWaitableResult *result;

// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;

@end
