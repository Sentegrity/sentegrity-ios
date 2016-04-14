//
//  DAFDefaultPasswordViewController.h
//  BTLEAuthenticator
//
//  Created by Ian Harvey on 31/01/2014.
//  Copyright (c) 2014 Good Technology Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DAFEventTypes.h"
#import "DAFWaitableResult.h"

@interface DAFDefaultPasswordViewController : UIViewController

@property enum DAFUIAction entryMode;
@property (weak, nonatomic) DAFWaitableResult *result;

@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (void)cancelCurrentOperation;

- (IBAction)editFinished:(id)sender;
- (IBAction)onCancelPressed:(id)sender;

@end
