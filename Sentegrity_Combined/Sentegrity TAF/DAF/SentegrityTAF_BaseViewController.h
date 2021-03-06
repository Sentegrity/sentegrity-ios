//
//  Sentegrity_BaseViewController.h
//  GOOD
//
//  Created by Ivo Leko on 17/04/16.
//  Copyright © 2016 Ivo Leko. All rights reserved.
//

#import <UIKit/UIKit.h>

// System Version
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@protocol SentegrityTAF_basicProtocol <NSObject>

- (void) dismissSuccesfullyFinishedViewController:(UIViewController *) vc withInfo: (NSDictionary *) info;

@end

@interface SentegrityTAF_BaseViewController : UIViewController

@property (nonatomic, weak) id <SentegrityTAF_basicProtocol> delegate;

// Show an alert
- (UIAlertController *) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message;


@end
