//
//  InitialPasswordCreation.m
//  GOOD
//
//  Created by Ivo Leko on 16/04/16.
//  Copyright © 2016 Ivo Leko. All rights reserved.
//

#import "SentegrityTAF_PasswordCreationViewController.h"
#import "LoginViewController.h"
#import "Sentegrity_TrustFactor_Storage.h"

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
    

    // Password requirements:
    NSDictionary *passwordRequirements = @{
                                           @"minPasswordLenght" : @(4),
                                           @"isAlphaNumeric" : @(YES),
                                           @"isMixedCase" : @(YES),
                                           @"specialCharacter" : @(NO)
                                           };
    
    
    // Check if the passwords meet the criteria
    if (![pass1 isEqualToString:pass2]) {
        
        // passwords do not match
        [self showAlertWithTitle:@"Passwords do not match!" andMessage:@"Please try again."];
        return;
        
    } else if (![self checkPassword:pass1 withRequirements:passwordRequirements]) {
        
        // password is not valid
        return;
    }
    
    
    
    NSError *error;

    //Reset Startup Store (remove store file)
    [[Sentegrity_Startup_Store sharedStartupStore] resetStartupStoreWithError:&error];
    
    if (error) {
        //TODO: error message for user
        [self showAlertWithTitle:@"Error" andMessage:@"Unknown error"];
        return;
    }
    
    //reset assertion store (remove assertion file)
    [[Sentegrity_TrustFactor_Storage sharedStorage] resetAssertionStoreWithError:&error];
    
    if (error) {
        //TODO: error message for user
        [self showAlertWithTitle:@"Error" andMessage:@"Unknown error"];
        return;
    }

    
    // Start with a clean startup file
    // Populate the startup file
    
    
    
    //Get the email address from the enterprise policy
    // NSString *email = [self.enterprisePolicy objectForKey:GDAppConfigKeyUserId];
    
    NSString *masterKeyString = [[Sentegrity_Startup_Store sharedStartupStore] createNewStartupFileWithUserPassword:pass1  withError:&error];
    
    
    if (error) {
        //TODO: error message for user
        [self showAlertWithTitle:@"Error" andMessage:@"Unknown error"];
        return;
    }
    
    // Set the result to the master key
    [result setResult:masterKeyString];
    result = nil;
    
    // Dismiss the view
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

- (IBAction)pressedInfoButton:(id)sender {
    //Show alert
    [self showAlertWithTitle:   @"Password requirements!"
                  andMessage:   @"Your password must have:\n"
                                @"- At least 4 characters\n"
                                @"- No more than 3 of any character\n"
                                @"- No personal information"];
}


// TBD
- (BOOL) checkPassword: (NSString *) password withRequirements:(NSDictionary *) requirements {

    BOOL lowerCaseLetter = NO;
    BOOL upperCaseLetter = NO;
    BOOL digit = NO;
    BOOL character = NO;
    BOOL specialCharacter = NO;
    
    if (![requirements[@"isMixedCase"] boolValue]) {
        lowerCaseLetter = YES;
        upperCaseLetter = YES;
    }
    
    if (![requirements[@"isAlphaNumeric"] boolValue]) {
        digit = YES;
        character = YES;
    }
    
    if (![requirements[@"specialCharacter"] boolValue]) {
        specialCharacter = YES;
    }
    
    if([password length] >= [requirements[@"minPasswordLenght"] boolValue])
    {
        for (int i = 0; i < [password length]; i++)
        {
            unichar c = [password characterAtIndex:i];
            if(!lowerCaseLetter)
            {
                lowerCaseLetter = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!upperCaseLetter)
            {
                upperCaseLetter = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!digit)
            {
                digit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
            }
            if(!character)
            {
                character = [[NSCharacterSet letterCharacterSet] characterIsMember:c];
            }
            if(!specialCharacter)
            {
                specialCharacter = [[NSCharacterSet symbolCharacterSet] characterIsMember:c];
            }
        }
        
        if(digit && lowerCaseLetter && upperCaseLetter && character && specialCharacter)
        {
            //password is valid for given requirements
            return YES;
        }
        else
        {
            
            NSMutableString *stringM = [[NSMutableString alloc] init];
            [stringM appendString:@"Please ensure that you have at least "];
            if (!lowerCaseLetter || !upperCaseLetter) {
                [stringM appendString:@"one lower case letter and one upper case letter."];
            }
            else if (!digit) {
                [stringM appendString:@"one digit."];
            }
            else if (!character) {
                [stringM appendString:@"one character."];
            }
            else if (!specialCharacter) {
                [stringM appendString:@"one special character."];
            }
            
            [self showAlertWithTitle:@"Error" andMessage:stringM];
        }
        
    }
    else
    {
        [self showAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Please Enter password with at least %ld characters.", [requirements[@"minPasswordLenght"] integerValue]]];
        
    }
    
    return NO;
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
