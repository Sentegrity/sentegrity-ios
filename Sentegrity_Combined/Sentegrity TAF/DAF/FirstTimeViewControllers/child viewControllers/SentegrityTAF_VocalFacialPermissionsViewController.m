//
//  SentegrityTAF_VocalFacialPermissionsViewController.m
//  Sentegrity
//
//  Created by Ivo Leko on 13/11/16.
//  Copyright © 2016 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_VocalFacialPermissionsViewController.h"
#import "Sentegrity_Startup.h"
#import "Sentegrity_Startup_Store.h"
#import <AVFoundation/AVFoundation.h>
#import "ILContainerView.h"
#import "CaptureConfiguration.h"
#import "CaptureViewController.h"
#import "UICKeyChainStore.h"


@interface SentegrityTAF_VocalFacialPermissionsViewController () <CaptureDelegate>

@property (weak, nonatomic) IBOutlet ILContainerView *containerView;


@end

@implementation SentegrityTAF_VocalFacialPermissionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //need to remove keychain item because maybe there is remaining item from previous app installation
    UICKeyChainStore *keychain = [[UICKeyChainStore alloc] initWithService:@"com.sentegrity.vocalfacial"];
    [keychain removeItemForKey:@"vocalFacialPassword"];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showAlertToAskAboutCameraPermissions {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Open settings to allow Camera?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
    
    UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"]];
                                                           }];
    
    
    [alert addAction:cancelAction];
    [alert addAction:settingsAction];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
    
}

- (void) startVocalFacialEnrollment {
    [self.containerView setCurrentViewController:self];
    
    NSError *error;
    Sentegrity_Startup *currentStartup = [[Sentegrity_Startup_Store sharedStartupStore] getStartupStore:&error];
    
    if (error) {
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        return;
    }
    
    //load Capture and put it on ILContainerview
    CaptureConfiguration *captureConfiguration = [[CaptureConfiguration alloc] initForEnrollment];
    [captureConfiguration updateWithClassIDString:currentStartup.email];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"CaptureViewController" bundle:nil];
    CaptureViewController *viewController = [storyboard instantiateInitialViewController];
    
    
    // Set captureConfiguration to the CaptureViewController
    viewController.configuration = captureConfiguration;
    
    // Set callback to self
    viewController.callback = self;
    
    [self.containerView setChildViewController:viewController];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.containerView.alpha = 1.0;
    }];
}


// Implement the biometricTaskFinished function to receive the result if the biometric task finished
- (void)biometricTaskFinished:(CaptureConfiguration *)data withSuccess:(BOOL)success {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        //to avoid multiple calling
        [(CaptureViewController *)self.containerView.childViewController setCallback:nil];
        
        
        // HERE you get the result of the biometric task from the CaptureViewController
        if (success && data.performEnrollment) {
            
            
            NSData *randomSalt = [[Sentegrity_Crypto sharedCrypto] generateSalt256];
            NSError *error;
            NSString *randomPassword = [[Sentegrity_Crypto sharedCrypto] convertDataToHexString:randomSalt withError:&error];
            
            
            [[Sentegrity_Startup_Store sharedStartupStore] updateStartupFileWithVocalFacialPassword:randomPassword masterKey:self.decryptedMasterKey withError:&error];
            
            if (error) {
                [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
                return;
            }
            
            
            //save password to keychain
#warning just for demo (insecure)
            UICKeyChainStore *keychain = [[UICKeyChainStore alloc] initWithService:@"com.sentegrity.vocalfacial"];
            keychain[@"vocalFacialPassword"] = randomPassword;
            
            
            [self.delegate dismissSuccesfullyFinishedViewController:self withInfo:nil];
        }
        else {
            //out animation
            [UIView animateWithDuration:0.3 animations:^{
                self.containerView.alpha = 0;
            } completion:^(BOOL finished) {
                self.containerView.childViewController = nil;
            }];
        }
    });
}




- (IBAction)pressedAccept:(id)sender {
    
    // check for camera permissions
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        NSLog(@"Camera access not determined. Ask for permission");
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startVocalFacialEnrollment];
                });
            }
        }];
    }
    
    else if (authStatus == AVAuthorizationStatusAuthorized) {
        [self startVocalFacialEnrollment];
    }
    else {
        [self showAlertToAskAboutCameraPermissions];

    }
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
    [startup setVocalFacialDisabledByUser:YES];
    [[Sentegrity_Startup_Store sharedStartupStore] setStartupStoreWithError:nil];
    [self.delegate dismissSuccesfullyFinishedViewController:self withInfo:nil];
     */
}
@end
