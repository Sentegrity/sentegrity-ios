//
//  SentegrityTAF_SupportViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 11/12/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_SupportViewController.h"
#import "Sentegrity_Policy.h"
#import "Sentegrity_Policy_Parser.h"
#import "Sentegrity_Startup_Store.h"
#import "Sentegrity_Startup.h"

@interface SentegrityTAF_SupportViewController ()

@property (nonatomic, strong) NSString *contactPhone;
@property (nonatomic, strong) NSString *contactEmail;


@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDesc;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelDeviceID;


- (IBAction)pressedPhone:(id)sender;
- (IBAction)pressedEmail:(id)sender;




@end

@implementation SentegrityTAF_SupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    //nav bar title logo
    UIImageView *imageViewTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sentegrity_white"]];
    [self.navigationItem setTitleView:imageViewTitle];
    
    //remove blur
    self.navigationController.navigationBar.translucent = NO;
    
    //background color of bar (#444444)
    self.navigationController.navigationBar.barTintColor = kDefaultDashboardBarColor;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //color of buttons
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //show done button if called from unlock screen
    if (self.delegate) {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressedDone)];
        self.navigationItem.leftBarButtonItem = barButton;
    }
    
    
    //load data from policy
    NSError *error;
    Sentegrity_Policy *policy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];

    
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        return;
    }
    
    if (!policy.support) {
        [self showAlertWithTitle:@"Error" andMessage:@"Invalid policy!"];
        NSLog(@"CRITICAL ERROR, INVALID POLICY");
        return;
    }
    
    //get current startup
    Sentegrity_Startup *currentStartup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
    
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
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
    
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:policy.support[@"supportScreenDesc"] attributes:attribs];
    self.labelDesc.attributedText = attributedString;
    
    
    self.labelTitle.text = policy.support[@"supportScreenTitle"];
    self.contactPhone = policy.support[@"supportScreenContactPhone"];
    self.contactEmail = policy.support[@"supportScreenContactEmail"];
    self.labelEmail.text = currentStartup.email;
    self.labelDeviceID.text = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) pressedDone {
    [self.delegate dismissSupportViewController];
}

- (IBAction)pressedPhone:(id)sender {
    NSString *phoneNumber = [@"tel://" stringByAppendingString:self.contactPhone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)pressedEmail:(id)sender {
    NSString *email = [NSString stringWithFormat:@"mailto:%@", self.contactEmail];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}
@end
