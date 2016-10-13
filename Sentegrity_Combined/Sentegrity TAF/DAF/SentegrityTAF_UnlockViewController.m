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

// Message UI
#import <MessageUI/MessageUI.h>

#import "SentegrityTAF_TouchIDManager.h"


@interface SentegrityTAF_UnlockViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate> {
    BOOL once;
}

@property (nonatomic) DashboardViewController *dashboardViewController;

@property (nonatomic, strong) SentegrityTAF_TouchIDManager *touchIDManager;


@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *onePixelConstraintsCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomFooterConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewSplash;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIView *viewFooter;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;


@property (weak, nonatomic) IBOutlet UIButton *buttonInfo;
@property (weak, nonatomic) IBOutlet UIButton *buttonSentegrity;

- (IBAction)pressedSentegrityLogo:(id)sender;
- (IBAction)pressedInfoButton:(id)sender;

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

- (id) init {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self =  [self initWithNibName:@"SentegrityTAF_UnlockViewController_iPhone" bundle:nil];
    }
    else {
        self =  [self initWithNibName:@"SentegrityTAF_UnlockViewController_iPad" bundle:nil];
    }
    
    if (self) {
    }
    return self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) dealloc {
    
    //remove dashboard
    if (self.dashboardViewController)
        [self.dashboardViewController dismissViewControllerAnimated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //hide nav bar if neccesary
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //touchID manager
    self.touchIDManager = [[SentegrityTAF_TouchIDManager alloc] init];

    
    
    //configure and hide splash image
    self.imageViewSplash.alpha = 0;
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if (screenHeight <= 480){
            self.imageViewSplash.image = [UIImage imageNamed:@"Splash_3.5"];
            NSLog(@"iPhone 4/4s (3.5 inch)");
        } else if ( screenHeight > 480 && screenHeight <= 568 ){
            self.imageViewSplash.image = [UIImage imageNamed:@"Splash_4.0"];
            NSLog(@"iPhone 5/5s/5c/SE (4.0 inch)");
        } else if ( screenHeight > 568 && screenHeight <= 667 ){
            self.imageViewSplash.image = [UIImage imageNamed:@"Splash_4.7"];
            NSLog(@"iPhone 6/6s (4.7 inch)");
        } else {
            self.imageViewSplash.image = [UIImage imageNamed:@"Splash_5.5"];
            NSLog(@"iPhone 6+/6s+ (5.5 inch)");
        }
    }
    

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
    
    

}


- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.imageViewSplash.alpha = 1.0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.imageViewSplash.alpha = 0.0;
        }];
    });
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self confirm];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Workaround for the jumping text bug in iOS.
    [textField resignFirstResponder];
    [textField layoutIfNeeded];
}

- (void)updateUIForNotification:(enum DAFUINotification)event
{
    
    if (event==ChangePasswordCancelled || event==GetPasswordCancelled)
    {
        // We were interrupted by idle lock, Easy Activation request, etc.
        // Ensure this VC is dismissed if it's showing
        NSLog(@"SentegrityTAF_UnlockViewController: cancelling change password");
        [self dismissViewControllerAnimated:NO completion: ^{
            if ( result != nil )
            {
                [result setError:[NSError errorWithDomain:@"SentegrityTAF_UnlockViewController"
                                                     code:101
                                                 userInfo:@{NSLocalizedDescriptionKey:@"Unlock VC interrupted"} ]];
            }
            result = nil;
        }];
    }
}


- (void) confirm {
    
    //Get password
    NSString *passwordAttempt = self.textFieldPassword.text;
    NSError *error;
    
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    if(computationResults.preAuthenticationAction == preAuthenticationAction_PromptForUserPassword || computationResults.preAuthenticationAction ==preAuthenticationAction_PromptForUserPasswordAndWarn)
    {
        
        Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithUserInput:passwordAttempt andError:&error];
        
        // Set the authentication response code
        computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
        
        // Set history now, we already have all the info we need
        [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:&error];
        
        // Success and recoverable errors operate the same since we still managed to get a decrypted master key
        if(computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError ) {
            
            // Now we can pass the key to the GD runtime
            NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
            
            NSString *decryptedMasterKeyString = [[Sentegrity_Crypto sharedCrypto] convertDataToHexString:decryptedMasterKey withError:&error];
            
            
            NSError *error;
            Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
            
            //user succesfully logged in with password, now check if user enabled touch ID for future login
            if (![startup touchIDDisabledByUser]) {
                
                //touch ID enabled, check if touch ID is available on current device
                
                if ([self.touchIDManager checkIfTouchIDIsAvailableWithError:nil]) {
                    
                    //great, it is available, now check is touchID already configured, but item is invalidated
                    if (self.touchIDManager.touchIDItemInvalidated) {
                        [self createTouchIDWithDecryptedMasterKey:decryptedMasterKey]; //create again
                        [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
                    }
                    //if touch ID is already configured and active, that means that user probbably canceled TouchID auth, or failed with auth. In both cases, just ignore and continue.
                    else if (startup.touchIDKeyEncryptedMasterKeyBlobString) {
                        // do nothing
                        [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
                    }
                    
                    else {
                    
                        //ask user to use touch ID for future login
                        [self.touchIDManager checkForTouchIDAuthWithMessage:@"Enable TouchID as one of the options for authentication?" withCallback:^(TouchIDResultType resultType, NSError *error) {
                            
                            if (resultType == TouchIDResultType_Success) {
                                [self createTouchIDWithDecryptedMasterKey:decryptedMasterKey]; // create touchID
                            }
                            else if (resultType == TouchIDResultType_UserCanceled) {
                                //save an answer
                                [startup setTouchIDDisabledByUser:YES];
                                [[Sentegrity_Startup_Store sharedStartupStore] setStartupStoreWithError:nil];
                            }
                            else if (resultType == TouchIDResultType_FailedAuth) {
                                [self showAlertWithTitle:@"Authentification Failed" andMessage:@"You can try again later."];
                            }
                            else {
                                [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
                            }
                            
                            [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
                        }];
                    }
                }
                else
                    [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
            }
            else
                [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
        
            
            
        } else if(computationResults.authenticationResult == authenticationResult_incorrectLogin) {
            
            // Show alert window
            [self showAlertWithTitle:loginResponseObject.responseLoginTitle andMessage:loginResponseObject.responseLoginDescription];

            
        } else if (computationResults.authenticationResult == authenticationResult_irrecoverableError) {
            
            // Show alert window
            [self showAlertWithTitle:loginResponseObject.responseLoginTitle andMessage:loginResponseObject.responseLoginDescription];
            
        }
        
        
        // Done
    }
  }

- (void) finishWithDecryptedMasterKey: (NSString *) decryptedMasterKeyString {
    
    // Direct call outside of DAF, but fails
    // NSError *error;
    // GDTrust *trustObject = [[DAFAppBase getInstance] gdTrust];
    // [trustObject unlockWithPassword:decryptedMasterKey error:&error];
    
    // We're done so dismiss and have main show the dashboard

    
    
    if (self.delegate) {
        // Use the decrypted master key
        [result setResult:decryptedMasterKeyString];
        result = nil;
        [self.delegate dismissSuccesfullyFinishedViewController:self];
    }
    else
        [self dismissViewControllerAnimated:NO completion:^{
            [result setResult:decryptedMasterKeyString];
            result = nil;
        }];

}


- (void) showInput {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.buttonInfo.alpha = 0.0;
        self.inputContainer.alpha = 1.0;
        self.buttonSentegrity.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
}

// Show the TAF Dashboard
- (IBAction)pressedSentegrityLogo:(id)sender {

    // removed for pilot
    
    /*
    // Show the landing page since we've been transparently authenticated
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Create the main view controller
     self.dashboardViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardviewcontroller"];
    
    // Hide the dashboard view controller
    [self.dashboardViewController.menuButton setHidden:YES];
    
    // We want the user to be able to go back from here
    [self.dashboardViewController.backButton setHidden:NO];
    
    // Set the last-updated text and reload button hidden
    [self.dashboardViewController.reloadButton setHidden:YES];
    
    // Navigation Controller
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.dashboardViewController];
    [navController setNavigationBarHidden:YES];
    
    // Present the view controller
    [self presentViewController:navController animated:NO completion:^{
        
        // Completed presenting
        
        // Hide the dashboard view controller
        [self.dashboardViewController.menuButton setHidden:YES];
        
        // Set the last-updated text and reload button hidden
        [self.dashboardViewController.reloadButton setHidden:YES];
        
        // Un-Hide the back button
        [self.dashboardViewController.backButton setHidden:NO];
        
    }];
     
     */
    
}

// Report a problem
- (IBAction)pressedInfoButton:(id)sender {
    
    // Report a problem - Email
    
    // Email Subject
    NSString *emailTitle = @"Sentegrity: Report a Problem";
    // Email Content
    NSString *messageBody = @"I encountered an error running Sentegrity";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"jsinchak@sentegrity.com"];
    
    // Create the mail compose view controller
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    mailComposeViewController.mailComposeDelegate = self;
    [mailComposeViewController setSubject:emailTitle];
    [mailComposeViewController setMessageBody:messageBody isHTML:NO];
    [mailComposeViewController setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mailComposeViewController animated:YES completion:NULL];
    
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


- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //scroll inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.viewFooter.frame.size.height, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
}


- (void)viewDidAppear:(BOOL)animated
{

    NSLog(@"SentegrityTAF_UnlockViewController: viewDidAppear");
    [super viewDidAppear:animated];
    
    
    //run core detection only once (when screen is loaded and showed)
    if (!once)
        [self checkForPolicyAndRunCoreDetection];

    once = YES;
    
    
    
}


- (void) checkForPolicyAndRunCoreDetection {
    
    
    NSError *error;
    Sentegrity_Policy *policy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
    NSString * currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    if (![policy.applicationVersionID isEqualToString:currentVersion]) {
        
        //if application version is not same as version in policy, we need to download new policy
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        // Upload run history (if necessary) and check for new policy
        [[Sentegrity_Network_Manager shared] uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback:^(BOOL successfullyExecuted, BOOL successfullyUploaded, BOOL newPolicyDownloaded, NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:NO];

            if (newPolicyDownloaded) {
                //new policy downloaded, run core detection
                [self runCoreDetection];
            }
            else {
                
                NSString *errorMessage;
                if (error)
                    errorMessage = error.localizedDescription;
                else
                    errorMessage = @"Could not download new policy.";
                
                //error occured, show error message and ask user for retry
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                               message:errorMessage
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [self checkForPolicyAndRunCoreDetection];
                                                                      }];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];

            }
        }];
    }
    else {
        [self runCoreDetection];
    }
    
}



- (void) runCoreDetection {
    // For demonstration purposes, retrieve startup data stored by FirstTimeViewController
    //NSString *startupData = [DAFAuthState getInstance].firstTime;
    //NSLog(@"SentegrityTAF_UnlockViewController: startup data = <%@>", startupData);
    
    // Run Core Detection
    
    // Show Animation
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.hud.labelText = @"Evaluating";
    self.hud.labelFont = [UIFont fontWithName:@"OpenSans-Bold" size:25.0f];
    
    self.hud.detailsLabelText = @"Mobile Device Posture";
    self.hud.detailsLabelFont = [UIFont fontWithName:@"OpenSans-Regular" size:18.0f];
    
    
    __weak SentegrityTAF_UnlockViewController *weakSelf = self;
    
    // Kick off Core Detection
    @autoreleasepool {
        
        dispatch_queue_t myQueue = dispatch_queue_create("Core_Detection_Queue",NULL);
        
        dispatch_async(myQueue, ^{
            
            // Perform Core Detection
            @try {
                
                [weakSelf performCoreDetection:weakSelf];
                
            } @catch (NSException *exception) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf coreDetectionerrorRecovery];
                    
                });
                
            }
            
            
        });
    }
}


- (void)coreDetectionerrorRecovery {
 
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    
    // We avoid analyzePreAuthenticationActions
    
    // Create  dummy computation results object that forces user login
    Sentegrity_TrustScore_Computation *computationResults = [[Sentegrity_TrustScore_Computation alloc]init];
    
    // Set the pre authetnication action
    computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPasswordAndWarn;
    
    // Set to breach class
    computationResults.attributingClassID = 1;
    
    // Set GUI manually
    computationResults.systemGUIIconID = 1;
    computationResults.systemGUIIconText = @"Unknown Risk";
    
    computationResults.userGUIIconID = 1;
    computationResults.userGUIIconText = @"Unknown Risk";
    
    // Set the core detection result to error
    computationResults.coreDetectionResult = CoreDetectionResult_CoreDetectionError;
    
    // Set the post authentication action, we cant whitelist because we have no assertions
    computationResults.postAuthenticationAction = postAuthenticationAction_DoNothing;
    
    // Populate data for dashboard
    // Scores

    computationResults.deviceTrusted = NO;
    computationResults.userTrusted = NO;
    computationResults.systemTrusted = NO;
    computationResults.systemScore = 0;
    computationResults.deviceScore=0;
    computationResults.userScore=0;
    
    // Set GUI messages (system)
    computationResults.systemIssues = [NSArray arrayWithObjects: @"Device error detected", nil];
    computationResults.systemSuggestions = [NSArray arrayWithObjects: @"Restart device", nil];
    computationResults.systemAnalysisResults = [NSArray arrayWithObjects: @"Analysis incomplete",  @"Unknown risks present",  nil];
    
    // Set GUI messages (user)
    computationResults.userIssues = [NSArray arrayWithObjects: @"User error detected", nil];
    computationResults.userSuggestions = [NSArray arrayWithObjects: @"Restart device", nil];
    computationResults.userAnalysisResults = [NSArray arrayWithObjects: @"Analysis incomplete", @"Unknown risks present", nil];
    
    
    // Set the last computation results manually so that confirm() can use it
    [[CoreDetection sharedDetection] setComputationResults:computationResults];
    
    // Call the normal stuff
    [self showInput];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kLastRun"];
    
    
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
    __weak SentegrityTAF_UnlockViewController *weakSelf = self;
    
    // Run Core Detection
    [[CoreDetection sharedDetection] performCoreDetectionWithCallback:^(BOOL success, Sentegrity_TrustScore_Computation *computationResults, NSError **error) {
        
        // Check if core detection completed successfully
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [weakSelf analyzePreAuthenticationActionsWithError:error];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                [weakSelf showInput];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kLastRun"];
                /*
                //Don't show input if we successfully transparently authenticated
                if(computationResults.deviceTrusted==YES && computationResults.preAuthenticationAction ==preAuthenticationAction_TransparentlyAuthenticate){
                    
                    // Don't show input as this screen will be
                }
                else{
                    [self showInput];
                }
                 */

                
            });
            
            // Log the errors
            NSLog(@"\n\nErrors: %@", [*error localizedDescription]);
            
        } else {
            // Core Detection Failed
            NSLog(@"Failed to run Core Detection: %@", [*error localizedDescription] ); // Here's why
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //handling error by calling recovery
                [weakSelf coreDetectionerrorRecovery];
            });
        }
        
    }]; // End of the Core Detection Block
    
} // End of Core Detection Function

#pragma mark - Analysis

// Set up the customizations for the view
- (void)analyzePreAuthenticationActionsWithError:(NSError **)error {
    
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    
    // The only preAuthenticationActions handled here are transparent, blockAndWarn,
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
                    
                    NSString *decryptedMasterKeyString = [[Sentegrity_Crypto sharedCrypto] convertDataToHexString:decryptedMasterKey withError:error];
                    
                    
                    
    
                    // Direct call outside of DAF, but fails
                    // NSError *error;
                    // GDTrust *trustObject = [[DAFAppBase getInstance] gdTrust];
                    // [trustObject unlockWithPassword:decryptedMasterKey error:&error];

                    
                    // We're done so dismiss the unlock view and show the dashboard behind it (called by mainviewcontroller)
                    // Dismiss the view
                    if (self.delegate) {
                        // Use the decrypted master key
                        [result setResult:decryptedMasterKeyString];
                        result = nil;
                        [self.delegate dismissSuccesfullyFinishedViewController:self];
                    }
                    else
                        [self dismissViewControllerAnimated:NO completion:^{
                            // Use the decrypted master key
                            [result setResult:decryptedMasterKeyString];
                            result = nil;
                        }];
                    // Done
                    break;
                    
                }
                    
                default: //Transparent auth errored, something very wrong happened because the transparent module found a match earlier...
                {
                    // Have the user interactive login
                    // Manually override the preAuthenticationAction and recall this function, we don't need to run core detection again
                    
                    computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
                    computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
                    
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
            
            // TODO: Change to show denied view instead of popup box
            [self showAlertWithTitle:@"Access Denied" andMessage:@"This device is high risk or in violation of policy, this access attempt has been denied."];
            
            // Done
            break;
            
        }
            
        case preAuthenticationAction_PromptForUserPassword:
        {
            // Do nothing, show login screen and try to login with TouchID
            [self tryToLoginWithTouchID];
            break;
        }
            
        case preAuthenticationAction_PromptForUserPasswordAndWarn:
        {
            
            // Show warning message then show login prompt
            [self showAlertWithTitle:@"Warning" andMessage:@"This device is high risk or in violation of policy, this access attempt will be reported."];
            
            break;
        }
            
        default:
            break;
            
    } // Done switch preauthentication action
    
}


#pragma mark - touchID


- (void) tryToLoginWithTouchID {
    NSError *error;

    
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
    if (error) {
        //did not able to read startup file, break
        return;
    }
    
    
    //if touchID is already configured
    if (!startup.touchIDDisabledByUser && startup.touchIDKeyEncryptedMasterKeyBlobString) {
        
        [self.touchIDManager getTouchIDPasswordFromKeychainwithMessage:@"Login with TouchID" withCallback:^(TouchIDResultType resultType, NSString *password, NSError *error) {
            if (resultType == TouchIDResultType_Success) {
                
                
                Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];

                Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithTouchIDpassword:password andError:&error];
                
                // Set the authentication response code
                computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
                
                // Set history now, we already have all the info we need
                [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:&error];
                
                // Success and recoverable errors operate the same since we still managed to get a decrypted master key
                if(computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError ) {
                    
                    // Now we can pass the key to the GD runtime
                    NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
                    
                    NSString *decryptedMasterKeyString = [[Sentegrity_Crypto sharedCrypto] convertDataToHexString:decryptedMasterKey withError:&error];
                    
                    [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
                }
                else {
                    [self showAlertWithTitle:loginResponseObject.responseLoginTitle andMessage:loginResponseObject.responseLoginDescription];
                }
            }
            else if (resultType == TouchIDResultType_ItemNotFound) {
                //probabbly invalidated item due change of fingerprint set, we will just try to delete it
                [self.touchIDManager removeTouchIDPasswordFromKeychainWithCallback:nil];
                [self showAlertWithTitle:@"Notice" andMessage:@"One of the fingerprints on this device have changed, password is required to continue"];
            }
            else {
                //if failed auth, or user simply pressed cancel, do nothing
            }
        }];
    
    }

}



- (void) createTouchIDWithDecryptedMasterKey: (NSData *) decryptedMasterKey {
    
#warning needs to implement random password generator
    NSString *randomPassword = @"RandomPassword";
    
    
    __weak SentegrityTAF_UnlockViewController *weakSelf = self;
    
    //first we want for sure delete old keychain item (if any) that can remain from previous installation of the app
    [self.touchIDManager removeTouchIDPasswordFromKeychainWithCallback:^(TouchIDResultType resultType, NSError *error) {
        
        //we succesfully deleted old keychain item, or item does not even exists
        if (resultType == TouchIDResultType_ItemNotFound || resultType == TouchIDResultType_Success) {
            //store new password into touchID keychain
            [weakSelf.touchIDManager addTouchIDPasswordToKeychain:randomPassword withCallback:^(TouchIDResultType resultType, NSError *error) {
                
                if (resultType == TouchIDResultType_Success && !error) {
                    
                    [[Sentegrity_Startup_Store sharedStartupStore] updateStartupFileWithTouchIDPassoword:randomPassword masterKey:decryptedMasterKey withError:&error];
                    
                    if (error) {
                        //TODO: error message for user
                        [weakSelf showAlertWithTitle:@"Unknown error" andMessage:error.localizedDescription];
                        [weakSelf.touchIDManager removeTouchIDPasswordFromKeychainWithCallback:nil];
                    }
                }
                else if (resultType == TouchIDResultType_DuplicateItem) {
                    [weakSelf showAlertWithTitle:@"Error" andMessage:@"TouchID is already stored."];
                }
                else {
                    [weakSelf showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
                }
            }];
        }
        else
            [weakSelf showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
    }];
}



#pragma mark - Mail Compose Delegate

// Mail compose view controller finished
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)mailResult error:(NSError *)error {
    
    // Check what the mail output was
    switch (mailResult) {
            
        case MFMailComposeResultCancelled:
            NSLog(@"Mail Cancelled");
            break;
            
        case MFMailComposeResultSaved:
            NSLog(@"Mail Saved");
            break;
            
        case MFMailComposeResultSent:
            NSLog(@"Mail Sent");
            break;
            
        case MFMailComposeResultFailed:
            NSLog(@"Mail Sent Failure: %@", [error localizedDescription]);
            break;
            
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
