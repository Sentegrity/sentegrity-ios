//
//  SentegrityTAF_TouchIDPermissionViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 30/10/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"

#import "DAFSupport/DAFWaitableResult.h"
#import "DAFSupport/DAFEventTypes.h"

@interface SentegrityTAF_TouchIDPermissionViewController : SentegrityTAF_BaseViewController

@property (nonatomic, strong) NSData *decryptedMasterKey;
@property (weak, nonatomic) DAFWaitableResult *result;


@end
