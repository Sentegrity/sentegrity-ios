//
//  DAFDefaultUnhandledOperationController.h
//  DAFsupport
//
//  Created by Lorenzo Blasa on 17/03/2016.
//  Copyright (c) 2016 Good Technology Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAFAuthenticationWarning.h"
#import "DAFWaitableResult.h"

@interface DAFDefaultUnhandledOperationController : UIViewController

@property enum DAFUIAction entryMode;
@property (weak, nonatomic) DAFWaitableResult *result;
@property (strong, nonatomic) NSString *message;

@property (weak, nonatomic) IBOutlet UILabel *warningMessage;

- (IBAction)onOkPressed:(id)sender;

@end
