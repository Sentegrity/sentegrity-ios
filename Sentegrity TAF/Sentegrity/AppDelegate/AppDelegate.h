//
//  AppDelegate.h
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>
// DAF Support
#import "DAFSupport/DAFAppBase.h"

#import "DAFSkelMainViewController.h"
#import "DAFSkelFirstTimeViewController.h"
#import "DAFSkelUnlockViewController.h"
#import "DAFSkelAuthWarningViewController.h"

// Activity Dispatcher
#import "Sentegrity_Activity_Dispatcher.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

// Window
@property (strong, nonatomic) UIWindow *window;

// Activity Dispatcher
@property (strong, atomic) Sentegrity_Activity_Dispatcher *activityDispatcher;

@end

