/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/** \file DAFAppBase.h
 *
 * \brief DAFSupport framework (iOS only): Base class for DAF Applications
 */

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <GD/GDiOS.h>

#import "GDTrust.h"
#import "DAFEventTypes.h"
#import "DAFWaitableResult.h"
#import "DAFDefaultStartupViewController.h"
#import "DAFDefaultPasswordViewController.h"
#import "DAFDefaultUnhandledOperationController.h"
#import "DAFPINEntryViewController.h"
#import "DAFAuthenticationWarning.h"

/** \brief Handler for DAF 'user operations'.
 *
 * 'User operations' are application functions which need a DAF Session
 * to complete. DAFAppBase provides a method for creating a session
 * (launching the UI to get an auth token if necessary), then calling back
 * a user-supplied handler with it. The callback is made on the DAF 
 * 'operations thread'; this allows blocking calls, and also ensures that
 * only one DAF call will be threaded at any one time.
 */

struct DASession;

@protocol DAFUserOperationHandler
- (void)runWithSession:(struct DASession *)session;
///< Performs the user operation, given a DASession object. The
///  session is torn down when the handler returns.

- (void)notifyFailure:(NSString *)message;
///< Called instead of runWithSession: if session creation failed
///  (or the operation was cancelled).
@end


/** \brief Base class for iOS DAF Applications
 *
 * The DAFAppBase class implements the GDTrustDelegate and
 * GDiOSDelegate protocols which must be provided to make a Trusted Authenticator
 * application using the Good Dynamics SDK. It uses DAF's 'authglue'
 * library (see \ref authglue.h) to make calls to the DADevice implementation
 * in order to produce the authentication secret value used to unlock the GD
 * containers.
 *
 * The app will usually need to provide user interfaces for such things as
 * prompts during authentication, initial setup, and device maintenance. This 
 * is done by implementing a subclass of DAFAppBase which overrides the
 * \ref getUIForAction:withResult: and \ref eventNotification:withMessage: methods.
 * This subclass is used as the UIApplicationDelegate object for the application.
 *
 * Default implementations of getUIForAction:withResult: and eventNotification:withMessage:
 * are provided which may be used if no customisation is required for a given action.
 *
 * On startup, DAFAppBase creates a thread (a DAFOperationsThread object) to 
 * perform cryptographic operations required to service GD TA requests.
 * All DADevice / DASession calls are made from this thread (not the
 * main iOS UI thread), so that they can block whilst waiting for
 * a hardware response.
 *
 */
@interface DAFAppBase : UIResponder <UIApplicationDelegate, GDiOSDelegate, GDTrustDelegate>

+ (DAFAppBase *)getInstance;
/**< \brief (static) Get DAFAppBase instance.
 *
 * \return Returns the instance of the \ref DAFAppBase object for this application.
 * This value gets recorded during the didFinishLaunchingWithOptions: method.
 */

/* Properties ---------------------------------- */

@property (strong, nonatomic) GDiOS *gdlib;
/**< (Property) reference to GD library instance */

@property (strong, nonatomic) GDTrust *gdTrust;
/**< \brief GDTrust object, used to make calls to GD's Trusted Authenticator API.
 * DAF applications will not usually need to use this directly.
 */

@property (strong, nonatomic) DAFDefaultStartupViewController *startupViewController;
/**< \brief Default view controller for startup actions.
 *
 *  This view controller is presented by the default implementation of \ref 
 *  getUIForAction:withResult: for the \ref AppStartup action. This presents an
 *  empty view and does not allow any user interaction. It is loaded by
 *  \ref loadDefaultViewControllers at app startup.
 */

@property (strong, nonatomic) DAFDefaultPasswordViewController *passwordViewController;
/**< \brief Default view controller for user password entry actions.
 *
 *   This is presented by the DAFAppBase's implementation of \ref getUIForAction:withResult:
 *   for password actions (\ref GetPassword_FirstTime etc). This controller presents
 *   basic, unbranded, password-entry screens which are suitable for basic TA apps. It
 *   is loaded by \ref loadDefaultViewControllers at app startup.
 */

@property (strong, nonatomic) DAFDefaultUnhandledOperationController *unhandledOperationController;
/**< \brief Default view controller for unhandled operations.
 *
 *  This view controller is presented by the default implementation of \ref
 *  getUIForAction:withResult: when an action needs to be implemented by the application
 *  but its not. This presents a basic view displaying an unhandled operation message. 
 *  It is loaded by \ref loadDefaultViewControllers at app startup.
 */

@property (strong, nonatomic) DAFPINEntryViewController *pinEntryViewController;
/**< \brief May be used to enter a PIN (numeric) value
 * 
 * This isn't ever presented by DAFAppBase's default handlers, but is available for
 * use by user programs.
 */

@property (weak, nonatomic)   UIWindow *gdWindow;
/**< The app's main window */

@property (strong, nonatomic) NSBundle *resourceBundle;
/**< Reference to the DAFSupportResources.bundle used internally by the DAFSupport framework */

@property (readonly) DAFAuthenticationWarning *authWarning;
/**< <b>NEW IN 2.0</b> Describes warning which should be given to the user for \ref GetAuthToken_WithWarning.
 *   Will be nil if no warning is required.
 */

/* Provided methods -------------------------------------------------
 *
 * The following are implemented in DAFAppBase and can be
 * called from UI code.
 */

/** \brief Request application lock
 * \param message   This is for information only; it is simply saved
 *                  in the log file.
 *
 * UI code can call this to request that the application is de-authorized,
 * e.g. in response to the user clicking a 'lock' button, or the loss of
 * communication with authentication hardware.
 *
 * Note that the GD runtime will begin a new authorization (unlock)
 * sequence as soon as this is called. This will result in a callback
 * to \ref getUIForAction:withResult: for the \ref GetAuthToken action. If the
 * app does not want to unlock at this time, it may delay the response
 * to GetAuthToken artibrarily.
 */
- (void)deauthorize:(NSString *)message;

/** \brief <b>(NEW in 2.0)</b> Reject an authentication-with-warning request
 *
 * When an authentication request is made using
 * \ref GetAuthToken_WithWarning, the user should be given an option
 * to reject the request. Call this method to inform DAF that the
 * request has been cancelled because it was rejected by the user.
 */
- (void)cancelAuthenticateWithWarn:(DAFWaitableResult *)authTokenResult;

/** \brief Request a change-password sequence.
 *
 * UI code can call this to request a change-password sequence,
 * e.g. in response to a user request.
 *
 * \return YES if the sequence has been started,
 *         NO if it can't be started at present (e.g. because
 *         the app is not unlocked, or not provisioned, or a
 *         password-change sequence is already in progress).
 */
- (BOOL)requestChangePassphrase;

/** \brief Request recovery sequence.
 *
 * If authentication cannot be completed, a recovery
 * sequence can be requested. To do this, the UI code can call
 * requestRecovery when the GetAuthToken operation is in 
 * progress. This will abandon the current authentication sequence
 * in an orderly way, and then initiate the 'temporary unlock' flow.
 * When this is done, a new GetAuthToken_FirstTime operation will
 * be requested, and a fresh authentication secret can be generated.
 *
 * \param authTokenResult 'result' parameter passed to getUIForAction.
 *                This result will be cancelled.
 */
- (void)requestRecovery:(DAFWaitableResult *)authTokenResult;

// Internal methods ------------------------------------

#if !(DOXYGEN)
// These are called by the internal DAF operations thread
// UI code should not normally call these.

- (void)opsGetAuthToken:(DAFWaitableResult *)res;
///< (Internal use) ops thread calls this before CreateSession

- (void)opsGetInitialPassphrase:(DAFWaitableResult *)res;
///< (Internal use) ops thread calls during enrollment sequence

- (void)opsGetAuthPassphrase:(DAFWaitableResult *)res;
///< (Internal use) ops thread calls during regular unlock sequence

- (void)opsGetOldPassphrase:(DAFWaitableResult *)res;
///< (Internal use) ops threads calls during password-change sequence

- (void)opsGetNewPassphrase:(DAFWaitableResult *)res;
///< (Internal use) ops threads calls during password-change sequence

- (void)opsAuthenticationSucceeded:(NSData *)block;
///< (Internal use) ops threads calls at end of enrolment and unlock sequences

- (void)opsAuthenticationFailed:(NSString *)message;
///<(Internal use) ops thread can call this during enrolment or unlock

- (void)opsChangePassphraseSucceeded:(NSArray *)oldAndNewBlocks;
///< (Internal use) ops thread calls at end of password-change sequence.
/// \param oldAndNewBlocks is an array of two NSData *

- (void)opsChangePassphraseFailed:(NSString *)message;
///< Internal use: ops thread can call this during password-change sequence

- (void)opsUserOperationDone:(id<DAFUserOperationHandler>)handler;
///< Internal use: indicates operations thread is finished running a user operation

#endif // !(DOXYGEN)

- (void)loadDefaultViewControllers;
/**<  Called to load default view controller NIBs during startup
 *
 * The implementation provided by DAFAppBase sets \ref resourceBundle, 
 * and loads \ref startupViewController and \ref passwordViewController from it.
 * A subclass could override this to replace these with other VCs if desired.
 */
 
- (BOOL)startUserOperation:(id<DAFUserOperationHandler>)handler withWarning:(DAFAuthenticationWarning *)warning;
/**< Begins a generic 'user operation' sequence
  *
  *  This launches the GetAuthToken_WithWarning UI to get 'auth token' data,
  *  then creates a DASession object with it. The session is passed to the 
  *  runWithSession: selector on the given 'handler' object.
  *
  *  Returns NO if the UI is unable to launch a session at this time, and
  *  YES if the sequence has been started.
  */

// Device-specific methods -----------------------------

- (UIViewController *)getUIForAction:(enum DAFUIAction)action withResult:(DAFWaitableResult *)result;
/**< \brief Get a UI screen for various actions.
 *
 * A subclass of DAFAppBase may override this method to specify a device-type-specific
 * user interface for various system actions.
 * \param action the action for which UI is being requested.
 * \param result the DAFWaitableResult object which is used to signal completion 
 *     of the operation.
 *
 * When the UI action has completed, 'result' should be set ( see \ref DAFWaitableResult::setResult: )
 * as follows:
 * - for \ref GetAuthToken, \ref GetAuthToken_FirstTime and \ref GetAuthToken_WithWarning
 * the result should be an NSData * byte-block; this is passed to \ref DADevice::createSession to start
 * a device session.
 * - for \ref GetPassword_FirstTime, \ref GetPassword, \ref GetOldPassword and 
 * \ref GetNewPassword, the result is an NSString * containing the entered password.
 *
 * DAFAppBase provides a default implementation for all of these actions,
 * - for \ref AppStartup, it presents \ref startupViewController
 * - for \ref GetAuthToken and \ref GetAuthToken_FirstTime, imediately returns a
 *    zero-length byte block to 'result'.
 * - for \ref GetAuthToken_WithWarning (<b>NEW IN 2.0</b>), it presents an alert to the user
 *    advising that the request type (see \ref DAFAuthenticationWarning) is not supported, then
 *    calls \ref cancelAuthenticateWithWarn: 
 * - for \ref GetPassword_FirstTime, \ref GetPassword, \ref GetOldPassword and 
 * \ref GetNewPassword, presents \ref passwordViewController.
 */

- (void)eventNotification:(enum DAFUINotification)event withMessage:(NSString *)msg;
/**< \brief Launch or update user interface in response to various events.
 *
 * The UI may update its status (e.g. show messages or enable/disable controls)
 * in response to these notifications.
 *
 * \param event is an event type code
 * \param msg is an error message for the \ref AuthorizationFailed and \ref
 * ChangePasswordFailed events. It is nil otherwise.
 *
 * DAFAppBase provides a default implementation of this method, which ignores all
 * events.
 */
@end
