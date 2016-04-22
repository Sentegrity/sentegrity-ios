//
//  SentegrityTAF_AppDelegate.m
//  Sentegrity
//
//  Created by Kramer, Nicholas on 6/8/15.
//  Copyright (c) 2015 Sentegrity. All rights reserved.
//

#import "SentegrityTAF_AppDelegate.h"


@implementation SentegrityTAF_AppDelegate

#pragma mark - Good DAF

// Setup NIBS
- (void)setupNibs {
    
    // Get the nib for the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.mainViewController = [[SentegrityTAF_MainViewController alloc]
                                   initWithNibName:@"SentegrityTAF_MainViewController_iPhone"
                                   bundle:nil];
        self.firstTimeViewController = [[SentegrityTAF_FirstTimeViewController alloc]
                                        initWithNibName:@"SentegrityTAF_FirstTimeViewController_iPhone"
                                        bundle:nil];
        self.unlockViewController = [[SentegrityTAF_UnlockViewController alloc]
                                     initWithNibName:@"SentegrityTAF_UnlockViewController_iPhone"
                                     bundle:nil];
        self.easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc]
                                             initWithNibName:@"SentegrityTAF_AuthWarningViewController_iPhone"
                                             bundle:nil];
        
    } else {
        self.mainViewController = [[SentegrityTAF_MainViewController alloc]
                                   initWithNibName:@"SentegrityTAF_MainViewController_iPad"
                                   bundle:nil];
        self.firstTimeViewController = [[SentegrityTAF_FirstTimeViewController alloc]
                                        initWithNibName:@"SentegrityTAF_FirstTimeViewController_iPad"
                                        bundle:nil];
        self.unlockViewController = [[SentegrityTAF_UnlockViewController alloc]
                                     initWithNibName:@"SentegrityTAF_UnlockViewController_iPad"
                                     bundle:nil];
        self.easyActivationViewController = [[SentegrityTAF_AuthWarningViewController alloc]
                                             initWithNibName:@"SentegrityTAF_AuthWarningViewController_iPad"
                                             bundle:nil];
    }
}

// This is our override of the super class showUIForAction.
- (void)showUIForAction:(enum DAFUIAction)action withResult:(DAFWaitableResult *)result
{
    NSLog(@"DAFSkelAppDelegate: showUIForAction (%d)", action);
    switch (action)
    {
        case AppStartup:
            // Occurs on each application startup (foreground as well)
            
            /* SENTEGRITY:
             * Start ACTIVITY DISPATCHER here
             
             * DESCRIPTION FROM API DOCS
             * Occurs after the GD runtime is initialized, and before GD's 'authorize' is called.
             * The app should set a root view controller for DAFAppBase::gdWindow . Other views
             * (e.g. password entry) will appear over it. Typically the root view will allow maintenance
             * actions (such as 'lock application', 'change password') to be initiated.
             */
            
            [self setupNibs];
            [self.gdWindow setRootViewController:self.mainViewController];
            [self.gdWindow makeKeyAndVisible];
            break;
            
        case GetAuthToken_FirstTime:
            // Used to connect to a hardware device for the first time ever
            // Sentegrity doesn't use this, just pass it back
            
            /* DESCRIPTION FROM API DOCS:
             * Occurs when DAF is about to call DADevice::createSession during the initial
             * application setup sequence. If user interaction is required to choose a device
             * and/or assist with its initial connection, a suitable view should be shown in response to this event.
             */
            
            NSLog(@"DAFSkelAppDelegate: starting activation UI");
            [super showUIForAction:action withResult:result];
            //[self.firstTimeViewController setResult:result];
            //[self.mainViewController presentViewController:self.firstTimeViewController animated:NO completion:nil];
            break;
            
        case GetAuthToken:
            // This is used to connect to a hardware device and establish a "session"
            // Sentegrity doesn't use this, just pass this back
            
            /* DESCRIPTION FROM API DOCS:
             * Occurs when DAF is about to call DADevice::createSession to reconnect to the device used
             * for authentication. This may be used to prompt the user to activate the device, give a status report, and so on.
             */
            
            NSLog(@"DAFSkelAppDelegate: starting unlock UI");
            [super showUIForAction:action withResult:result];
            
            //[self.unlockViewController setResult:result];
            //[self.mainViewController presentViewController:self.unlockViewController animated:NO completion:nil];
            break;
            
        case GetAuthToken_WithWarning:
            // If a warning is present it will be showed here prior to starting the authetnication process
            // These are warnings that come from the GD runtime such as "easy activation" when other Good apps are present
            // Sentegrity doesn't use this, let the default view controllers handle it
            
            /* DESCRIPTION FROM API DOCS:
             * This is used when a warning must be shown to the user before starting an authentication sequence, for
             * example when processing an Easy Activation request. The warning is described by a DAFAuthenticationWarning
             * object, which can be accessed using the DAFAppBase::authWarning property.
             *
             * The user should be given an option to reject the request for authentication; in this case cancelAuthenticateWithWarn:
             * (DAFAppBase) should be called.
             *
             * The application should not ignore this request. Passing it back to the default
             * showUIForAction:withResult: (DAFAppBase) handler will result in the authentication request being rejected.
             */
            
            // We can call the default view controllers here, but don't pass it back to "[super showUIForAction:action withResult:result];"
            [self.easyActivationViewController setResult:result];
            [self.mainViewController presentViewController:self.easyActivationViewController animated:NO completion:nil];
            break;
            
        case GetPassword_FirstTime:
            // Prompts for user to create password
            
            /* SENTEGRITY:
             * We are "layering" over the existing password mechanism by passing in our MASTER_KEY
             * instead of what would normally be the user's password. Here we will generate the Core Detection startup file
             * we will show Ivo's creat password view controller and once a password is accepted
             * call the startup file to create a new one using this password. 
             
             * NSString *masterKeyString = [[Sentegrity_Startup_Store sharedStartupStore] populateNewStartupFileWithUserPassword:password withError:error];
             
             * In response, the startup file will be created and will return a masterKey a string, this MASTER_KEY can be used
             * to setResult here and complete the first time setup process.

             
             
             * DESCRIPTION FROM API DOCS:
             * Where a user password is required (see DA_AUTH_PUBLIC), this should present a screen which allows the user
             * to set an initial password. This event occurs during the application setup sequence.
             *
             * DAFAppBase::passwordViewController provides a simple (built in) implementation of this function.
             */
            
            // REMOVED THIS SUPER CALL ONCE IMPLEMENT SENTEGRITY VIEWCONTROLLER (IT SHOWS THE DEFAULT)
            [super showUIForAction:action withResult:result];
            
            break;
        case GetPassword:
            // Prompts for user password/authentication
            
            /* SENTEGRITY:
             * Run core detection and analyze core detection results here
             * Results can be analyzed using analyzePreAuthenticationActionsWithError() (see LoginViewController inside Sentegrity Project)
             * The goal here is to basically port all the functionality from LoginViewController in the standalone Sentegrity app to here
             * and analyzed specifically, the preAuthenticationAction
             * If preAuthenticationAction=Transparently_Authentication we simply setResult here to MASTER_KEY (convert to string first)
             * If preAuthenticationAction=promptUserForPassword or promptUserForPasswordAndWarn
             * then show Ivo's Login view controller, in the event of "AndWarn" we show the popup box once LoginViewcontroller loads
             * If preAuthenticationAction=BlockAndWarn we can invoke the popup w/ message once LoginViewcontroller loads and
             * hide the input boxes
             *
             * If the user successfully authenticates via Ivo's login screen
             * (loginResponseObject.authenticationResponseCode = authenticationResult_Success)
             * the MASTER_KEY will have been returned in the loginResponseObject and we can setResult with it here
             
             
             * DESCRIPTION FROM API DOCS:
             * Where a user password is required (see DA_AUTH_PUBLIC), this should present a screen prompting the
             * user to enter their password in order to complete authentication.
             
             * DAFAppBase::passwordViewController provides a simple implementation of this function.
             */
            
            // REMOVED THIS SUPER CALL ONCE IMPLEMENT SENTEGRITY VIEWCONTROLLER (IT SHOWS THE DEFAULT)
            [super showUIForAction:action withResult:result];
            break;
        case GetOldPassword:
            // setResult to string containing old password during password change
            // NA (NOT IMPLEMENTED YET IN SENTEGRITY)
            
            /* DESCRIPTION FROM API DOCS:
             * When a user password is being changed, this should present a screen requesting the user's old (existing) password.
             * DAFAppBase::passwordViewController provides a simple implementation of this function.
             */
            
            break;
        case GetNewPassword:
            // setResult to string containing new password during password change
            // NA (NOT IMPLEMENTED YET IN SENTEGRITY)
            
            /* DESCRIPTION FROM API DOCS:
             * When a user password is being changed, this should present a screen requesting the user to set a new password.
             * DAFAppBase::passwordViewController provides a simple implementation of this function.
             */
            
            break;
        default:
            
            // Pass on all other requests (and any actions added in future)
            // to DAFAppBase's default implementation.
            [super showUIForAction:action withResult:result];
            break;
    }
}


- (void)eventNotification:(enum DAFUINotification)event withMessage:(NSString *)msg
{
    NSLog(@"DAFSkelAppDelegate: we got an event notification, type=%d message='%@'", event, msg);
    [super eventNotification:event withMessage:msg];
    
    // Pass the message to all of the view controllers
    [self.mainViewController updateUIForNotification:event];
    [self.firstTimeViewController updateUIForNotification:event];
    [self.unlockViewController updateUIForNotification:event];
    [self.easyActivationViewController updateUIForNotification:event];
}

@end
