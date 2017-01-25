//
//  SentegrityTAF_TouchIDPermissionViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 30/10/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_TouchIDPermissionViewController.h"
#import "SentegrityTAF_TouchIDManager.h"
#import "Sentegrity_Startup_Store.h"

@interface SentegrityTAF_TouchIDPermissionViewController ()


@property (nonatomic, strong) SentegrityTAF_TouchIDManager *touchIDManager;

- (IBAction)pressedAccept:(id)sender;
- (IBAction)pressedDecline:(id)sender;


@end

@implementation SentegrityTAF_TouchIDPermissionViewController

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

- (IBAction)pressedAccept:(id)sender {
    
    
    NSError *error;
    SentegrityTAF_TouchIDManager *touchIDManager = [SentegrityTAF_TouchIDManager shared];

    
    if (![touchIDManager checkIfTouchIDIsAvailableWithError:&error]) {
        
        // error code == -7 ("No fingers are enrolled with Touch ID.")
        // error code == -5 ("Passcode not set.")
        
        if (error.code == (-7) || error.code == (-5)) {
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                           message:@"Open settings to configure TouchID."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TOUCHID_PASSCODE"]];
                                                                  }];

            
            [alert addAction:cancelAction];
            [alert addAction:settingsAction];

            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
            
            return;
        }
    }
    

    
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        return;
    }

    
    //ask user to use touch ID for future login
    [touchIDManager checkForTouchIDAuthWithMessage:@"Place fingerprint on the reader to enroll in Sentegrity" withCallback:^(TouchIDResultType resultType, NSError *error) {
        
        if (resultType == TouchIDResultType_Success) {
            //create touch ID
            [touchIDManager createTouchIDWithDecryptedMasterKey:self.decryptedMasterKey withCallback:^(BOOL successful, NSError *error) {
                if (!successful) {
                    //error
                    [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
                }
                else {
                    //everything successfull
                    [self.delegate dismissSuccesfullyFinishedViewController:self withInfo:nil];
                }
            }];
        }
        else if (resultType == TouchIDResultType_UserCanceled) {
            //user canceled popUp, do nothing
        }
        else if (resultType == TouchIDResultType_FailedAuth) {
            //user failed to authentificate, show error
            [self showAlertWithTitle:@"Authentification Failed" andMessage:nil];
        }
        else {
            //unknown error
            [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        }
    }];
}

- (IBAction)pressedDecline:(id)sender {
    
    //this is now: EXIT SETUP button action
    //Force to crash
    [self performSelector:NSSelectorFromString(@"crashme:") withObject:nil afterDelay:1];
    
    /*
    NSError *error;
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
    
    
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        return;
    }

    //save an answer
    [startup setTouchIDDisabledByUser:YES];
    [[Sentegrity_Startup_Store sharedStartupStore] setStartupStoreWithError:nil];
    [self.delegate dismissSuccesfullyFinishedViewController:self withInfo:nil];
     */
}







@end
