//
//  Sentegrity_BaseViewController.h
//  GOOD
//
//  Created by Ivo Leko on 17/04/16.
//  Copyright © 2016 Ivo Leko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SentegrityTAF_basicProtocol <NSObject>

- (void) dismiss:(UIViewController *) vc;

@end

@interface SentegrityTAF_BaseViewController : UIViewController

@property (nonatomic, weak) id <SentegrityTAF_basicProtocol> delegate;
// Show an alert
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;


@end
