//
//  SentegrityTAF_BlankAuthViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 31/07/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"
#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"


@interface SentegrityTAF_BlankAuthViewController : SentegrityTAF_BaseViewController

@property (weak, nonatomic) DAFWaitableResult *result;

- (void)updateUIForNotification:(enum DAFUINotification)event;

@end
