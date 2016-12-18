/*
 * (c) 2015 Good Technology Corporation. All rights reserved.
 */

#ifndef __GD_TRUST_H__
#define __GD_TRUST_H__


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** \defgroup trustconstants Trusted Authenticator constants
 * \copydetails ssGDTrustAction
 * \{
 */

/** Constants for GDTrustAction type.
 * \copydetails ssGDTrustActionConst
 */
typedef enum
{
    GDTrustActionWipe = 0,
    /**< \copydetails ssGDTrustActionWipe
     */
    
    GDTrustActionBlock = 1,
    /**< \copydetails ssGDTrustActionBlock
     */
    
    GDTrustActionUnblock = 2,
    /**< \copydetails ssGDTrustActionUnblock
     */
    
    GDTrustActionTemporaryUnlock = 3,
    /**< \copydetails ssGDTrustActionTemporaryUnlock
     */
    
    GDTrustActionIdleLock = 4,
    /**< \copydetails ssGDTrustActionIdleLock
     */
    
    GDTrustActionRejectWarning = 5
    /**< \copydetails ssGDTrustActionRejectWarning
     */
    
} GDTrustAction;

/** Constants for GDTrustNotification type.
 * This enumeration represents the type of a GDTrustNotification that is being
 * sent. The parameter of a \link GDTrustDelegate::eventNotification:\endlink
 * invocation will always take one of these values.
 *
 * Note: In the current release, there is only one type of notification.
 */
typedef enum
{
    AuthenticateWithWarningCancelled
    /**< Authenticate and warn was cancelled implicitly.
     * This notification is dispatched when an authenticate and warn request is
     * implicitly cancelled. For example, implicit cancellation could take place
     * if the user brings another application to the foreground when an
     * authenticate and warn request is still being handled in the Trusted
     * Authenticator application.
     *
     * Do not execute a \ref GDTrustActionRejectWarning action in response to
     * this notification. The Good Dynamics Runtime detects implicit
     * cancellation itself and executes the necessary processing.
     *
     * Handling for this notification could include, for example, dismissing any
     * user interface shown in order to process an authenticate and warn
     * request.
     */
} GDTrustNotification;

/** \}
 */

/** \defgroup gdtrusterrordomain GDTrust Error Domain
 * These constants can be used when handling errors returned by
 * \ss_class_link{GDTrust} functions.
 *
 * \{
 */

extern NSString* const GDTrustErrorDomain;
/**< \copydetails ssGDTrustErrorDomain
 */

extern NSInteger const GDTrustPasswordDoesNotMatch;
/**< \copydetails ssGDTrustPasswordDoesNotMatch
 */

extern NSInteger const GDTrustRemoteLocked;
/**< \copydetails ssGDTrustRemoteLocked
 */

extern NSInteger const GDTrustWiped;
/**< \copydetails ssGDTrustWiped
 */

extern NSInteger const GDTrustErrGeneral;
/**< \copydetails ssGDTrustErrGeneral
 */

/** \}
 */

/** Trust actions for use by Good Dynamics Trusted Authenticator applications.
 * \copydetails ssGDTrust
 */
@interface GDTrust : NSObject

-(BOOL)unlockWithPassword:(NSData*)password error:(NSError**)error;
/**< Notify the Good Dynamics Runtime that user authentication succeeded.
 * \copydetails ssGDTrustUnlockWithPassword
 */

-(BOOL)performTrustAction:(GDTrustAction)action error:(NSError**)error;
/**< Notify the Good Dynamics Runtime that user authentication failed.\ Execute
 * a discretionary trust action.
 * \copydetails ssGDTrustPerformTrustAction
 */

-(BOOL)changePassword:(NSData*)oldPassword withNewPassword:(NSData*)newPassword error:(NSError**)error;
/**< Change the password.
 * \copydetails ssGDTrustChangePassword
 */
 
-(NSDictionary*)securityPolicy;
/**< Get policy setttings, from the enterprise Good Control server.
 * \copydetails ssGDTrustSecurityPolicy
 */

+(NSString *)getStartupData;
/**< Return startup data associated with the Trusted Authenticator app.
  * This will be a zero-length string for a fresh install or if reprovisioning
  * is required. Callers must be prepared to receive a zero-length string at
  * any time (for instance if the app has been wiped).
  */

+(void)setStartupData:(NSString *)startupData;
/**< Store startup data; this is generally called during provisioning.
  * Binary/nonprintable data should be base64-encoded or similar.
  */

@end

/** Handler for implementation of Good Dynamics Trusted Authenticator
 * applications.
 * \copydetails ssGDTrustDelegate
 */
@protocol GDTrustDelegate 
@required

-(void)authenticateWithTrust:(GDTrust*)trust;
/**< Authentication requested callback.
 * \copydetails ssGDTrustDelegateAuthenticateWithTrust
 */

-(void)authenticateWithTrust:(GDTrust *)trust
             warnWithMessage:(NSString *)message
                        icon:(UIImage *)icon;
/**< Authenticate and warn requested callback.
 * \copydetails ssGDTrustDelegateAuthenticateWithTrustWarn
 */

-(void)eventNotification:(GDTrustNotification)event;
/**< Trust notification callback.
 * This callback is invoked to notify the application of events that might
 * require handling by the Trusted Authenticator application code.
 *
 * See the \ref GDTrustNotification documentation for details of the
 * types of event that are dispatched through this interface, and of how they
 * could be handled.
 *
 * \param event <TT>GDTrustNotification</TT> object that represents the type of
 *              event being notified.
 */

@optional
-(void)securityPolicyDidChange:(GDTrust*)trust;
/**< Policy changed callback.
 * \copydetails ssGDTrustDelegateSecurityPolicyDidChange
 */

@end

#endif
