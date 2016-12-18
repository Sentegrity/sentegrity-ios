//
//  SentegrityTAF_VocalFacialPermissionsViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 13/11/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"
#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"


@interface SentegrityTAF_VocalFacialPermissionsViewController : SentegrityTAF_BaseViewController

@property (nonatomic, strong) NSData *decryptedMasterKey;
@property (weak, nonatomic) DAFWaitableResult *result;


- (IBAction)pressedAccept:(id)sender;
- (IBAction)pressedDecline:(id)sender;


@end
