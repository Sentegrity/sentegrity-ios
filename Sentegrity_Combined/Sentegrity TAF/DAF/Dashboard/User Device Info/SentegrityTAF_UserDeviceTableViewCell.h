//
//  SentegrityTAF_UserDeviceTableViewCell.h
//  Sentegrity
//
//  Created by Ivo Leko on 24/11/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularProgressView.h"

@interface SentegrityTAF_UserDeviceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CircularProgressView *circularProgressView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;



@end
