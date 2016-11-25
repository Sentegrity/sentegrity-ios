//
//  SentegrityTAF_UserDeviceTableViewCell.m
//  Sentegrity
//
//  Created by Ivo Leko on 24/11/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_UserDeviceTableViewCell.h"
#import "Sentegrity_Constants.h"


@implementation SentegrityTAF_UserDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    //configure circle view
    self.circularProgressView.circleWidth = 5.0;
    self.circularProgressView.circleColor = kCircularProgressEmptyColor;
    self.circularProgressView.circleProgressColor = kCircularProgressFillColor;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
