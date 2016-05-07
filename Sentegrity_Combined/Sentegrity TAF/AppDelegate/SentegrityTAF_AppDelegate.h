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

// Root View Controller
#import "SentegrityTAF_Main2ViewController.h"

// Activity Dispatcher
#import "Sentegrity_Activity_Dispatcher.h"

// Implement the DAFAppBase delegate and conform to GDiOSDelegate protocol

@interface SentegrityTAF_AppDelegate : DAFAppBase 


// root view controller
@property (strong, nonatomic) SentegrityTAF_Main2ViewController *main2ViewController;

@end

