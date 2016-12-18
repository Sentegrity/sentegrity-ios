//
//  SentegrityTAF_AskPermissionsViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 07/05/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"
#import "LocationPermissionViewController.h"
#import "ActivityPermissionViewController.h"

#import "Sentegrity_Activity_Dispatcher.h"


@interface SentegrityTAF_AskPermissionsViewController : SentegrityTAF_BaseViewController <ISHPermissionsViewControllerDataSource, ISHPermissionsViewControllerDelegate>

@property (nonatomic, strong) NSArray *permissions;
@property (strong, atomic) Sentegrity_Activity_Dispatcher *activityDispatcher;


@end
