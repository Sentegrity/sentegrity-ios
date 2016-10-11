/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

#pragma once

#import <Foundation/Foundation.h>

/** NSURLCredential category with additional features.
 * This class is a category of the Foundation <tt>NSURLCredential</tt> class
 * that can be used when the Good Dynamics (GD) proxy infrastructure is enabled in
 * the URL Loading System (see \ref GDURLLoadingSystem). This class provides the
 * ability to set the persistence of credentials.
 *
 * @see <a
 *     HREF="http://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLCredential_Class"
 *     target="_blank"
 * >NSURLCredential class reference</a> in the iOS Developer Library on the
 * apple.com website.
 */
@interface NSURLCredential (GDNET)

/** Credential persistence.
 * Set this property of an <tt>NSURLCredential</tt> object to specify the
 * persistence for the credential that it represents. This property can be set
 * on a server trust credential that is created as part of the processing of an
 * <tt>NSURLAuthenticationMethodServerTrust</tt> authentication challenge.
 *
 * The property can be set to one of the following values:
 * - <tt>NSURLCredentialPersistenceNone</tt> Credential will not be stored
 *   persistently.
 * - <tt>NSURLCredentialPersistencePermanent</tt> Credential will be stored
 *   persistently in the GD secure store on the mobile device.
 * .
 * 
 * If the credential is stored persistently then it will be reused automatically
 * every time an authentication challenge for the same protection space is
 * received. This means that the following callbacks will not be invoked:
 * - <tt>NSURLConnectionDelegate willSendRequestForAuthenticationChallenge</tt>
 * - <tt>GDURLRequestConnectionDelegate willSendRequestForAuthenticationChallenge</tt>
 * .
 * 
 * Automatic reuse continues until one of the following occurs:
 * - The server presents different certificate details.
 * - The application cancels persistence, by calling the
 *   <tt>undoPriorTrustDecision</tt> function.
 * .
 *
 * See the class reference of the \ref NSMutableURLRequest(GDNET) category for
 * details of the <tt>undoPriorTrustDecision</tt> function.
 */
@property (readwrite) NSUInteger gdPersistence;

@end
