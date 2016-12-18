//
//  SentegrityTAF_SupportViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 11/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"

@protocol SentegrityTAF_SupportDelegate <NSObject>

- (void) dismissSupportViewController;

@end


@interface SentegrityTAF_SupportViewController : SentegrityTAF_BaseViewController


@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *supportPhone;
@property (nonatomic, strong) NSString *supportEmail;


@property (nonatomic, weak) id <SentegrityTAF_SupportDelegate> delegateSupport;


@end
