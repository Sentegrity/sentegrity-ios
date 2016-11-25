//
//  SentegrityTAF_UserDeviceInformationViewController.h
//  Sentegrity
//
//  Created by Ivo Leko on 24/11/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_BaseViewController.h"

typedef enum {
    InformationTypeUser = 0,
    InformationTypeDevice
} InformationType;

@interface SentegrityTAF_UserDeviceInformationViewController : SentegrityTAF_BaseViewController

@property (nonatomic, strong) NSArray *arrayOfSubClassResults;
@property (nonatomic) InformationType informationType;

@end
