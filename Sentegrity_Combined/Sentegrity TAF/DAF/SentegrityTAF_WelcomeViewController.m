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
- (IBAction)pressedContinue:(id)sender;


@end

@implementation SentegrityTAF_WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressedContinue:(id)sender {
    
    
    //show loader
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    //before proceed, we try to fetch latest policy from the server. This must be succesfully executed before proceeding to other screens
    NSString *email = [[[GDiOS sharedInstance] getApplicationConfig] objectForKey:GDAppConfigKeyUserId];

    if (email == nil || [email isEqual:[NSNull null]]) {
        //something is not good with GOOD
        [self showAlertWithTitle:@"Error" andMessage:@"Can not get email address. Please try again."];
        NSLog(@"FATAL ERROR: Cannot get email from GDiOS!");
        
        //hide loader
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    NSError *error;
    
    //create new startup file, we need it now because of deviceSalt
    [[Sentegrity_Startup_Store sharedStartupStore] createNewStartupFileWithError:&error];
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        
        //hide loader
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    //update new startup file with email
    [[Sentegrity_Startup_Store sharedStartupStore] updateStartupFileWithEmail:email withError:&error];
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        
        //hide loader
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    
    //try to get new policy from the server
    [[Sentegrity_Network_Manager shared] checkForNewPolicyWithEmail:email withCallback:^(BOOL successfullyExecuted, BOOL newPolicyDownloaded, NSError *errorT) {
        
        //hide loader
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
        if (!successfullyExecuted) {
            [self showAlertWithTitle:@"Error" andMessage:errorT.localizedDescription];
            return;
        }
        
        [self.delegate dismissSuccesfullyFinishedViewController:self];
    }];
}




@end
