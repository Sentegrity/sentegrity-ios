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
#import "SentegrityTAF_SupportViewController.h"

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

// TouchID
#import "SentegrityTAF_TouchIDManager.h"

// BioID
#import "CaptureConfiguration.h"
#import "CaptureViewController.h"

// Helpers and wrappers
#import "ILContainerView.h"
#import "UICKeyChainStore.h"
#import "Reachability.h"



@interface SentegrityTAF_UnlockViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate, CaptureDelegate, SentegrityTAF_SupportDelegate> {
    BOOL once;
}

@property (nonatomic) DashboardViewController *dashboardViewController;



@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *onePixelConstraintsCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomFooterConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewSplash;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIView *viewFooter;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;

@property (weak, nonatomic) IBOutlet ILContainerView *containerViewForBioID;
@property (weak, nonatomic) IBOutlet ILContainerView *containerViewForSupport;



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
    self =  [self initWithNibName:@"SentegrityTAF_UnlockViewController" bundle:nil];

    
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
    

    SentegrityTAF_TouchIDManager *touchIDManager = [SentegrityTAF_TouchIDManager shared];
    
   Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithPassword:passwordAttempt andError:&error];
   
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
           
           if ([touchIDManager checkIfTouchIDIsAvailableWithError:nil]) {
               
               //great, it is available, now check is touchID already configured, but item is invalidated
               if (touchIDManager.touchIDItemInvalidated) {
                   //create touchID again
                   [touchIDManager createTouchIDWithDecryptedMasterKey:decryptedMasterKey withCallback:^(BOOL successful, NSError *error) {
                       [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
                   }];
               }
               //if touch ID is already configured and active, that means that user probbably canceled TouchID auth, or failed with auth. In both cases, just ignore and continue.
               else if (startup.touchIDKeyEncryptedMasterKeyBlobString) {
                   // do nothing
                   [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
               }
               else {
                   //This should never happen because we are asking user for touchID after password creation
                   NSLog(@"WARNING: TouchID not configured and not disabled.");
                   [touchIDManager checkForTouchIDAuthWithMessage:@"Would you like to enable TouchID as one of the options for authentication?" withCallback:^(TouchIDResultType resultType, NSError *error) {
                       
                       if (resultType == TouchIDResultType_Success) {
                           //create touchID again
                           [touchIDManager createTouchIDWithDecryptedMasterKey:decryptedMasterKey withCallback:^(BOOL successful, NSError *error) {
                           }];
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
        [self.delegate dismissSuccesfullyFinishedViewController:self withInfo:nil];
    }
    else
        [self dismissViewControllerAnimated:NO completion:^{
            [result setResult:decryptedMasterKeyString];
            result = nil;
        }];
    
    // Added for testing
   // [result setResult:decryptedMasterKeyString];
    //result = nil;

}


- (void) showInput {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.buttonInfo.alpha = 1.0;
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


- (void) dismissSupportViewController {
    self.containerViewForSupport.alpha = 0;
    self.containerViewForSupport.childViewController = nil;
    [self.textFieldPassword becomeFirstResponder];
}

// Report a problem
- (IBAction)pressedInfoButton:(id)sender {
    
    //Trouble logging in? Show support screen
    
    [self.textFieldPassword resignFirstResponder];
    
    SentegrityTAF_SupportViewController *supportVC = [[SentegrityTAF_SupportViewController alloc] init];
    supportVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:supportVC];
    
    self.containerViewForSupport.currentViewController = self;
    self.containerViewForSupport.childViewController = nav;
    self.containerViewForSupport.alpha = 1;
    
   
    
    
    /*
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
     
     */
    
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
        //[self runCoreDetection];

    once = YES;
    
}


- (void) checkForPolicyAndRunCoreDetection {

    
    NSError *error;
    
    //get currently in-use policy and app version
    Sentegrity_Policy *inUsePolicy = [[Sentegrity_Policy_Parser sharedPolicy] getPolicy:&error];
    NSString * currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    
    //if application versions is not same as version in policy, we need to update policy before running core detection
    if (![inUsePolicy.applicationVersionID isEqualToString:currentAppVersion]) {
        
        //if currently in-use policy does not belong to any organisation (it is default policy)...
        if ([inUsePolicy.policyID isEqualToString:@"default"]) {
            //...than we can simply replace it with this new policy from app's bundle
            
            
            Sentegrity_Policy *policyFromBundle = [[Sentegrity_Policy_Parser sharedPolicy] loadPolicyFromMainBundle:&error];
            if (error) {
                NSLog(@"CRITICAL ERROR, cannot load policy from bundle");
                [self showAlertWithTitle:@"ERROR" andMessage:error.localizedDescription];
                return;
            }
            
            [[Sentegrity_Policy_Parser sharedPolicy] saveNewPolicy:policyFromBundle withError:&error];
            if (error) {
                NSLog(@"CRITICAL ERROR, cannot save new policy");
                [self showAlertWithTitle:@"ERROR" andMessage:error.localizedDescription];
                return;
            }
            
            [self runCoreDetection];
        }
        
        
        //if currently in-use policy is not default, we need to try to get new policy from server
        else {
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            
            // Upload run history (if necessary) and check for new policy
            [[Sentegrity_Network_Manager shared] uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback:^(BOOL successfullyExecuted, BOOL successfullyUploaded, BOOL newPolicyDownloaded, BOOL policyOrganisationExists, NSError *error) {
                
                
                [MBProgressHUD hideHUDForView:self.view animated:NO];
                
                
                //first check if any error occured (like network connection problems). If error, show message to user and ask him for retry.
                if (!successfullyExecuted) {
                    
                    NSString *errorMessage;
                    if (error)
                        errorMessage = error.localizedDescription;
                    else
                        errorMessage = @"Could not download new policy. Please try again.";
                    
                    //error occured, show error message and ask user for retry
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                   message:errorMessage
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {
                                                                              [self checkForPolicyAndRunCoreDetection];
                                                                          }];
                    [alert addAction:defaultAction];
                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
                }
                
                
                //next, check if new policy is downloaded
                else if (newPolicyDownloaded) {
                
                    //new policy downloaded and stored, we are ready to run core detection
                    [self runCoreDetection];
                }
                
                else {
                    //last known scenario, request is finished without errors, but we did not get any policy
                    //need to check useDefaultAsBackup to decide what to do next
                    
                    if (inUsePolicy.useDefaultAsBackup.boolValue) {
                        //just use default policy from bundle as current policy
                        Sentegrity_Policy *policyFromBundle = [[Sentegrity_Policy_Parser sharedPolicy] loadPolicyFromMainBundle:&error];
                        if (error) {
                            NSLog(@"CRITICAL ERROR, cannot load policy from bundle");
                            [self showAlertWithTitle:@"ERROR" andMessage:error.localizedDescription];
                            return;
                        }
                        
                        [[Sentegrity_Policy_Parser sharedPolicy] saveNewPolicy:policyFromBundle withError:&error];
                        if (error) {
                            NSLog(@"CRITICAL ERROR, cannot save new policy");
                            [self showAlertWithTitle:@"ERROR" andMessage:error.localizedDescription];
                            return;
                        }
                        
                        //run core detection
                        [self runCoreDetection];
                    
                    }
                    else {
                        //no available policy for new app version :(. Show message to the user.
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                       message:@"This app version is not supported by your organization"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Try again" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {
                                                                                  [self checkForPolicyAndRunCoreDetection];
                                                                              }];
                        [alert addAction:defaultAction];
                        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
                        
                    }
                }
            }];
        }
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
    
    self.hud.labelText = @"Authenticating User";
    self.hud.labelFont = [UIFont fontWithName:@"OpenSans-Regular" size:20.0f];
    //self.hud.labelFont = [UIFont fontWithName:@"OpenSans-Bold" size:25.0f];
    
    //self.hud.detailsLabelText = @"Performing Risk Assessment";
    //self.hud.detailsLabelFont = [UIFont fontWithName:@"OpenSans-Regular" size:18.0f];
    
    
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
    computationResults.authenticationAction = authenticationAction_PromptForUserPasswordAndWarn;
    
    // Set to breach class
    computationResults.attributingClassID = 1;
    
    // Set GUI manually

    computationResults.dashboardText = @"Unknown Risk";
    
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
    
    // Set GUI messag
    computationResults.userSubClassResultObjects = nil;
    computationResults.systemSubClassResultObjects = nil;

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
    [[Sentegrity_Network_Manager shared] uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback:^(BOOL successfullyExecuted, BOOL successfullyUploaded, BOOL newPolicyDownloaded, BOOL policyOrganisationExists, NSError *error) {

        
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
                
                
                [weakSelf analyzeAuthenticationActionsWithError:error];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                [weakSelf showInput];
 
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kLastRun"];

                
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
- (void)analyzeAuthenticationActionsWithError:(NSError **)error {
    
    // Get last computation results
    Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
    
    [self.textFieldPassword becomeFirstResponder];
    
    // The only preAuthenticationActions handled here are transparent, blockAndWarn,
    switch (computationResults.authenticationAction) {
        case authenticationAction_TransparentlyAuthenticate:
        {
            
            [self.textFieldPassword resignFirstResponder];

            // Attempt to login
            // we have no input to pass, use nil
            Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithTransparentAuthentication:error];
            
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
                        [self.delegate dismissSuccesfullyFinishedViewController:self withInfo:nil];
                    }
                    else
                        [self dismissViewControllerAnimated:NO completion:^{
                            // Use the decrypted master key
                            [result setResult:decryptedMasterKeyString];
                            result = nil;
                           [self showAlertWithTitle:computationResults.authenticationModuleEmployed.warnTitle andMessage:computationResults.authenticationModuleEmployed.warnDesc];
                        }];
                    // Done
                    break;
                    
                }
                    
                default: //Transparent auth errored, something very wrong happened because the transparent module found a match earlier...
                {
                    // Have the user interactive login
                    // Manually override the preAuthenticationAction and recall this function, we don't need to run core detection again
                    
                    computationResults.authenticationAction = authenticationAction_PromptForUserPassword;
                    computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
                    
                    // Done
                    break;
                    
                }
                    
            } // Done Switch AuthenticationResult
            
            // Done
            break;
            
        }
        case authenticationAction_TransparentlyAuthenticateAndWarn:
        {
            NSLog(@"AAAA");
            
            [self.textFieldPassword resignFirstResponder];

            
            // Attempt to login
            // we have no input to pass, use nil
            Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithTransparentAuthentication:error];
            
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
                        [self.delegate dismissSuccesfullyFinishedViewController:self withInfo:nil];
                    }
                    else
                        [self dismissViewControllerAnimated:NO completion:^{
                            // Use the decrypted master key
                            [result setResult:decryptedMasterKeyString];
                            result = nil;
                            [self showAlertWithTitle:computationResults.warnTitle andMessage:computationResults.warnDesc];
                        }];
                    // Done
                    break;
                    
                }
                    
                default: //Transparent auth errored, something very wrong happened because the transparent module found a match earlier...
                {
                    // Have the user interactive login
                    // Manually override the preAuthenticationAction and recall this function, we don't need to run core detection again
                    
                    computationResults.authenticationAction = authenticationAction_PromptForUserPassword;
                    computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
                    
                    // Done
                    break;
                    
                }
                    
            } // Done Switch AuthenticationResult
            
            // Done
            break;

        }
        case authenticationAction_PromptForUserFingerprint:
        {
            //No promptForUserFingerprintAndWarn because TouchID always displays a message
            [self tryToLoginWithTouchIDMessage:computationResults.authenticationModuleEmployed.warnTitle];
            
            break;
        }
        case authenticationAction_PromptForUserFingerprintAndWarn:
        {
            
            // Show message and than call fingerprint
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:computationResults.warnTitle
                                                                           message:computationResults.warnDesc
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self tryToLoginWithTouchIDMessage:computationResults.authenticationModuleEmployed.warnTitle];
                                                                  }];
            
            
            [alert addAction:defaultAction];
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
            
            //No promptForUserFingerprintAndWarn because TouchID always displays a message
            //[self tryToLoginWithTouchIDMessage:computationResults.authenticationModuleEmployed.warnTitle];
            
            break;
        }
        case authenticationAction_PromptForUserPassword:
        {
            //show login screen and try to login with TouchID
            //[self tryToLoginWithTouchID];
            break;
        }
            
        case authenticationAction_PromptForUserPasswordAndWarn:
        {
            
            // Since we're already on the login screen, simply show a popup message then allow user to interact with login prompt
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:computationResults.warnTitle andMessage:computationResults.warnDesc];
            });
            
            
            break;
        }
        case authenticationAction_PromptForUserVocalFacial:
        {
            // vocal facial login
            [self tryToLoginWithVocalFacial];
            break;
        }
            
        case authenticationAction_PromptForUserVocalFacialAndWarn:
        {
            
            
            // Show message and than call vocal facial login
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:computationResults.warnTitle
                                                                           message:computationResults.warnDesc
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [self tryToLoginWithVocalFacial];
                                                                  }];
            
            
            [alert addAction:defaultAction];
            
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
            
            /*
            [self dismissViewControllerAnimated:NO completion:^{
                // Use the decrypted master key

                [self showAlertWithTitle:computationResults.authenticationModuleEmployed.warnTitle andMessage:computationResults.authenticationModuleEmployed.warnDesc];
            }];
        */
            // Not implemented yet
            break;
        }
        case authenticationAction_BlockAndWarn:
        {
            
            
            // Login Response
            Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithBlockAndWarn:error];
            
            // Set the authentication response code
            computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
            
            // Set history now, we already have all the info we need
            [[Sentegrity_Startup_Store sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:error];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // TODO: Change to show denied view instead of popup box
                [self showAlertWithTitle:@"Access Denied" andMessage:@"This device is high risk or in violation of policy, this access attempt has been denied."];
            });
            
           
            
            // Done
            break;
            
        }
            
            
        default:
            break;
            
    } // Done switch preauthentication action
    
    
    
}




#pragma mark - touchID


- (void) tryToLoginWithTouchIDMessage:(NSString *) loginMessage {
    NSError *error;

    
    Sentegrity_Startup *startup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
    if (error) {
        //did not able to read startup file, break
        return;
    }
    SentegrityTAF_TouchIDManager *touchIDManager = [SentegrityTAF_TouchIDManager shared];

    
    //if touchID is already configured
    if (!startup.touchIDDisabledByUser && startup.touchIDKeyEncryptedMasterKeyBlobString) {
        
        if (loginMessage == nil)
            loginMessage = @"";
        
        [touchIDManager getTouchIDPasswordFromKeychainwithMessage:loginMessage withCallback:^(TouchIDResultType resultType, NSString *password, NSError *error) {
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
                [touchIDManager removeTouchIDPasswordFromKeychainWithCallback:nil];
                [self showAlertWithTitle:@"Notice" andMessage:@"One of the fingerprints on this device have changed, password is required to continue"];
            }
            else {
                //if failed auth, or user simply pressed cancel, do nothing

            }
        }];
    
    }

}


#pragma mark - Vocal/Facial




- (void) tryToLoginWithVocalFacial {
    
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        [self showAlertWithTitle:@"Notice" andMessage:@"There is no Internet access and facial recognition cannot be performed."];
        return;
    }
    
    
    [self.textFieldPassword resignFirstResponder];

    
    NSError *error;
    Sentegrity_Startup *currentStartup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
    
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        return;
    }
    
    
    //if vocal/facial is already configured
    if (!currentStartup.vocalFacialDisabledByUser && currentStartup.vocalFacialKeyEncryptedMasterKeyBlobString) {
        
        //load Capture and put it on ILContainerview
        CaptureConfiguration *captureConfiguration = [[CaptureConfiguration alloc] initForVerification:NO];
        [captureConfiguration updateWithClassIDString:currentStartup.email];
        
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"CaptureViewController" bundle:nil];
        CaptureViewController *viewController = [storyboard instantiateInitialViewController];
        
        // Set captureConfiguration to the CaptureViewController
        viewController.configuration = captureConfiguration;
        
        // Set callback to self
        viewController.callback = self;
        
        self.containerViewForBioID.currentViewController = self;
        self.containerViewForBioID.childViewController = viewController;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.containerViewForBioID.alpha = 1.0;
        }];
    }
}

// Implement the biometricTaskFinished function to receive the result if the biometric task finished
- (void)biometricTaskFinished:(CaptureConfiguration *)data withSuccess:(BOOL)success {
    
    NSError *error;
    
    //out animation
    [UIView animateWithDuration:0.3 animations:^{
        self.containerViewForBioID.alpha = 0;
    } completion:^(BOOL finished) {
        self.containerViewForBioID.childViewController = nil;
    }];
    
    //to avoid multiple calling
    [(CaptureViewController *)self.containerViewForBioID.childViewController setCallback:nil];
    
    // HERE you get the result of the biometric task from the CaptureViewController
    if (success && !data.performEnrollment) {
        
#warning just for demo (insecure)
        //get password from keychain
        UICKeyChainStore *keychain = [[UICKeyChainStore alloc] initWithService:@"com.sentegrity.vocalfacial"];
        NSString *password = keychain[@"vocalFacialPassword"];
       
        
        Sentegrity_TrustScore_Computation *computationResults = [[CoreDetection sharedDetection] getLastComputationResults];
        
        Sentegrity_LoginResponse_Object *loginResponseObject = [[Sentegrity_LoginAction sharedLogin] attemptLoginWithVocalFacial:password andError:&error];
        
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
