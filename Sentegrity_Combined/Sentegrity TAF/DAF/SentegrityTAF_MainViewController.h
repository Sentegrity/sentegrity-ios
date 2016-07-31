//
//  SentegrityTAF_MainViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 06/05/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DAFSupport/DAFEventTypes.h>

// DAF View Controllers
#import "SentegrityTAF_UnlockViewController.h"
#import "SentegrityTAF_PasswordCreationViewController.h"
#import "SentegrityTAF_AuthWarningViewController.h"
#import "SentegrityTAF_WelcomeViewController.h"
#import "SentegrityTAF_AskPermissionsViewController.h"

// Activity Dispatcher
#import "Sentegrity_Activity_Dispatcher.h"

// General GD runtime
#import <GD/GDiOS.h>

#import "ILContainerView.h"



@interface SentegrityTAF_MainViewController : UIViewController


// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;


@property (weak, nonatomic) DAFWaitableResult *result;



@end
