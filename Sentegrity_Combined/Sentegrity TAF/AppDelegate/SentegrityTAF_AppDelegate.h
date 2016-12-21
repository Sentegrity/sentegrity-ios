//
//  SentegrityTAF_AppDelegate.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>

// DAF Support
#import "DAFSupport/DAFAppBase.h"

// General GD runtime
#import <GD/GDiOS.h>

// view controllers
#import "SentegrityTAF_MainViewController.h"
#import "SentegrityTAF_FirstTimeViewController.h"
#import "SentegrityTAF_UnlockViewController.h"
#import "SentegrityTAF_AuthWarningViewController.h"
#import "SentegrityTAF_BlankAuthViewController.h"
#import "SentegrityTAF_UnlockHolderViewController.h"

// Activity Dispatcher
#import "Sentegrity_Activity_Dispatcher.h"

// Implement the DAFAppBase delegate and conform to GDiOSDelegate protocol

@interface SentegrityTAF_AppDelegate : DAFAppBase 


@property (nonatomic, strong) SentegrityTAF_BlankAuthViewController *authFirstTimeViewController;
@property (nonatomic, strong) SentegrityTAF_BlankAuthViewController *authViewController;
@property (strong, nonatomic) SentegrityTAF_MainViewController *mainViewController;
@property (nonatomic, strong) SentegrityTAF_FirstTimeViewController *firstTimeViewController;
@property (nonatomic, strong) SentegrityTAF_UnlockHolderViewController *unlockHolderViewController;
@property (nonatomic, strong) SentegrityTAF_AuthWarningViewController *easyActivationViewController;
@property (nonatomic, strong) Sentegrity_Activity_Dispatcher *activityDispatcher;


@end

