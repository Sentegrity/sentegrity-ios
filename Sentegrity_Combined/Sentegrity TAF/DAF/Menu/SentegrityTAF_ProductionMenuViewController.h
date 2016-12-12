//
//  SentegrityTAF_ProductionMenuViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 11/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"

static NSString *SentegrityTAF_MenuItem_UserSecurity = @"User Security";
static NSString *SentegrityTAF_MenuItem_DeviceSecurity = @"Device Security";
static NSString *SentegrityTAF_MenuItem_Support = @"Support";
static NSString *SentegrityTAF_MenuItem_About = @"About";
static NSString *SentegrityTAF_MenuItem_Privacy = @"Privacy";



@protocol SentegrityTAF_ProductionMenuDelegate <NSObject>

- (void) userSelectedItemFromMenu: (NSString *) menuItem;

@end


@interface SentegrityTAF_ProductionMenuViewController : SentegrityTAF_BaseViewController

@property (nonatomic, weak) id <SentegrityTAF_ProductionMenuDelegate> delegate;

@end
