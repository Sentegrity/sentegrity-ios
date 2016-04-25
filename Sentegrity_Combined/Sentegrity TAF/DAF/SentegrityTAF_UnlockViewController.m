/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  SentegrityTAF_UnlockViewController.m
//  Skeleton
//
//  Created by Ian Harvey on 17/03/2014.
//

#import "SentegrityTAF_UnlockViewController.h"

// DAF Support
#import "DAFSupport/DAFAppBase.h"
#import "DAFSupport/DAFAuthState.h"

// Sentegrity
#import "Sentegrity.h"

// Animated Progress Alerts
#import "MBProgressHUD.h"

// Custom Alert View
#import "SCLAlertView.h"

// Dashboard View Controller
#import "DashboardViewController.h"

@interface SentegrityTAF_UnlockViewController ()

// Progress HUD
@property (nonatomic,strong) MBProgressHUD *hud;

@end


@implementation SentegrityTAF_UnlockViewController

@synthesize result;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUIForNotification:(enum DAFUINotification)event
{
    if (event==ChangePasswordCancelled  && result != nil)
    {
        // Idle Lock (or other lock event) happened during change-passphrase sequence
        // Ensure this VC is dismissed if it's showing
        NSLog(@"SentegrityTAF_UnlockViewController: cancelling change password");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_UnlockViewController"
                                                 code:101
                                             userInfo:@{NSLocalizedDescriptionKey:@"Change password cancelled"} ]];
            result = nil;
        }];
    }
    else if (event==GetPasswordCancelled  && result != nil) {
        
        NSLog(@"SentegrityTAF_UnlockViewController: cancelling unlock");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_UnlockViewController"
                                                 code:102
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unlock cancelled"} ]];
            result = nil;
        }];
    }
    else if (event == AuthenticateWithWarnStarted)
    {
        NSLog(@"SentegrityTAF_UnlockViewController: starting authenticateWithWarn");
        [self dismissViewControllerAnimated:NO completion: ^{
            [result setError:[NSError errorWithDomain:@"SentegrityTAF_UnlockViewController"
                                                 code:103
                                             userInfo:@{NSLocalizedDescriptionKey:@"Unlock cancelled"} ]];
            result = nil;
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"SentegrityTAF_UnlockViewController: viewDidAppear");
    [super viewDidAppear:animated];
    
    // For demonstration purposes, retrieve startup data stored by FirstTimeViewController
    NSString *startupData = [DAFAuthState getInstance].vendorState;
    NSLog(@"SentegrityTAF_UnlockViewController: startup data = <%@>", startupData);
    
    // Run Core Detection
    
    // Show Animation
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.hud.labelText = @"Analyzing";
    self.hud.labelFont = [UIFont fontWithName:@"OpenSans-Bold" size:25.0f];
    
    self.hud.detailsLabelText = @"Mobile Security Posture";
    self.hud.detailsLabelFont = [UIFont fontWithName:@"OpenSans-Regular" size:18.0f];
    
    // Kick off Core Detection
    @autoreleasepool {
        
        dispatch_queue_t myQueue = dispatch_queue_create("Core_Detection_Queue",NULL);
        
        dispatch_async(myQueue, ^{
            
            // Perform Core Detection
            [self performCoreDetection:self];
            
        });
    }
}

#pragma mark - Core Detection

// Perform Core Detection
- (void)performCoreDetection:(id)sender {
    
    // Upload run history (if necessary) and check for new policy
    [[Sentegrity_Network_Manager shared] uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback:^(BOOL successfullyExecuted, BOOL successfullyUploaded, BOOL newPolicyDownloaded, NSError *error) {
        
        if (!successfullyExecuted) {
            // something went wrong somewhere (uploading, or new policy)
            NSLog(@"Error unable to run Network Manager:\n %@", error.debugDescription);
        }
        
        if (successfullyUploaded) {
            //error maybe occured on policy download, but it succesfully uploaded runHistoryObjects report
            [[Sentegrity_Startup_Store sharedStartupStore] setStartupStoreWithError:&error];
            
            // Check for an error
            if (error != nil) {
                // Unable to remove the store
                NSLog(@"Error unable to update startup store: %@", error.debugDescription);
            }
            else {
                NSLog(@"Network manager: Succesfully uploaded runHistoryObjects.");
            }
        }
        if (newPolicyDownloaded) {
            NSLog(@"Network manager: New policy downloaded and stored for the next run.");
        }
    }];
    
    /* Perform Core Detection */
    
    // Run Core Detection
    [[CoreDetection sharedDetection] performCoreDetectionWithCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
        
        // Check if core detection completed successfully
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [self analyzePreAuthenticationActionsWithError:error];
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                
            });
            
            // Log the errors
            NSLog(@"\n\nErrors: %@", [*error localizedDescription]);
            
        } else {
            // Core Detection Failed
            NSLog(@"Failed to run Core Detection: %@", [*error localizedDescription] ); // Here's why
        }
        
    }]; // End of the Core Detection Block
    
} // End of Core Detection Function

#pragma mark - Analysis

// Set up the customizations for the view
- (void)analyzePreAuthenticationActionsWithError:(NSError **)error {
    
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    switch (computationResults.preAuthenticationAction) {
        case preAuthenticationAction_TransparentlyAuthenticate:
        {
            // Attempt to login
            // we have no input to pass, use nil
            Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:nil andError:error];
            
            // Set the authentication response code
            computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
            
            // Set history now, we have all the info we need
            [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
            
            // Go through the authentication results
            switch (computationResults.authenticationResult) {
                case authenticationResult_Success:{ // No transparent auth errors
                    
                    // Now we can pass the key to the GD runtime
                    NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
                    NSString *decryptedMasterKeyString = [NSString stringWithUTF8String:[decryptedMasterKey bytes]];
                    
                    // Use the decrypted master key
                    [result setResult:decryptedMasterKeyString];
                    result = nil;
                    
                    // Dismiss the view
                    //[self dismissViewControllerAnimated:NO completion:nil];
                    
                    // Done
                    break;
                    
                }
                    
                default: //Transparent auth errored, something very wrong happened because the transparent module found a match earlier...
                {
                    // Have the user interactive login
                    // Manually override the preAuthenticationAction and recall this function, we don't need to run core detection again
                    
                    computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
                    computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
                    
                    [self analyzePreAuthenticationActionsWithError:error];
                    
                    // Done
                    break;
                    
                }
                    
            } // Done Switch AuthenticationResult
            
            // Done
            break;
            
        }
            
        case preAuthenticationAction_BlockAndWarn:
        {
            
            // Login Response
            Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:nil andError:error];
            
            // Set the authentication response code
            computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
            
            // Set history now, we already have all the info we need
            [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
            
            SCLAlertView *blocked = [[SCLAlertView alloc] init];
            blocked.backgroundType = Shadow;
            [blocked removeTopCircle];
            
            [blocked addButton:@"TrustScore Details" actionBlock:^(void) {
                
                // Get the storyboard
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                // Create the main view controller
                DashboardViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
                
                [self.navigationController pushViewController:mainViewController animated:NO];
                
            }];
            
            [blocked showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
            
            // Done
            break;
            
        }
            
        case preAuthenticationAction_PromptForUserPassword:
        {
            
            SCLAlertView *userInput = [[SCLAlertView alloc] init];
            userInput.backgroundType = Transparent;
            userInput.showAnimationType = SlideInFromBottom;
            [userInput removeTopCircle];
            
            UITextField *userText = [userInput addTextField:@"Password"];
            
            [userInput addButton:@"Login" actionBlock:^(void) {
                
                Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:userText.text andError:error];
                
                // Set the authentication response code
                computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
                
                // Set history now, we already have all the info we need
                [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
                
                // Success and recoverable errors operate the same since we still managed to get a decrypted master key
                if(computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError ) {
                    
                    // Now we can pass the key to the GD runtime
                    NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
                    NSString *decryptedMasterKeyString = [NSString stringWithUTF8String:[decryptedMasterKey bytes]];
                    
                    // Use the decrypted master key
                    [result setResult:decryptedMasterKeyString];
                    result = nil;
                    
                    // Dismiss the view
                    //[self dismissViewControllerAnimated:NO completion:nil];
                    
                    
                } else if(computationResults.authenticationResult == authenticationResult_incorrectLogin) {
                    
                    // Show alert window
                    SCLAlertView *incorrect = [[SCLAlertView alloc] init];
                    incorrect.backgroundType = Shadow;
                    [incorrect removeTopCircle];
                    
                    [incorrect addButton:@"Retry" actionBlock:^(void) {
                        
                        // Call this function again
                        [self analyzePreAuthenticationActionsWithError:error];
                        
                    }];
                    
                    [incorrect showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
                    
                } else if (computationResults.authenticationResult == authenticationResult_irrecoverableError) {
                    
                    // Show alert window
                    SCLAlertView *error = [[SCLAlertView alloc] init];
                    error.backgroundType = Shadow;
                    [error removeTopCircle];
                    
                    [error addButton:@"Retry" actionBlock:^(void) {
                        
                        // Reload the view
                        [self viewDidAppear:NO];
                        
                    }];
                    
                    [error showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
                    
                }
                
            }];
            
            [userInput showCustom:self image:nil color:[UIColor grayColor] title:@"User Login" subTitle:@"Enter user password" closeButtonTitle:nil duration:0.0f];
            
            // Done
            break;
        }
            
        case preAuthenticationAction_PromptForUserPasswordAndWarn:
        {
            SCLAlertView *userInput = [[SCLAlertView alloc] init];
            userInput.backgroundType = Transparent;
            userInput.showAnimationType = SlideInFromBottom;
            [userInput removeTopCircle];
            
            UITextField *userText = [userInput addTextField:@"Password"];
            
            [userInput addButton:@"Login" actionBlock:^(void) {
                
                Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:userText.text andError:error];
                
                // Set the authentication response code
                computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
                
                // Set history now, we already have all the info we need
                [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
                
                // Success and recoverable errors operate the same since we still managed to get a decrypted master key
                if (computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError) {
                    
                    // Now we can pass the key to the GD runtime
                    NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
                    NSString *decryptedMasterKeyString = [NSString stringWithUTF8String:[decryptedMasterKey bytes]];
                    
                    // Use the decrypted master key
                    [result setResult:decryptedMasterKeyString];
                    result = nil;
                    
                    // Dismiss the view
                    //[self dismissViewControllerAnimated:NO completion:nil];
                    
                    
                } else if (computationResults.authenticationResult == authenticationResult_incorrectLogin) {
                    
                    // Show alert window
                    SCLAlertView *incorrect = [[SCLAlertView alloc] init];
                    incorrect.backgroundType = Shadow;
                    [incorrect removeTopCircle];
                    
                    [incorrect addButton:@"Retry" actionBlock:^(void) {
                        
                        // Call this function again
                        [self analyzePreAuthenticationActionsWithError:error];
                        
                    }];
                    
                    [incorrect showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
                    
                } else if (computationResults.authenticationResult == authenticationResult_irrecoverableError) {
                    
                    // Show alert window
                    SCLAlertView *error = [[SCLAlertView alloc] init];
                    error.backgroundType = Shadow;
                    [error removeTopCircle];
                    
                    [error addButton:@"Retry" actionBlock:^(void) {
                        
                        // Reload the view
                        [self viewDidAppear:NO];
                        
                    }];
                    
                    [error showCustom:self image:nil color:[UIColor grayColor] title:loginResponseObject.responseLoginTitle subTitle:loginResponseObject.responseLoginDescription closeButtonTitle:nil duration:0.0f];
                    
                }
                
            }];
            
            // Show the warning
            [userInput showCustom:self image:nil color:[UIColor grayColor] title:@"Warning" subTitle:@"This device is high risk or in violation of policy, this access attempt will be reported." closeButtonTitle:nil duration:0.0f];
            
            // Done
            break;
        }
            
        default:
            break;
            
    } // Done switch preauthentication action
    
}

@end
