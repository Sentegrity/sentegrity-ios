//
//  SentegrityTAF_DetailInfoViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 24/11/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_DetailInfoViewController.h"
#import "CircularProgressView.h"
#import "Sentegrity_Constants.h"


@interface SentegrityTAF_DetailInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelExplanation;
@property (weak, nonatomic) IBOutlet UILabel *labelSuggestion;
@property (weak, nonatomic) IBOutlet CircularProgressView *circularProgressView;



@end

@implementation SentegrityTAF_DetailInfoViewController

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    //nav bar title logo
    UIImageView *imageViewTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sentegrity_white"]];
    [self.navigationItem setTitleView:imageViewTitle];
    
    
    //labels
    self.labelTitle.text = self.subClassResultObject.subClassTitle;
    self.labelStatus.text = [self.subClassResultObject.subClassStatusText uppercaseString];
    self.labelExplanation.text = self.subClassResultObject.subClassExplanation;
    self.labelSuggestion.text = self.subClassResultObject.subClassSuggestion;
    
    
    //"TRUSTED" is yellow, all other states are red
    if ([self.labelStatus.text isEqualToString:@"COMPLETE"]){
        self.labelStatus.textColor = kStatusTrustedColor;
    }
    else {
        self.labelStatus.textColor = kStatusUnTrustedColor;
    }
    
    //imageview
    self.imageViewIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)self.subClassResultObject.subClassIconID]];
    
    
    //circle progress
    self.circularProgressView.circleWidth = 5.0;
    self.circularProgressView.circleColor = kCircularProgressEmptyColor;
    self.circularProgressView.circleProgressColor = kCircularProgressFillColor;
    self.circularProgressView.progress = self.subClassResultObject.trustPercent;

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
