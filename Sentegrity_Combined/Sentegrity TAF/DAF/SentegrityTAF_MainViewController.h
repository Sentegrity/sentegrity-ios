/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  SentegrityTAF_ViewController.h
//  Skeleton
//
//  Created by Ian Harvey on 14/03/2014.
//

#import <UIKit/UIKit.h>
#import <DAFSupport/DAFEventTypes.h>

@interface SentegrityTAF_MainViewController : UIViewController

// Called by SentegrityTAF_AppDelegate
- (void)updateUIForNotification:(enum DAFUINotification)event;


// UI elements
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
- (IBAction)onChangePasswordPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *lockButton;
- (IBAction)onLockPressed:(id)sender;

@end
