//
//  SentegrityTAF_WelcomeViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 06/05/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WelcomeViewControllerDelegate <NSObject>

- (void) welcomeFinished;

@end


@interface SentegrityTAF_WelcomeViewController : UIViewController

@property (nonatomic, weak) id <WelcomeViewControllerDelegate> delegate;

@end
