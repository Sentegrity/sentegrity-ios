//
//  SentegrityTAF_WelcomeViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 06/05/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_WelcomeViewController.h"
#import "Sentegrity_Network_Manager.h"
#import "Sentegrity_Policy_Parser.h"
#import <GD/GDiOS.h>
#import "Sentegrity_Startup_Store.h"
#import "MBProgressHUD.h"



@interface SentegrityTAF_WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelWelcomeTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelWelcomeDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;
@property (weak, nonatomic) IBOutlet UIView *viewLogoAndLabelsHolder;

- (IBAction)pressedContinue:(id)sender;


@end

@implementation SentegrityTAF_WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonContinue.enabled = NO;
    self.viewLogoAndLabelsHolder.alpha = 0;
    self.buttonContinue.alpha = 0;

    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [self prepareStartupAndFetchNewPolicy];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) prepareStartupAndFetchNewPolicy {

    //show loader
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //before proceed, we try to fetch latest policy from the server. This must be succesfully executed before proceeding to other screens

    NSString *email = [[[GDiOS sharedInstance] getApplicationConfig] objectForKey:(NSString *)GDAppConfigKeyUserId];

    
    if (email == nil || [email isEqual:[NSNull null]]) {
        //something is not good with GOOD
        [self showErrorWithRetryButtonAndDescription:@"Can not get email address. Please try again."];
        NSLog(@"FATAL ERROR: Cannot get email from GDiOS!");
        
        //hide loader
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    NSError *error;
    
    //create new startup file, we need it now because of deviceSalt
    [[Sentegrity_Startup_Store sharedStartupStore] createNewStartupFileWithError:&error];
    if (error) {
        [self showErrorWithRetryButtonAndDescription:error.localizedDescription];
        
        //hide loader
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    //update new startup file with email
    [[Sentegrity_Startup_Store sharedStartupStore] updateStartupFileWithEmail:email withError:&error];
    if (error) {
        [self showErrorWithRetryButtonAndDescription:error.localizedDescription];
        
        //hide loader
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    
    //try to get new policy from the server
    [[Sentegrity_Network_Manager shared] checkForNewPolicyWithEmail:email withCallback:^(BOOL successfullyExecuted, BOOL newPolicyDownloaded, BOOL policyOrganisationExists, NSError *errorT) {
        
        //hide loader
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
        if (!successfullyExecuted) {
            [self showErrorWithRetryButtonAndDescription:errorT.localizedDescription];
            return;
        }
        
        //if policy organisation exists, but there is no new policy for this version, stop executing
        if (policyOrganisationExists && !newPolicyDownloaded) {
            [self showErrorWithRetryButtonAndDescription:@"This app version is not supported by your organization."];
            return;
        }
        
        [self loadUI];
        self.buttonContinue.enabled = YES;

    }];
}


- (void) loadUI {
    
    //load title and description from policy
    NSError *error;
    Sentegrity_Policy *policy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
    
    if (error) {
        //some strange error occured
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
    }
    
    self.labelWelcomeTitle.text = policy.welcome[@"title"];
    self.labelWelcomeDescription.text = policy.welcome[@"description"];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewLogoAndLabelsHolder.alpha = 1;
        self.buttonContinue.alpha = 1;
    }];
}



- (void) showErrorWithRetryButtonAndDescription: (NSString *) description {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:description
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self prepareStartupAndFetchNewPolicy];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)pressedContinue:(id)sender {
    [self.delegate dismissSuccesfullyFinishedViewController:self withInfo:nil];
}




@end
