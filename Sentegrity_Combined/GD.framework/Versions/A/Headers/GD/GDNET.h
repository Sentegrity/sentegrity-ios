/*
 * (c) 2016 BlackBerry Limited. All rights reserved.
 *
 */

#pragma once

#import <Foundation/Foundation.h>
#import "GDURLLoadingSystem.h"
#import "GDPortability.h"

GD_NS_ASSUME_NONNULL_BEGIN

/** NSURLCache category with additional features.
 * This class is a category of the native <tt>NSURLCache</tt> class that adds
 * the functions documented below to the API. The additional functions can
 * be used when the Good Dynamics proxy infrastructure is enabled in the URL
 * Loading System (see \ref GDURLLoadingSystem). This class provides additional
 * features to the default cache.
 *
 * This documentation includes only additional operations that are not part
 * of the default <tt>NSURLCache</tt> API.
 *
 * Note that the additional features in this API cannot be used when the Good
 * Dynamics proxy infrastructure is disabled in the URL Loading System, even if
 * temporarily. If the functions are called in this state, they have no effect.
 * @see <a
 *     HREF="http://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLCache_Class"
 *     target="_blank"
 * >NSURLCache class reference</a> in the iOS Developer Library on apple.com
 */
@interface NSURLCache (GDURLCache)

/** Set the default maximum age of cached files.
 * Call this function to set a default maximum age for cached files.
 * The default maximum age will be used where it is less than the maximum age
 * specified in the server cache directive, if any.
 *
 * The default maximum only applies when the Good Dynamics proxy infrastructure
 * is enabled in the URL Loading System, see \ref GDURLLoadingSystem.
 *
 * @param age <tt>NSTimeInterval</tt> representing the maximum age in
 *            seconds.
 */
- (void) setMaxCacheFileAge:(NSTimeInterval) age;

/** Set the maximum permitted size of a cached file.
 * Call this function to set the maximum permitted size of a cached file.
 * If not set, a default maximum of 1 megabyte will be used.
 *
 * This function sets the limit for a single file, not for the size of the whole
 * cache. The capacity of the cache as a whole can be set using the
 * native <tt>NSURLCache</tt> API. See the <a
 *     HREF="http://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLCache_Class"
 *     target="_blank"
 * >NSURLCache class reference</a> in the iOS Developer Library on apple.com for
 * details.
 *
 * The permitted maximum only applies when the Good Dynamics proxy
 * infrastructure is enabled in the URL Loading System, see
 * \ref GDURLLoadingSystem.
 *
 * @param fileSize <tt>NSUInteger</tt> representing the maximum file size in
 *                 bytes.
 */
- (void) setMaxCacheFileSize:(NSUInteger) fileSize;

/** Get the maximum permitted size of a cached file.
 * Call this function to get the maximum permitted size of a cached file.
 *
 * This function returns the limit for a single file, not for the size of the
 * whole cache. The native <tt>NSURLCache</tt> API can be used to access
 * information about the cache as a whole. See the <a
 *     HREF="http://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSURLCache_Class"
 *     target="_blank"
 * >NSURLCache class reference</a> in the iOS Developer Library on apple.com for
 * details.
 *
 * The permitted maximum only applies when the Good Dynamics proxy
 * infrastructure is enabled in the URL Loading System, see
 * \ref GDURLLoadingSystem.
 *
 * @return <tt>NSUInteger</tt> representing the maximum file size in bytes.
 */
- (NSUInteger) maxCacheFileSize;

@end


/** Control the secure authentication cache.
 * Use this class to control the secure authentication caches of the
 * \ref GDURLLoadingSystem 
 * and \ref GDHttpRequest classes. (Currently, there are
 * only two controls.)
 * The secure authentication cache is used by these classes as follows:<dl
 * ><dt>GD URL Loading System</dt><dd
 * >Stores credentials for all authentication methods.\n
 * Stores tickets for Kerberos authentication.</dd>
 * <dt>GD HTTP Request</dt>
 * <dd>Stores tickets for Kerberos authentication.</dd>
 * </dl>
 */
@interface GDCacheController : NSObject {
}

/** Clear cached authentication credentials.
 * Call this function to clear the cached credentials for a particular
 * authentication method, or to clear for all methods.
 * Calling this function clears the session cache, and the permanent cache if
 * present. (Currently, the Good Dynamics Runtime only has a permanent
 * cache for Kerberos authentication tickets.)
 *
 * @param method
 * One of the following constants, specifying which cache or
 * caches are to be cleared:\n
 * <tt>NSURLAuthenticationMethodHTTPBasic</tt>
 * clears Basic Authentication credentials,\n
 * <tt>NSURLAuthenticationMethodDefault</tt>
 * also clears Basic Authentication credentials,\n
 * <tt>NSURLAuthenticationMethodHTTPDigest</tt>
 * clears Digest Authentication credentials,\n
 * <tt>NSURLAuthenticationMethodNTLM</tt>
 * clears NTLM Authentication credentials,\n
 * <tt>NSURLAuthenticationMethodNegotiate</tt>
 * clears Kerberos Authentication credentials and tickets,\n
 * <tt>nil</tt>
 * clears all of the above.
 */
+ (void) clearCredentialsForMethod:(GD_NSNULLABLE NSString*) method;

/** Allow or disallow Kerberos delegation.
 * Call this function to allow or disallow Kerberos delegation within
 * Good Dynamics secure communications. By default, Kerberos delegation is not
 * allowed.
 *
 * When Kerberos delegation is allowed, the Good Dynamics Runtime behaves as
 * follows:
 * - Kerberos requests will be for tickets that can be delegated.
 * - Application servers that are trusted for delegation can be sent tickets
 *   that can be delegated, if such tickets were issued.
 * .
 *
 * When Kerberos delegation is not allowed, the Good Dynamics Runtime behaves as
 * follows:
 * - Kerberos requests will not be for tickets that can be delegated.
 * - No application server will be sent tickets that can be delegated, even if
 *   such tickets were issued.
 * .
 *
 * After this function has been called, delegation will remain allowed or
 * disallowed until this function is called again with a different setting.
 *
 * Note: User and service configuration in the Kerberos Domain Controller
 * (typically a Microsoft Active Directory server) is required in order for
 * delegation to be successful. On its own, calling this function will not
 * make Kerberos delegation work in the whole end-to-end application.
 *
 * When this function is called, the Kerberos ticket and credentials caches
 * will be cleared. I.e. there is an effective call to the
 * \link GDCacheController::clearCredentialsForMethod:
 * clearCredentialsForMethod:\endlink function with an <tt
 * >NSURLAuthenticationMethodNegotiate</tt> parameter.
 *
 * @param allow <tt>BOOL</tt> for the setting: <tt>YES</tt> to allow delegation,
 *              <tt>NO</tt> to disallow.
 */
+ (void) kerberosAllowDelegation:(BOOL)allow;
@end


GD_NS_ASSUME_NONNULL_END
