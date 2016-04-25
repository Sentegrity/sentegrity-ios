//
//  InitialPasswordCreation.m
//  GOOD
//
//  Created by Ivo Leko on 16/04/16.
//  Copyright © 2016 Ivo Leko. All rights reserved.
//

#import "SentegrityTAF_PasswordCreationViewController.h"
#import "LoginViewController.h"

@interface SentegrityTAF_PasswordCreationViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *onePixelConstraintsCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomFooterConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *textFieldNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldConfirmPassword;

@property (weak, nonatomic) IBOutlet UIView *viewFooter;

- (IBAction)pressedInfoButton:(id)sender;


@end

@implementation SentegrityTAF_PasswordCreationViewController

@synthesize result;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   // NSError *error;
 
   // NSString *masterKey = [[Sentegrity_Startup_Store sharedStartupStore] createNewStartupFileWithUserPassword:@"asdf" withError:&error];
    
    // generate lines with one pixel (on all iOS devices)
    for (NSLayoutConstraint *constraint in self.onePixelConstraintsCollection) {
        constraint.constant = 1.0 / [UIScreen mainScreen].scale;
    }
    
    //notifications for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //scroll inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.viewFooter.frame.size.height, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;

}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //hide nav bar if neccesary
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (self.textFieldNewPassword == textField) {
        [self.textFieldConfirmPassword becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self confirm];
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Workaround for the jumping text bug in iOS.
    [textField resignFirstResponder];
    [textField layoutIfNeeded];
}

// Validate the passwords
- (void)confirm {
    
    // Get the passwords
    NSString *pass1 = self.textFieldNewPassword.text;
    NSString *pass2 = self.textFieldConfirmPassword.text;

    // Check if the passwords meet the criteria
    if (![pass1 isEqualToString:pass2]) {
        
        // passwords do not match
        [self showAlertWithTitle:@"Passwords do not match!" andMessage:@"Please try again."];
        
    } else if (pass1.length < 4) {
        
        // password too short
        [self showAlertWithTitle:@"Password is too short." andMessage:@"Please try with a longer password."];
        
    }
    
    // TODO: If needed, add additional password checks
    
    else {
        
        //just for testing
        
        /* Startup File */
        // Check if the startup file exists, if not we will create a new one
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[Sentegrity_Startup_Store sharedStartupStore] startupFilePath]]) {
            
            // Populate the startup file
            NSError *error;
            NSString *masterKey = [[Sentegrity_Startup_Store sharedStartupStore] createNewStartupFileWithUserPassword:pass1 withError:&error];
            
            // TODO: Check for errors
            
            [self dismissViewControllerAnimated:NO completion: ^{
                NSLog(@"DAFSkelUnlockViewController: delivering auth token");
                NSData *authToken = [NSData dataWithBytes:"dummy" length:5];
                [result setResult:authToken];
                result = nil;
            }];
            
            // Set the result to the master key
            [result setResult:masterKey];
            result = nil;
            
            // Dismiss the view
            [self dismissViewControllerAnimated:NO completion:nil];
            
        } else {
            
            // TODO: Startup file already exists?
            NSLog(@"Startup file already exists!");
            [self showAlertWithTitle:@"Startup File already exists" andMessage:@"Major error"];
            
        }
    }
}

- (IBAction)pressedInfoButton:(id)sender {
    //Show alert
    [self showAlertWithTitle:   @"Password requirements!"
                  andMessage:   @"Your password must have:\n"
                                @"- At least 4 characters\n"
                                @"- No more than 3 of any character\n"
                                @"- No personal information"];
}



-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and location
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    //do animation
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:UIViewAnimationOptionBeginFromCurrentState | [curve intValue] animations:^{
        self.bottomFooterConstraint.constant = (keyboardBounds.size.height);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];

}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
  
    //do animation
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:UIViewAnimationOptionBeginFromCurrentState | [curve intValue] animations:^{
        self.bottomFooterConstraint.constant = 50;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];

}

#pragma mark - DAFSupport

- (void)updateUIForNotification:(enum DAFUINotification)event
{
    if (event==ChangePasswordCancelled  && result != nil)
    {
        // Idle Lock (or other lock event) happened during change-passphrase sequence
        // Ensure this VC is dismissed if it's showing
        NSLog(@"SentegrityTAF_PasswordCreationViewController: cancelling change password");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_PasswordCreationViewController"
                                                 code:101
                                             userInfo:@{NSLocalizedDescriptionKey:@"Change password cancelled"} ]];
            result = nil;
        }];
    }
    else if (event==GetPasswordCancelled  && result != nil) {
        
        NSLog(@"SentegrityTAF_PasswordCreationViewController: cancelling unlock");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_PasswordCreationViewController"
                                                 code:102
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unlock cancelled"} ]];
            result = nil;
        }];
    }
    else if (event == AuthenticateWithWarnStarted)
    {
        NSLog(@"SentegrityTAF_PasswordCreationViewController: starting authenticateWithWarn");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_PasswordCreationViewController"
                                                 code:103
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unlock cancelled"} ]];
            result = nil;
        }];
    }
}

@end
