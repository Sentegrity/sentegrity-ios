//
//  SentegrityTAF_FirstTimeViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 27/07/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"
#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"
#import "ILContainerView.h"

// Activity Dispatcher
#import "Sentegrity_Activity_Dispatcher.h"

@interface SentegrityTAF_FirstTimeViewController : SentegrityTAF_BaseViewController

// Activity Dispatcher
@property (strong, atomic) Sentegrity_Activity_Dispatcher *activityDispatcher;

//application permissions
@property (nonatomic, strong) NSArray *applicationPermissions;

@property (weak, nonatomic) DAFWaitableResult *result;

// Called by DAFSkelAppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;




@end
