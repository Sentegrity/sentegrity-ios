/*
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

/**
 * \file DAFEventTypes.h
 *
 * \brief DAFSupport framework (iOS only): Event types used by DAFAppBase.h
 *
 * DAFAppBase notifies the device-type-specific user interface
 * of various events via the getUIForAction:withResult:
 * and eventNotification:withMessage: methods.
 *
 * The DAFUIAction events generally require a response of some 
 * form, and should not be ignored. The DAFUINotification events
 * are for information only, although the UI status will typically
 * be updated in response to them.
 */

#ifndef BTLEAuthenticator_DAFEventTypes_h
#define BTLEAuthenticator_DAFEventTypes_h

/** \brief User interface actions requested by DAFAppBase
 *
 * See the documentation for DAFAppBase::getUIForAction:withResult: for
 * more information. 
 */
enum DAFUIAction
{
    /** \brief Application start event.
     * Occurs after the GD runtime is initialized, and before GD's 'authorize'
     * is called. The app should set a root view controller for \ref
     * DAFAppBase::gdWindow . Other views (e.g. password entry) will appear
     * over it. Typically the root view will allow maintenance actions
     * (such as 'lock application', 'change password') to be initiated.
     */
    AppStartup,
    
    /** \brief Make initial connection to device
     *
     * Occurs when DAF is about to call \ref DADevice::createSession
     * during the initial application setup sequence. If user interaction
     * is required to choose a device and/or assist with its initial connection,
     * a suitable view should be shown in response to this event.  
     */
    GetAuthToken_FirstTime,
    
    /** \brief Connect to device for authentication
     *
     * Occurs when DAF is about to call \ref DADevice::createSession
     * to reconnect to the device used for authentication. This may be used
     * to prompt the user to activate the device, give a status report, and
     * so on.
     */
    GetAuthToken,
    
    /** \brief Get initial password during provisioning
     *
     * Where a user password is required (see \ref DA_AUTH_PUBLIC), this
     * should present a screen which allows the user to set an initial
     * password. This event occurs during the application setup sequence.
     *
     * \ref DAFAppBase::passwordViewController provides a simple
     * implementation of this function.
     */
    GetPassword_FirstTime,
    
    /** \brief Get user password
     *
     * Where a user password is required (see \ref DA_AUTH_PUBLIC), this
     * should present a screen prompting the user to enter their password
     * in order to complete authentication.
     *
     * \ref DAFAppBase::passwordViewController provides a simple
     * implementation of this function.
     */
    GetPassword,
    
    /** \brief Get existing password during password-change
     * 
     * When a user password is being changed, this should present a screen
     * requesting the user's old (existing) password.
     *
     * \ref DAFAppBase::passwordViewController provides a simple
     * implementation of this function.
     */
    GetOldPassword,
    
    /** \brief Get replacement password during password-change
     *
     * When a user password is being changed, this should present a screen
     * requesting the user to set a new password.
     *
     * \ref DAFAppBase::passwordViewController provides a simple
     * implementation of this function.
     */
    GetNewPassword,
    
    /** \brief <b>(NEW IN 2.0)</b> Connect to device for authentication, showing warning
     *
     * This is used when a warning must be shown to the user before
     * starting an authentication sequence, for example when processing
     * an Easy Activation request. The warning is described by a 
     * \ref DAFAuthenticationWarning object, which can be
     * accessed using the \ref DAFAppBase::authWarning property.
     *
     * The user should be given an option to reject the request for
     * authentication; in this case DAFAppBase::cancelAuthenticateWithWarn:
     * should be called. 
     *
     * The application should not ignore this request. Passing it back
     * to the default DAFAppBase::getUIForAction:withResult: handler
     * will result in the authentication request being rejected. 
     */
    GetAuthToken_WithWarning,

    
};

/** \brief User interface notifications sent by DAFAppBase
 */
enum DAFUINotification
{
    AuthorizationSucceeded,	///< GD app is now unlocked (authorized)
    AuthorizationFailed,    ///< GD app is still locked
    IdleLocked,	            ///< GD app has become locked (due to timeout or user request)
    GetPasswordCancelled,   ///< Get-password sequence is being cancelled; app should close UI
    ChangePasswordSucceeded,///< Change-password sequence completed OK
    ChangePasswordFailed,	///< Change-password sequence failed
    ChangePasswordCancelled,///< Change-password sequence was cancelled; app should close UI
    AuthWithWarnCancelled,  ///< Authenticate-with-warn sequence is being cancelled; app should close UI
    AuthWithWarnFailed,     ///< Authenticate-with-warn sequence failed
};

#endif
