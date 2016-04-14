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

@optional
-(void)securityPolicyDidChange:(GDTrust*)trust;
/**< Policy changed callback.
 * \copydetails ssGDTrustDelegateSecurityPolicyDidChange
 */

@end

#endif
