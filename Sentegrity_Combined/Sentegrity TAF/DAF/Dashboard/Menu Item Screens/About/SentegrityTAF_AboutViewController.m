//
//  SentegrityTAF_AboutViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 11/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_AboutViewController.h"
#import "Sentegrity_Policy_Parser.h"
#import "Sentegrity_Policy.h"

@interface SentegrityTAF_AboutViewController ()


@property (nonatomic, strong) NSURL *learnMoreURL;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDesc;

- (IBAction)pressedButton:(id)sender;



@end

@implementation SentegrityTAF_AboutViewController


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
    
    if (!policy.about) {
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
    
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:policy.about[@"aboutScreenDesc"] attributes:attribs];
    self.labelDesc.attributedText = attributedString;

    
    self.labelTitle.text = policy.about[@"aboutScreenTitle"];
    self.learnMoreURL = [NSURL URLWithString:policy.about[@"aboutScreenContactURL"]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pressedButton:(id)sender {
    if (!self.learnMoreURL)
        return;
    
    [[UIApplication sharedApplication] openURL:self.learnMoreURL];
}
@end
