//
//  SentegrityTAF_PrivacyViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 11/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_PrivacyViewController.h"
#import "Sentegrity_Policy.h"
#import "Sentegrity_Policy_Parser.h"

@interface SentegrityTAF_PrivacyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDesc;

- (IBAction)pressedFullPolicy:(id)sender;

@property (nonatomic, strong) NSURL *fullPolicyURL;



@end

@implementation SentegrityTAF_PrivacyViewController


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    //nav bar title logo
    UIImageView *imageViewTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sentegrity_white"]];
    [self.navigationItem setTitleView:imageViewTitle];
    
    
    
    //load data from policy
    NSError *error;
    Sentegrity_Policy *policy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
    
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        return;
    }
    
    if (!policy.privacy) {
        [self showAlertWithTitle:@"Error" andMessage:@"Invalid policy!"];
        NSLog(@"CRITICAL ERROR, INVALID POLICY");
        return;
    }
    
    
    
    //fill labels
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:2.0];
    style.alignment                = NSTextAlignmentJustified;
    
    NSDictionary *attribs = @{
                              NSBaselineOffsetAttributeName: @0,
                              NSParagraphStyleAttributeName: style,
                              NSForegroundColorAttributeName: kDefaultDashboardBarColor,
                              NSFontAttributeName: [UIFont fontWithName:@"Lato-Light" size:15.0]
                              };
    
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:policy.privacy[@"privacyScreenDesc"] attributes:attribs];
    self.labelDesc.attributedText = attributedString;
    
    self.labelTitle.text = policy.privacy[@"privacyScreenTitle"];
    self.fullPolicyURL = [NSURL URLWithString:policy.privacy[@"privacyScreenContactURL"]];
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pressedFullPolicy:(id)sender {
    if (!self.fullPolicyURL)
        return;
    
    [[UIApplication sharedApplication] openURL:self.fullPolicyURL];
}
@end
